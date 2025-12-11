// File: supabase/functions/realtime-notify/index.ts

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.43.4';

// --- PENGAMBILAN KREDENSIAL DARI SECRETS ---
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!; 
const FCM_SERVICE_ACCOUNT_JSON_STRING = Deno.env.get('FCM_SERVICE_ACCOUNT_JSON')!;
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!; 

if (!SUPABASE_SERVICE_ROLE_KEY || !FCM_SERVICE_ACCOUNT_JSON_STRING || !SUPABASE_URL) {
    throw new Error("Missing required environment variables.");
}

const FCM_SERVICE_ACCOUNT_JSON = JSON.parse(FCM_SERVICE_ACCOUNT_JSON_STRING);

// Klien Supabase dengan izin Service Role
const supabaseAdmin = createClient(
    SUPABASE_URL,
    SUPABASE_SERVICE_ROLE_KEY,
    {
        auth: {
            autoRefreshToken: false,
            persistSession: false,
        },
    }
);

const TRANSACTION_LIMIT = 1000000; // Batas Transaksi Besar (Rp 1.000.000)

// Interface untuk Payload Trigger Database
interface TransactionRecord {
    id: string;
    user_id: string;
    category_id: number;
    amount: number;
    description: string;
    date: string;
}

// Interface untuk Payload Notifikasi
interface FcmNotificationPayload {
    user_id: string;
    title: string;
    body: string;
    notification_type: 'large_transaction' | 'budget_warning' | 'budget_exceeded';
}

// --- FUNGSI HELPER: FCM V1 API INTEGRATION ---

let fcmAccessToken: string | null = null;

async function getFCMToken(): Promise<string> {
    if (fcmAccessToken) return fcmAccessToken; 
    
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
    
    const { data: tokenData, error: tokenError } = await supabaseAdmin
        .from('fcm_tokens')
        .select('fcm_token')
        .eq('user_id', payload.user_id);

    if (tokenError || !tokenData || tokenData.length === 0) {
        console.warn(`No FCM tokens found for user ${payload.user_id}`);
        // Lanjutkan untuk menyimpan ke DB meskipun tidak ada token perangkat
    }
    
    // 1. KIRIM KE FCM
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
        
        if (response.ok) {
            console.log(`FCM sent successfully: ${payload.notification_type} to user ${payload.user_id}`);
        } else {
            const error = await response.json();
            console.error(`FCM send failed for token ${token}:`, error);
        }
    }

    // 2. SIMPAN KE user_notifications (Agar notifikasi persisten)
    const { error: insertError } = await supabaseAdmin
        .from('user_notifications')
        .insert({
            user_id: payload.user_id,
            title: payload.title,
            message: payload.body,
            type: payload.notification_type, 
        });

    if (insertError) {
        console.error('Failed to insert notification into DB:', insertError);
    } else {
        console.log('Notification saved to user_notifications table.');
    }
}

// --- Edge Function Handler ---
serve(async (req: Request) => {
    try {
        console.log('Realtime notify function triggered.');

        if (req.method !== 'POST') {
            return new Response(JSON.stringify({ error: 'Method Not Allowed' }), { 
                status: 405, 
                headers: { 'Content-Type': 'application/json' } 
            });
        }

        const payload = await req.json();
        
        // ASUMSI: Payload dari Staging Function SQL memiliki field 'record'
        const newTrxRecord: TransactionRecord = payload.record;
        
        const today = new Date(newTrxRecord.date).toISOString().split('T')[0];
        console.log(`Processing transaction ID: ${newTrxRecord.id}, Amount: ${newTrxRecord.amount}`);


        // 1. Cek apakah ini adalah pengeluaran, jika tidak, abaikan
        const { data: categoryData, error: catError } = await supabaseAdmin
            .from('master_categories')
            .select('type, name')
            .eq('id', newTrxRecord.category_id)
            .maybeSingle();

        if (catError || !categoryData || categoryData.type !== 'expense') {
            console.log('Ignoring non-expense transaction or invalid category.');
            return new Response(JSON.stringify({ message: 'Ignoring non-expense transaction or invalid category' }), { 
                status: 200,
                headers: { 'Content-Type': 'application/json' },
            });
        }
        
        // --- 2. LOGIKA TRANSAKSI BESAR ---
        if (newTrxRecord.amount >= TRANSACTION_LIMIT) { 
            await sendFCMNotification({
                user_id: newTrxRecord.user_id,
                notification_type: 'large_transaction',
                title: '💰 Transaksi Besar Terdeteksi!',
                body: `Pengeluaran Rp${newTrxRecord.amount.toLocaleString('id-ID')} dicatat untuk "${newTrxRecord.description || 'Transaksi Umum'}".`,
            });
        }

        // --- 3. LOGIKA PERINGATAN/TERLAMPAUI BATAS ANGGARAN ---
        await checkBudgetAlerts(newTrxRecord, categoryData.name, today);
        
        return new Response(
            JSON.stringify({ message: 'Real-time checks completed successfully' }),
            {
                status: 200,
                headers: { 'Content-Type': 'application/json' },
            }
        );

    } catch (error) {
        const errorMessage = error instanceof Error ? error.message : 'Unknown error';
        console.error("ERROR IN REALTIME-NOTIFY:", errorMessage);
        return new Response(JSON.stringify({ error: errorMessage }), {
            status: 500,
            headers: { 'Content-Type': 'application/json' },
        });
    }
});

