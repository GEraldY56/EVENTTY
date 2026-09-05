# 👨‍💼 CREATE ADMIN USER

**File:** `CREATE_USER_ADMIN.sql`

---

## ⚡ CARA PAKAI (1 MENIT)

1. **Buka Supabase** → https://supabase.com/dashboard
2. **SQL Editor** → New Query
3. **Copy-paste** file `CREATE_USER_ADMIN.sql`
4. **Click Run**
5. ✅ **Done!**

---

## 🔐 ADMIN CREDENTIALS

```
╔═══════════════════════════════════╗
║        ADMIN LOGIN                ║
╠═══════════════════════════════════╣
║ Full Name : Admin EVENTTY         ║
║ NIS       : 00000                 ║
║ Password  : indonesia             ║
║ Email     : 00000@eventty.app     ║
╚═══════════════════════════════════╝
```

---

## ✅ EXPECTED OUTPUT

```
✅ ADMIN USER CREATED SUCCESSFULLY!

📧 Email    : admin@eventty.app
👤 Name     : Admin EVENTTY
🎫 NIS      : 00000
🔒 Password : indonesia
👔 Role     : admin

🔐 LOGIN DI APP:
   Full Name: Admin EVENTTY
   NIS: 00000
   Password: indonesia

✅ User ID: xxxxx-xxxxx-xxxxx

📊 VERIFICATION:
   ✅ In auth.users: 1
   ✅ In profiles: 1

🎉 SUCCESS! Admin ready to login!
```

---

## 🧪 TEST LOGIN

1. Buka app EVENTTY
2. Login dengan:
   - **Full Name:** Admin EVENTTY
   - **NIS:** 00000
   - **Password:** indonesia
3. ✅ Masuk ke Admin Dashboard

---

## 📊 VERIFY DI SUPABASE

### Check 1: Authentication Tab
- Click **Authentication** → **Users**
- Harus ada: `admin@eventty.app` ✅

### Check 2: Table Editor
- Click **Table Editor** → **profiles**
- Harus ada row dengan:
  - email: `admin@eventty.app`
  - student_id: `00000`
  - role: `admin` ✅

---

## 🐛 TROUBLESHOOTING

### Problem: User already exists
**Solution:** SQL akan delete user lama, lalu create baru

### Problem: Login failed
**Check:**
- Password harus **persis**: `indonesia` (lowercase)
- NIS harus **persis**: `00000` (5 angka nol)
- App sudah connect ke Supabase yang benar (cek .env)

---

## ✅ READY!

**NEXT:** Run SQL → Test login → Done! 🚀
