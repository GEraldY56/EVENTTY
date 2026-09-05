# 🚀 RUN THIS SQL - Update Database yang Sudah Ada

**File:** `SUPABASE_UPDATE_EXISTING.sql`  
**Purpose:** Update database Anda yang sudah ada tanpa error

---

## ⚡ **QUICK INSTRUCTIONS**

### **1. Buka Supabase SQL Editor**
- Go to: https://supabase.com/dashboard
- Select project: `jqxzrxlfpazjnlchfpdm`
- Click **"SQL Editor"** di sidebar kiri
- Click **"+ New query"**

### **2. Copy SQL**
- Buka file: **`SUPABASE_UPDATE_EXISTING.sql`** (bukan yang COMPLETE)
- Select ALL (Ctrl+A)
- Copy (Ctrl+C)

### **3. Paste & Run**
- Paste ke SQL Editor (Ctrl+V)
- Click **"Run"** button
- Wait ~10 detik

### **4. Check Output**
Anda harus lihat:
```
✅ UPDATE COMPLETE!

📊 DATABASE STATUS:
- Tables: 9
- User Varo: 1 (exists)
- Events: 4 total
- Announcements: X total

👤 USER VARO:
- Email: 12345@eventty.app
- Password: indonesia
- NIS: 12345
- Kelas: XII RPL 1

✅ Ready to test! Login dengan NIS: 12345
```

---

## ✅ **WHAT THIS SQL DOES**

### **Safe Updates (No Errors!):**
1. ✅ Add missing columns to `announcements` table:
   - `category` (General, Event, Academic, Facility)
   - `priority` (low, medium, high)
   - `is_published` (true/false)

2. ✅ Add missing column to `news` table:
   - `is_published` (true/false)

3. ✅ Create or update User Varo:
   - Jika belum ada → Create new
   - Jika sudah ada → Update profile

4. ✅ Insert 4 sample events:
   - Delete old samples first (jika ada)
   - Insert fresh 4 events:
     1. Basketball Championship (Team, Winners)
     2. Career Day 2024 (Individual, All Participants)
     3. AI Seminar (Individual, All Participants)
     4. Coding Workshop (Individual, No Certificate)

### **Idempotent = Aman di-run berkali-kali!**
- ✅ Tidak create duplicate
- ✅ Tidak error kalau data sudah ada
- ✅ Hanya update yang perlu

---

## 🧪 **AFTER RUNNING SQL**

### **Test di App:**
```bash
flutter clean
flutter pub get
flutter run
```

### **Login:**
- **NIS:** 12345
- **Password:** indonesia

### **Expected:**
- ✅ Login berhasil
- ✅ Profile shows "Varo, XII RPL 1"
- ✅ Events tab shows 4 events
- ✅ Can register for events
- ✅ Announcements works (admin)

---

## 🐛 **TROUBLESHOOTING**

### **Still getting errors?**

**Option 1: Check specific error**
Screenshot error message dan share

**Option 2: Check what's already there**
Run this query in SQL Editor:
```sql
-- Check tables
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public'
ORDER BY table_name;

-- Check user Varo
SELECT * FROM profiles WHERE student_id = '12345';

-- Check events
SELECT id, title FROM events;

-- Check announcements columns
SELECT column_name 
FROM information_schema.columns 
WHERE table_name = 'announcements';
```

**Option 3: Fresh start (jika perlu)**
Jika mau reset total:
1. Drop semua tables
2. Run `SUPABASE_COMPLETE_SETUP.sql` (yang original)

---

## 📋 **COMPARISON**

| File | Use When | What It Does |
|------|----------|--------------|
| `SUPABASE_COMPLETE_SETUP.sql` | Fresh project | Creates everything from scratch |
| `SUPABASE_UPDATE_EXISTING.sql` ⭐ | **Existing data** | **Updates safely without errors** |

**Your case:** Database sudah ada → **Use `SUPABASE_UPDATE_EXISTING.sql`** ✅

---

## ✅ **READY!**

Run `SUPABASE_UPDATE_EXISTING.sql` sekarang!

**Expected time:** ~10 seconds  
**Expected result:** ✅ No errors, data updated!

---

**Created:** 2024-01-05  
**Use this instead of:** SUPABASE_COMPLETE_SETUP.sql (for existing databases)
