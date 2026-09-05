# 📦 Panduan Build APK - EVENTTY App

**Cara build APK untuk Android dari Flutter project**

---

## ⚡ **QUICK BUILD (Paling Mudah)**

### **Build Debug APK (Untuk Testing)**

```bash
# Di terminal VS Code:
flutter build apk --debug
```

**Output:** 
- File APK: `build\app\outputs\flutter-apk\app-debug.apk`
- Ukuran: ~50-100 MB
- Waktu: ~2-3 menit

**Install ke HP:**
1. Copy file APK ke HP via USB/WhatsApp
2. Install APK (allow "Unknown Sources" jika ditanya)
3. Done! ✅

---

## 🚀 **RELEASE APK (Optimal & Kecil)**

### **Step 1: Buat Keystore (Satu Kali Saja)**

Keystore digunakan untuk "sign" APK Anda. Buat sekali, simpan selamanya!

```bash
# Di terminal VS Code:
keytool -genkey -v -keystore c:\Projects\EVENTTY\eventty-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias eventty
```

**Anda akan ditanya:**
```
Enter keystore password: [BUAT PASSWORD - INGAT INI!]
Re-enter new password: [ULANGI PASSWORD]
What is your first and last name? [Nama Anda]
What is the name of your organizational unit? [SMKN 20 atau kosongkan]
What is the name of your organization? [SMKN 20 atau kosongkan]
What is the name of your City or Locality? [Jakarta atau kota Anda]
What is the name of your State or Province? [DKI Jakarta atau provinsi Anda]
What is the two-letter country code for this unit? [ID]
Is CN=..., correct? [yes]
```

⚠️ **PENTING:** Simpan password dan file `.jks` dengan aman! Kalau hilang, tidak bisa update app di Play Store!

---

### **Step 2: Buat File key.properties**

File ini berisi informasi keystore (jangan di-commit ke Git!).

**Lokasi:** `c:\Projects\EVENTTY\android\key.properties`

**Isi file:**
```properties
storePassword=PASSWORD_YANG_ANDA_BUAT
keyPassword=PASSWORD_YANG_ANDA_BUAT
keyAlias=eventty
storeFile=../eventty-release-key.jks
```

**Ganti** `PASSWORD_YANG_ANDA_BUAT` dengan password yang Anda buat di Step 1!

---

### **Step 3: Update build.gradle**

File: `android/app/build.gradle`

**Tambahkan di ATAS `android {`:**

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ... existing code
}
```

**Di dalam `android { ... }`, cari section `buildTypes` dan update:**

```gradle
buildTypes {
    release {
        signingConfig signingConfigs.release
        minifyEnabled true
        shrinkResources true
    }
}
```

**Tambahkan SEBELUM `buildTypes`:**

```gradle
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}
```

---

### **Step 4: Build Release APK**

```bash
flutter build apk --release
```

**Output:**
- File APK: `build\app\outputs\flutter-apk\app-release.apk`
- Ukuran: ~20-40 MB (jauh lebih kecil!)
- Waktu: ~5-10 menit (pertama kali lebih lama)

---

## 📱 **SPLIT APK (Per Architecture) - Recommended!**

Buat APK terpisah untuk setiap jenis processor (ukuran lebih kecil lagi):

```bash
flutter build apk --release --split-per-abi
```

**Output:** 3 APK files
- `app-armeabi-v7a-release.apk` (~15-25 MB) - HP lama (32-bit)
- `app-arm64-v8a-release.apk` (~15-25 MB) - HP modern (64-bit) ⭐ **PALING UMUM**
- `app-x86_64-release.apk` (~20-30 MB) - Emulator

**Install:** Pilih APK sesuai HP:
- **HP modern (2018+):** `arm64-v8a`
- **HP lama:** `armeabi-v7a`
- **Tidak tahu?** Install yang `arm64-v8a` dulu, kalau gagal baru coba `armeabi-v7a`

---

## 🎯 **RINGKASAN COMMAND**

### **Untuk Testing (Paling Cepat)**
```bash
flutter build apk --debug
```

### **Untuk Distribusi (Paling Optimal)**
```bash
# Pertama kali: Setup keystore dulu (lihat Step 1-3 di atas)

