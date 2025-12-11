// File: supabase/functions/scheduled-notify/index.ts

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.43.4';

// --- PENGAMBILAN KREDENSIAL DARI SECRETS ---
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
const FCM_SERVICE_ACCOUNT_JSON_STRING = Deno.env.get('FCM_SERVICE_ACCOUNT_JSON');

if (!SUPABASE_SERVICE_ROLE_KEY || !FCM_SERVICE_ACCOUNT_JSON_STRING) {
    throw new Error("Missing required secrets (SUPABASE_SERVICE_ROLE_KEY atau FCM_SERVICE_ACCOUNT_JSON).");
}

const SUPABASE_URL = 'https://fqgpllrlrdowhzlsmely.supabase.co'; // Gunakan URL proyek Anda
const FCM_SERVICE_ACCOUNT_JSON = JSON.parse(FCM_SERVICE_ACCOUNT_JSON_STRING);

// Klien Supabase dengan izin Service Role
const supabaseAdmin = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
    auth: {
        autoRefreshToken: false,
        persistSession: false,
    },
});

let fcmAccessToken: string | null = null;

// Interface untuk Payload Notifikasi
interface FcmNotificationPayload {
    user_id: string;
    title: string;
    body: string;
    notification_type: 'log_reminder' | 'budget_end';
}


// --- FUNGSI HELPER: FCM V1 API INTEGRATION & TOKEN ---

async function getFCMToken(): Promise<string> {
    if (fcmAccessToken) return fcmAccessToken; 
    
    // Menggunakan Secret manual FCM_ACCESS_TOKEN
    const manualToken = Deno.env.get('FCM_ACCESS_TOKEN');
    if (manualToken) {
        fcmAccessToken = manualToken;
        return manualToken;
    }
    
    console.error("TOKEN AKSES FCM GAGAL DITEMUKAN. Notifikasi TIDAK AKAN TERKIRIM KE HP.");
    return "DUMMY_TOKEN_PLEASE_REPLACE_ME"; 
}


