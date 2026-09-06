# 🚀 Cara Menjalankan EVENTTY Flutter App

## 📍 Lokasi Project
```
c:\Users\Lenovo V14\Desktop\FAQIH UJIAN\faqih\coba\hahay\EVENTTY
```

## ⚠️ Masalah Umum
**Error: "No pubspec.yaml file found"**
- **Penyebab**: Anda berada di folder yang salah
- **Solusi**: Masuk ke folder EVENTTY terlebih dahulu

---

## ✅ Cara Menjalankan Aplikasi

### 1️⃣ Buka Terminal PowerShell
- Tekan `Win + X` → Pilih "Windows PowerShell"
- ATAU klik kanan di folder → "Open in Terminal"

### 2️⃣ Masuk ke Folder EVENTTY
```powershell
cd "c:\Users\Lenovo V14\Desktop\FAQIH UJIAN\faqih\coba\hahay\EVENTTY"
```

### 3️⃣ Cek Lokasi Anda (Opsional)
```powershell
# Pastikan Anda di folder EVENTTY
pwd

# Harus menampilkan:
# Path: C:\Users\Lenovo V14\Desktop\FAQIH UJIAN\faqih\coba\hahay\EVENTTY
```

### 4️⃣ Install Dependencies (Pertama Kali)
```powershell
flutter pub get
```

### 5️⃣ Jalankan Aplikasi

#### 🌐 **Untuk Web (Chrome) - RECOMMENDED**
```powershell
flutter run -d chrome
```

#### 🖥️ **Untuk Windows Desktop**
```powershell
flutter run -d windows
```

#### 📱 **Untuk Android (jika ada emulator)**
```powershell
flutter run -d android
```

---

## 🎯 Shortcut Saat Aplikasi Running

Setelah aplikasi berjalan, Anda bisa gunakan:
- `r` → Hot Reload (update perubahan code tanpa restart)
- `R` → Hot Restart (restart aplikasi)
- `q` → Quit (tutup aplikasi)
- `h` → Help (lihat semua perintah)

---

## 🐛 Troubleshooting

### Problem 1: "No devices found"
**Solusi:**
```powershell
# Lihat daftar devices yang tersedia
flutter devices

# Jika Chrome tidak muncul, enable web support:
flutter config --enable-web
```

### Problem 2: Build Error / Dependency Issues
**Solusi:**
```powershell
# Clean project
flutter clean

# Get dependencies lagi
flutter pub get

# Run lagi
flutter run -d chrome
```

### Problem 3: Cache Issues
**Solusi:**
```powershell
# Clean Flutter cache
flutter clean

# Clean pub cache
flutter pub cache clean

# Get dependencies
flutter pub get
```

---

## 📊 Status Aplikasi

### ✅ Fitur yang Sudah Selesai:
1. ✅ Authentication (Login/Register)
2. ✅ Home Screen dengan nama user dinamis
3. ✅ Event List & Detail
4. ✅ Certificate Page dengan:
   - 🏆 3D Trophy illustration di header
   - 📑 3 Tab filters (Semua/Sertifikat Event/Sertifikat Prestasi)
   - 📜 Certificate thumbnail preview
   - ⬇️ Download button
   - ✓ Status badge
5. ✅ Profile Management
6. ✅ Admin Dashboard

### ⏳ Yang Perlu Dilakukan:
1. ⏳ Run SQL script `DATABASE_SETUP.sql` di Supabase
2. ⏳ Run SQL script `UPDATE_EVENT_IMAGES.sql` di Supabase
3. ⏳ Test certificate page di aplikasi

---

## 🔗 Supabase Setup

### Database URL:
```
https://chvztiukndxgguprufza.supabase.co
```

### Cara Run SQL Scripts:
1. Buka: https://supabase.com/dashboard/project/chvztiukndxgguprufza/sql
2. Copy isi file `DATABASE_SETUP.sql`
3. Paste di SQL Editor
4. Klik "Run"
5. Ulangi untuk `UPDATE_EVENT_IMAGES.sql`

### Test Users:
- **Student**: NIS: `12345`, Password: `indonesia`
- **Admin**: NIS: `00000`, Password: `indonesia`

---

## 📞 Need Help?

Jika masih ada masalah:
1. Pastikan Flutter sudah terinstall: `flutter doctor`
2. Pastikan berada di folder EVENTTY
3. Cek file `.env` sudah ada dan benar
4. Restart terminal jika perlu

---

**Last Updated:** September 6, 2026
**Project:** EVENTTY - OSIS Event Management System
