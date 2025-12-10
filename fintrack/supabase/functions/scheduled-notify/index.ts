// File: supabase/functions/scheduled-notify/index.ts

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// --- KONFIGURASI SUPABASE ANDA ---
const SUPABASE_URL = 'https://fqgpllrlrdowhzlsmely.supabase.co';
// SERVICE_ROLE_KEY Anda
const SERVICE_ROLE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZxZ3BsbHJscmRvd2h6bHNtZWx5Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NDU5MzMxNCwiZXhwIjoyMDgwMTY5MzE0fQ.ShnlHUeQHP35h8yA5SoFOjxH1KLNfze13iBwbl5kgD8';

// Klien Supabase dengan izin Service Role
const supabaseAdmin = createClient(SUPABASE_URL, SERVICE_ROLE_KEY, {
    auth: {
        autoRefreshToken: false,
        persistSession: false,
    },
});

// Endpoint FCM Anda (GANTI INI DENGAN ENDPOINT FCM SERVER ASLI ANDA)
const FCM_ENDPOINT = 'PASTE_ENDPOINT_FCM_SERVER_ANDA_DI_SINI'; 


// --- FUNGSI UTAMA UNTUK MENJALANKAN LOGIKA TERJADWAL ---
async function handleScheduledNotifications() {
    console.log('Running scheduled checks...');
    const today = new Date().toISOString().split('T')[0]; // Format YYYY-MM-DD

    // 1. LOGIKA PENGINGAT LOG
    await checkLogReminders(today);

    // 2. LOGIKA ANGGARAN BERAKHIR & PERULANGAN
    await checkExpiringBudgets(today);
}

// -----------------------------------------------------------
// 1. Logika Pengingat Log (Pengingat Log)
// -----------------------------------------------------------
async function checkLogReminders(today: string) {
    const twoDaysAgo = new Date(new Date().setDate(new Date().getDate() - 2)).toISOString();

    const { data: users, error } = await supabaseAdmin
        .from('users')
        .select('id, name')
        .lte('last_transaction_date', twoDaysAgo)
        .or('last_transaction_date.is.null');

    if (error) {
        console.error('Error fetching users for reminder:', error);
        return;
    }

    for (const user of users) {
        const payload = {
            user_id: user.id,
            notification_type: 'log_reminder',
            title: `Halo ${user.name}!`,
            body: 'Jangan lupa catat transaksi hari ini agar keuanganmu terkelola.',
        };
        await sendFCMNotification(payload); 
    }
}

// -----------------------------------------------------------
// 2. Logika Anggaran Berakhir (Anggaran Berakhir)
// -----------------------------------------------------------
async function checkExpiringBudgets(today: string) {
    
    const { data: budgets, error } = await supabaseAdmin
        .from('budgets')
        .select('id, user_id, name, category, amount, start_date, end_date, repeat_type')
        .lt('end_date', today);

    if (error) {
        console.error('Error fetching expiring budgets:', error);
        return;
    }

    for (const budget of budgets) {
        const payload = {
            user_id: budget.user_id,
            notification_type: 'budget_end',
            title: `Anggaran ${budget.name} Berakhir!`,
            body: `Anggaran ${budget.name} untuk kategori ${budget.category} telah berakhir.`,
        };
        await sendFCMNotification(payload); 

        const newBudget = createNewRepeatingBudget(budget);
        if (newBudget) {
            await supabaseAdmin.from('budgets').insert(newBudget);
            console.log(`Created new budget for user ${budget.user_id}`);
        }
    }
}

async function sendFCMNotification(payload: any) {
    // Anda harus mengganti ini dengan logic panggilan HTTP POST ke FCM_ENDPOINT
    // menggunakan kunci FCM server Anda.
    console.log(`Sending scheduled notification to user ${payload.user_id}: ${payload.title}`);
}

function createNewRepeatingBudget(oldBudget: any) {
    const oldEndDate = new Date(oldBudget.end_date);
    let newStartDate: Date;
    let newEndDate: Date;

    if (oldBudget.repeat_type === 'Bulanan') {
        newStartDate = new Date(oldEndDate.getFullYear(), oldEndDate.getMonth() + 1, oldEndDate.getDate() + 1);
        newEndDate = new Date(newStartDate.getFullYear(), newStartDate.getMonth() + 2, 0); 
    } else if (oldBudget.repeat_type === 'Mingguan') {
        newStartDate = new Date(oldEndDate.getTime() + (24 * 60 * 60 * 1000));
        newEndDate = new Date(newStartDate.getTime() + (6 * 24 * 60 * 60 * 1000));
    } else {
        return null;
    }

    return {
        user_id: oldBudget.user_id,
        name: oldBudget.name,
        category: oldBudget.category,
        amount: oldBudget.amount,
        start_date: newStartDate.toISOString(),
        end_date: newEndDate.toISOString(),
        repeat_type: oldBudget.repeat_type,
    };
}


// --- Edge Function Handler ---
// Menggunakan 'Request' untuk memperbaiki type error
Deno.serve(async (req: Request) => {
    try {
        if (req.method !== 'POST') {
            return new Response('Method Not Allowed', { status: 405 });
        }
        
        await handleScheduledNotifications(); 

        return new Response('Scheduled checks completed successfully', {
            status: 200,
            headers: { 'Content-Type': 'application/json' },
        });
    } catch (error) {
        // Menggunakan instanceof Error untuk memperbaiki 'error is unknown'
        const errorMessage = error instanceof Error ? error.message : 'Unknown error';
        return new Response(JSON.stringify({ error: errorMessage }), {
            status: 500,
            headers: { 'Content-Type': 'application/json' },
        });
    }
});