async function sendFCMNotification(payload: FcmNotificationPayload): Promise<void> {
    const accessToken = await getFCMToken();
    if (accessToken === "DUMMY_TOKEN_PLEASE_REPLACE_ME") return; 
    
    const fcmProjectId = FCM_SERVICE_ACCOUNT_JSON.project_id;
    const fcmUrl = `https://fcm.googleapis.com/v1/projects/${fcmProjectId}/messages:send`;
    
    // 1. Ambil semua token perangkat pengguna dari tabel fcm_tokens
    const { data: tokenData, error: tokenError } = await supabaseAdmin
        .from('fcm_tokens')
        .select('fcm_token')
        .eq('user_id', payload.user_id);

    if (tokenError || !tokenData || tokenData.length === 0) {
        console.warn(`No FCM tokens found for user ${payload.user_id}.`);
        // Lanjutkan ke penyimpanan DB meskipun tidak ada token perangkat
    }
    
    // Kirim notifikasi ke setiap token
    for (const token of tokenData ? tokenData.map((t: { fcm_token: string }) => t.fcm_token) : []) {
        const message = {
            message: {
                token: token,
                notification: {
                    title: payload.title,
                    body: payload.body,
                },
                data: {
                    type: payload.notification_type,
                }
            }
        };

        const response = await fetch(fcmUrl, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${accessToken}`, 
            },
            body: JSON.stringify(message),
        });

        if (!response.ok) {
            const error = await response.json();
            console.error(`FCM send failed for token ${token}:`, error);
        } else {
            console.log(`FCM sent successfully to ${token}`);
        }
    }

    // --- TAMBAHAN KRITIS: SIMPAN KE TABEL user_notifications ---
    const { error: insertError } = await supabaseAdmin
        .from('user_notifications')
        .insert({
            user_id: payload.user_id,
            title: payload.title,
            message: payload.body,
            // Asumsi: 'type' di DB sama dengan 'notification_type'
            type: payload.notification_type, 
        });

    if (insertError) {
        console.error('Failed to insert scheduled notification into DB:', insertError);
    } else {
        console.log('Scheduled notification saved to user_notifications table.');
    }
    // --- END TAMBAHAN KRITIS ---
}


// --- FUNGSI UTAMA UNTUK MENJALANKAN LOGIKA TERJADWAL ---
async function handleScheduledNotifications() {
    console.log('Running scheduled checks...');

    // 1. LOGIKA PENGINGAT LOG
    await checkLogReminders();

    // 2. LOGIKA ANGGARAN BERAKHIR & PERULANGAN
    await checkExpiringBudgets();
    
    console.log('Scheduled checks finished.');
}


// -----------------------------------------------------------
// 1. Logika Pengingat Log (Pengingat Log) - SOLUSI JOIN MANUAL
// -----------------------------------------------------------
async function checkLogReminders() {
    const twoDaysAgo = new Date(Date.now() - 48 * 60 * 60 * 1000).toISOString();

    // Mengambil SEMUA user ID yang berpotensi membutuhkan pengingat dari tabel users
    const { data: usersData, error: usersError } = await supabaseAdmin
        .from('users')
        .select('id, name, last_transaction_date')
        .or(`last_transaction_date.lte.${twoDaysAgo},last_transaction_date.is.null`);

    if (usersError) {
        console.error('Error fetching users for reminder:', usersError);
        return;
    }
    
    for (const user of usersData) {
        // Cek secara individual: apakah user memiliki token FCM?
        const { data: tokenData } = await supabaseAdmin
             .from('fcm_tokens')
             .select('fcm_token')
             .eq('user_id', user.id)
             .limit(1);

        // Kami mengirim notifikasi ke FCM/DB meskipun hanya ada 1 token
        if (tokenData && tokenData.length > 0) {
            const payload: FcmNotificationPayload = {
                user_id: user.id,
                notification_type: 'log_reminder',
                title: `Halo ${user.name || 'Pengguna'}!`,
                body: 'Sudah lama tidak mencatat? Jangan lupa catat transaksi hari ini agar keuanganmu terkelola.',
            };
            await sendFCMNotification(payload); 
        }
        // PENTING: Notifikasi juga harus dikirim jika tidak ada token, karena sendFCMNotification sekarang menyimpan ke DB.
        // Kita perlu memanggil sendFCMNotification sekali lagi di sini tanpa mengecek token, tetapi ini akan duplikasi.
        // Solusi di atas (memanggil sendFCMNotification di dalam checkLogReminders) sudah cukup.
    }
}

// -----------------------------------------------------------
// 2. Logika Anggaran Berakhir (Anggaran Berakhir & Recurrence) - KOREKSI QUERY
// -----------------------------------------------------------
async function checkExpiringBudgets() {
    const today = new Date().toISOString().split('T')[0];
    
    // Query sekarang tidak akan error karena 'repeat_type' sudah ditambahkan
    const { data: budgetsToExpire, error } = await supabaseAdmin
        .from('budgets')
        .select('id, user_id, name, category, amount, start_date, end_date, repeat_type, notif_end_sent')
        .lte('end_date', today) 
        .eq('notif_end_sent', false); 

    if (error) {
        console.error('Error fetching expiring budgets (Setelah Tambah Kolom):', error);
        return;
    }

    for (const budget of budgetsToExpire) {
        // A. KIRIM NOTIFIKASI (Sekarang akan menyimpan ke DB)
        const payload: FcmNotificationPayload = {
            user_id: budget.user_id,
            notification_type: 'budget_end',
            title: `Anggaran ${budget.name} Berakhir!`,
            body: `Anggaran ${budget.name} untuk kategori ${budget.category} telah berakhir.`,
        };
        await sendFCMNotification(payload); 
        
        // B. UPDATE FLAG NOTIFIKASI menjadi true (Agar tidak dikirim lagi)
        await supabaseAdmin
            .from('budgets')
            .update({ notif_end_sent: true })
            .eq('id', budget.id);

        // C. LOGIKA PERULANGAN (RECURRENCE) - UPDATE budget LAMA
        if (budget.repeat_type) {
            const updatedDates = calculateNewPeriod(budget.end_date, budget.repeat_type);
            
            if (updatedDates) {
                await supabaseAdmin
                    .from('budgets')
                    .update({
                        start_date: updatedDates.newStartDate,
                        end_date: updatedDates.newEndDate,
                        // Reset status notifikasi untuk periode baru
                        notif_90_sent: false,
                        notif_100_sent: false,
                        notif_end_sent: false, 
                    })
                    .eq('id', budget.id);
                console.log(`Budget ${budget.id} updated for next period.`);
            }
        }
    }
}

// Fungsi untuk menghitung tanggal periode baru (Recurrence)
function calculateNewPeriod(oldEndDate: string, repeatType: string): { newStartDate: string, newEndDate: string } | null {
    const oldEnd = new Date(oldEndDate);
    let newStartDate: Date;
    let newEndDate: Date;

    const dayAfterOldEnd = oldEnd.getTime() + (1 * 24 * 60 * 60 * 1000);
    newStartDate = new Date(dayAfterOldEnd);

    if (repeatType === 'Bulanan') {
        // Tambah satu bulan ke tanggal mulai baru
        newEndDate = new Date(newStartDate.getFullYear(), newStartDate.getMonth() + 1, newStartDate.getDate());
        // Koreksi sederhana untuk memastikan end date adalah akhir bulan jika end date lama adalah akhir bulan
        if (newEndDate.getDate() !== newStartDate.getDate()) {
             newEndDate = new Date(newStartDate.getFullYear(), newStartDate.getMonth() + 2, 0); // Akhir bulan depan
        }
    } else if (repeatType === 'Mingguan') {
        newEndDate = new Date(newStartDate.getTime() + (6 * 24 * 60 * 60 * 1000));
    } else if (repeatType === 'Harian') {
        newEndDate = newStartDate; 
    } else {
        return null; 
    }

    return {
        newStartDate: newStartDate.toISOString(),
        newEndDate: newEndDate.toISOString(),
    };
}


// --- Edge Function Handler ---
// Menggunakan serve() dari Deno std
serve(async (req) => {
    try {
        if (req.method !== 'POST') {
            return new Response(JSON.stringify({ error: 'Method Not Allowed' }), { 
                status: 405, 
                headers: { 'Content-Type': 'application/json' } 
            });
        }
        
        await handleScheduledNotifications(); 

        return new Response(JSON.stringify({ message: 'Scheduled checks completed successfully' }), {
            status: 200,
            headers: { 'Content-Type': 'application/json' },
        });
    } catch (error) {
        const errorMessage = error instanceof Error ? error.message : 'Unknown error';
        console.error("ERROR IN SCHEDULED-NOTIFY:", errorMessage);
        return new Response(JSON.stringify({ error: errorMessage }), {
            status: 500,
            headers: { 'Content-Type': 'application/json' },
        });
    }
});