// Fungsi untuk memeriksa anggaran (Peringatan Batas & Terlampaui) - PERBAIKAN TOTAL
async function checkBudgetAlerts(newTrx: TransactionRecord, categoryName: string, today: string) {
    console.log(`Checking budget for category: ${categoryName}`);

    // Mengambil anggaran aktif yang cocok DAN FLAG NOTIFIKASI
    const { data: budget, error: budgetError } = await supabaseAdmin
        .from('budgets')
        .select('id, name, amount, totalDipakai, start_date, end_date, notif_90_sent, notif_100_sent') 
        .eq('user_id', newTrx.user_id)
        .eq('category', categoryName) 
        .lte('start_date', today)
        .gte('end_date', today)
        .maybeSingle();

    if (budgetError || !budget) {
        if (budgetError) console.error('Budget fetching error:', budgetError);
        else console.log('No active budget found for this category and date.');
        return; 
    }

    // PENTING: Hitung total pengeluaran BARU
    const newUsedAmount = (budget.totalDipakai || 0) + newTrx.amount; 
    const budgetLimit = budget.amount;
    const percentage = (newUsedAmount / budgetLimit) * 100;
    
    console.log(`Current spent: ${budget.totalDipakai}, New spent: ${newUsedAmount}, Percentage: ${percentage.toFixed(2)}%`);

    let notificationToSend: FcmNotificationPayload | null = null;
    let updatePayload: any = {};
    let shouldUpdateBudgetFlag = false; 

    // Logika 1: Terlampaui 100%
    if (percentage >= 100 && !budget.notif_100_sent) {
        console.warn('Budget exceeded 100%. Sending notification.');
        notificationToSend = {
            user_id: newTrx.user_id,
            notification_type: 'budget_exceeded',
            title: `🛑 Anggaran ${budget.name} Terlampaui!`,
            body: `Pengeluaran telah mencapai Rp${newUsedAmount.toLocaleString('id-ID')}, melebihi batas Rp${budgetLimit.toLocaleString('id-ID')}.`,
        };
        updatePayload = { notif_100_sent: true, notif_90_sent: true }; 
        shouldUpdateBudgetFlag = true;
    } 
    // Logika 2: Peringatan 90% (Hanya jika 100% belum tercapai dan 90% belum dikirim)
    else if (percentage >= 90 && percentage < 100 && !budget.notif_90_sent) {
        console.warn('Budget reached 90%. Sending warning.');
        notificationToSend = {
            user_id: newTrx.user_id,
            notification_type: 'budget_warning',
            title: `⚠️ Peringatan Batas Anggaran!`,
            body: `Pengeluaran ${budget.name} mencapai ${percentage.toFixed(0)}%. Segera batasi pengeluaran Anda.`,
        };
        updatePayload = { notif_90_sent: true };
        shouldUpdateBudgetFlag = true;
    }

    // --- PERBAIKAN KRITIS: UPDATE PENGELUARAN ---
    
    // SELALU tambahkan pengeluaran baru ke total pengeluaran di updatePayload.
    updatePayload.totalDipakai = newUsedAmount;

    if (notificationToSend) {
        await sendFCMNotification(notificationToSend);
    }
    
    // Selalu update database, baik hanya totalDipakai atau bersama dengan flag notifikasi.
    if (true) { // Update selalu berjalan karena harus update totalDipakai
        const { error: updateError } = await supabaseAdmin
            .from('budgets')
            .update(updatePayload) // updatePayload berisi totalDipakai dan flag (jika ada)
            .eq('id', budget.id);

        if (updateError) {
            console.error('ERROR UPDATING BUDGET:', updateError);
        } else {
            console.log(`Budget ${budget.id} updated successfully. New spent: ${newUsedAmount}`);
        }
    }
}