# Lalu build:
flutter build apk --release --split-per-abi
```

---

## 📂 **Lokasi File APK**

Setelah build selesai, APK ada di:

```
c:\Projects\EVENTTY\build\app\outputs\flutter-apk\
```

Files:
- `app-debug.apk` (jika build debug)
- `app-release.apk` (jika build release tanpa split)
- `app-arm64-v8a-release.apk` (jika build dengan split) ⭐
- `app-armeabi-v7a-release.apk` (jika build dengan split)
- `app-x86_64-release.apk` (jika build dengan split)

---

## 📲 **Cara Install APK ke HP**

### **Via USB Cable:**
1. Connect HP ke laptop via USB
2. Enable "File Transfer" di HP
3. Copy APK ke folder `Downloads` di HP
4. Buka File Manager di HP → Downloads
5. Tap APK → Install
6. Allow "Install from Unknown Sources" jika diminta

### **Via WhatsApp/Telegram:**
1. Send APK file ke diri sendiri
2. Download di HP
3. Tap file → Install

### **Via ADB (Developer):**
```bash
# Install langsung via USB debugging
adb install build\app\outputs\flutter-apk\app-release.apk
```

---

## 🛡️ **Security & Best Practices**

### **Jangan Commit ke Git:**

Update `.gitignore` agar file sensitif tidak ter-upload:

```gitignore
# Keystore & Keys (JANGAN COMMIT!)
*.jks
*.keystore
android/key.properties
android/app/release/

# APK Build
build/
*.apk
*.aab
```

### **Backup Keystore:**

⚠️ **SUPER PENTING!**
- Backup file `eventty-release-key.jks` ke tempat aman (Google Drive, USB, dll)
- Simpan password di password manager
- Kalau hilang = tidak bisa update app di Play Store selamanya!

---

## 🐛 **Troubleshooting**

### **Error: "keytool not found"**

**Solusi:**
```bash
# Cek apakah Java sudah terinstall:
java -version

# Jika belum, install Java JDK dari:
# https://www.oracle.com/java/technologies/downloads/

# Atau via Chocolatey (Windows):
choco install openjdk
```

---

### **Error: "Execution failed for task ':app:signReleaseBundle'"**

**Penyebab:** File `key.properties` tidak ditemukan atau salah isi.

**Solusi:**
1. Cek file ada di: `android\key.properties`
2. Cek isi file sudah benar (lihat Step 2)
3. Cek path `storeFile=../eventty-release-key.jks` benar

---

### **APK Ukuran Sangat Besar (>100 MB)**

**Solusi:**
```bash
# Build dengan split per ABI:
flutter build apk --release --split-per-abi

# Atau build App Bundle (untuk Play Store):
flutter build appbundle --release
```

---

### **Error saat Install di HP: "App not installed"**

**Solusi:**
1. Uninstall versi lama app (jika ada)
2. Pastikan HP punya cukup storage
3. Allow "Install from Unknown Sources" di Settings
4. Coba reboot HP

---

### **Error: "Minimum SDK version"**

**Solusi:** Edit `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        minSdkVersion 21  // Ganti jadi 21 atau 23
        targetSdkVersion 34
    }
}
```

---

## 📦 **App Bundle (Untuk Play Store)**

Jika mau upload ke Google Play Store, build AAB (bukan APK):

```bash
flutter build appbundle --release
```

**Output:** `build\app\outputs\bundle\release\app-release.aab`

AAB ukurannya lebih kecil dan Google Play Store akan otomatis generate APK optimal untuk setiap device.

---

## ✅ **Checklist Sebelum Build Release**

Pastikan semua sudah oke:

- [ ] App sudah di-test dengan `flutter run` (tidak ada error)
- [ ] File `.env` sudah ada dengan Supabase credentials
- [ ] App name dan icon sudah sesuai
- [ ] Version number sudah benar di `pubspec.yaml`
- [ ] Keystore sudah dibuat dan di-backup
- [ ] File `key.properties` sudah dibuat
- [ ] `build.gradle` sudah diupdate
- [ ] `.gitignore` sudah update (jangan commit keystore!)

---

## 🎉 **SELESAI!**

Sekarang Anda punya APK yang bisa:
- ✅ Di-install ke HP Android
- ✅ Di-share ke teman via WhatsApp/Telegram
- ✅ Di-upload ke Play Store (jika build release)

**Happy Building!** 🚀

---

## 📞 **Quick Reference**

```bash
# Debug (Testing - Cepat)
flutter build apk --debug

# Release (Optimal)
flutter build apk --release --split-per-abi

# App Bundle (Play Store)
flutter build appbundle --release

# Clean build (jika ada error)
flutter clean
flutter pub get
flutter build apk --release
```

---

**Created:** 2024-01-05  
**Version:** 1.0.0  
**Tested:** ✅ Working on Windows + Android
