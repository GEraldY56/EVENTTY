# EVENTTY - Event Management System

> 🎯 Sistem Manajemen Event OSIS untuk Siswa SMK/SMA

## 📋 Deskripsi

EVENTTY adalah aplikasi manajemen event berbasis Flutter yang memungkinkan siswa untuk:
- Melihat dan mendaftar event OSIS
- Mengikuti event dengan mudah
- Mendapatkan sertifikat digital
- Berkomunikasi dengan admin OSIS
- Melihat galeri dan dokumentasi event

Admin dapat:
- Membuat dan mengelola event
- Mengelola pendaftaran peserta
- Generate sertifikat otomatis
- Mengirim announcement dan notifikasi
- Melihat laporan dan statistik

## 🛠️ Tech Stack

- **Frontend:** Flutter 3.x
- **Backend:** Supabase (PostgreSQL + Auth + Storage + Realtime)
- **State Management:** Riverpod
- **Routing:** GoRouter
- **UI:** Material Design 3 with Dark Mode support

## 📁 Struktur Project

```
EVENTTY/
├── lib/
│   ├── core/
│   │   ├── config/          # Konfigurasi (Supabase, Theme)
│   │   ├── constants/       # Konstanta (Colors, Strings, Spacing)
│   │   ├── models/          # Data models
│   │   ├── routes/          # App routing
│   │   ├── services/        # Business logic services
│   │   └── theme/           # Theme configuration
│   ├── features/
│   │   ├── authentication/  # Login, Register, Forgot Password
│   │   ├── student/         # Student features (Home, Events, Profile, etc)
│   │   ├── admin/           # Admin features (Dashboard, Management, etc)
│   │   └── shared/          # Shared features (Profile, Settings)
│   └── main.dart
├── database/
│   ├── EVENTTY_DATABASE_SCHEMA.sql    # Database schema lengkap
│   ├── EVENTTY_SEED_DATA.sql          # Data dummy untuk testing
│   └── NOTIFICATION_RLS_FIXES.sql     # RLS policy fixes
├── assets/
│   ├── images/
│   └── icons/
└── README.md
```

## 🚀 Setup & Installation

### Prerequisites

- Flutter SDK 3.24.0 atau lebih baru
- Dart SDK 3.5.0 atau lebih baru
- Akun Supabase
- Android Studio / VS Code dengan Flutter extension

### 1. Clone Repository

```bash
git clone <repository-url>
cd EVENTTY
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Setup Supabase

1. Buat project baru di [Supabase](https://supabase.com)
2. Jalankan schema database:
   - Buka SQL Editor di Supabase Dashboard
   - Copy dan jalankan `database/EVENTTY_DATABASE_SCHEMA.sql`
3. (Optional) Insert data dummy:
   - Jalankan `database/EVENTTY_SEED_DATA.sql`
4. Apply RLS fixes:
   - Jalankan `database/NOTIFICATION_RLS_FIXES.sql`

### 4. Konfigurasi Environment

Buat file `.env` di root project:

```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

### 5. Run Application

```bash
flutter run
```

## 👥 User Credentials (Seed Data)

### Admin
- **NIS:** 00001
- **Password:** admin123

### Student
- **NIS:** 12345
- **Password:** student123

## 🎨 Features

### Student Features
- ✅ Home Dashboard dengan event terbaru
- ✅ Daftar Event dengan filter kategori
- ✅ Detail Event dan Pendaftaran
- ✅ My Events (event yang diikuti)
- ✅ Calendar Event
- ✅ News & Announcements
- ✅ Messages (Chat dengan Admin OSIS)
- ✅ Gallery & Documentation
- ✅ Certificate (Sertifikat Digital)
- ✅ Profile Management
- ✅ Bookmarks
- ✅ Notifications
- ✅ Dark Mode

### Admin Features
- ✅ Dashboard dengan statistik
- ✅ Event Management (Create, Edit, Delete)
- ✅ Participant Management
- ✅ Certificate Generation
- ✅ Announcement Management
- ✅ Messages (Reply ke Student)
- ✅ Gallery Management
- ✅ Reports & Analytics
- ✅ Profile Management
- ✅ Dark Mode

## 📊 Database Schema

Database menggunakan PostgreSQL (Supabase) dengan tabel utama:
- `profiles` - User profiles (student & admin)
- `events` - Event data
- `registrations` - Pendaftaran event (individual & team)
- `participants` - Peserta final event
- `certificates` - Sertifikat digital
- `announcements` - Pengumuman
- `messages` - Chat antara student & admin
- `notifications` - Notifikasi sistem
- `bookmarks` - Bookmark event
- `gallery_images` - Galeri foto event

Detail schema lengkap ada di `database/EVENTTY_DATABASE_SCHEMA.sql`

## 🔐 Authentication

Authentication menggunakan Supabase Auth dengan internal email system:
- Email format: `{NIS}@eventty.local`
- Login menggunakan NIS + Password
- Register otomatis membuat profile dengan role `student`
- Admin diatur manual di database

## 🎯 Certificate System

Certificate generate otomatis untuk peserta yang eligible:
- Ambil data dari `registrations` table dengan status `confirmed`
- Support individual & team registration
- Customizable certificate template
- Auto-generate certificate number

## 💬 Chat System

Chat real-time antara student & admin:
- Student dapat mengirim pesan kapan saja
- Admin membalas pada jam operasional (Senin-Jumat 06:00-15:00)
- Tidak menggunakan AI/Bot
- Support attachment dan typing indicator

## 🌙 Dark Mode

Aplikasi support Light & Dark Mode dengan:
- Adaptive colors mengikuti system theme
- Toggle manual di Settings
- Persistent state menggunakan SharedPreferences
- Smooth transition tanpa rebuild

## 🐛 Known Issues & Fixes

### Notification RLS Issue
**Problem:** Admin tidak bisa INSERT notification untuk student

**Solution:** Gunakan inline role check di RLS policy
```sql
-- See database/NOTIFICATION_RLS_FIXES.sql for complete solution
```

### Navigation Error di News/Announcement Screen
**Problem:** Error `!_debugLocked` saat klik back button

**Solution:** Remove manual back button, biarkan shell navigation handle

## 📝 Development Notes

- State management menggunakan Riverpod
- Routing menggunakan GoRouter dengan ShellRoute untuk bottom navigation
- Theme management dengan ThemeService
- All services menggunakan Supabase client
- Image handling menggunakan Supabase Storage
- Real-time updates menggunakan Supabase Realtime

## 🤝 Contributing

Project ini dikembangkan untuk keperluan akademik. Untuk kontribusi atau pertanyaan, silakan hubungi maintainer.

## 📄 License

[Specify license here]

## 👨‍💻 Author

Developed by [Your Name]

---

**Last Updated:** September 13, 2026
