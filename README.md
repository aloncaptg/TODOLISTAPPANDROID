# 🚀 TugasKu Pro - Enterprise Task Management (Flutter)

Aplikasi **Todo List & Task Management** kelas komersial/enterprise (kombinasi fitur Todoist dan Trello) berbasis **Flutter** untuk Android dan iOS. Dibangun menggunakan arsitektur **Feature-First / Clean Architecture**, didukung desain modern **Material Design 3** (Light & Dark Mode), serta sistem persistensi lokal cepat dan persisten menggunakan **SQLite (`sqflite`)** dan **`shared_preferences`**.

---

## 🌟 Alur & Fitur Utama Aplikasi

### 1. 🎬 Splash Screen & Otentikasi
- **Splash Screen:** Pembuka aplikasi elegan dengan logo, animasi skala (*scale & fade*), dan transisi halus ke halaman utama.
- **Onboarding / Authentication Simulator:** Layar login lokal untuk menyimpan profil nama pengguna, email, jabatan/peran, pilihan avatar emoji, serta opsi **Guest Mode** instan.

### 2. 🗂️ Dual-View Task Management
- **List View ([`task_list_screen.dart`](lib/features/tasks/screens/task_list_screen.dart)):**
  - Tampilan daftar tugas harian lengkap dengan badge kategori, prioritas, deadline, dan indikator sematan (*pinned*).
  - **Dual Swipe Actions:**
    - **Geser Kanan:** Tandai tugas selesai atau aktifkan kembali secara cepat (*toggle completion*).
    - **Geser Kiri:** Hapus tugas dengan dialog konfirmasi & tombol *BATALKAN (Undo)* pada SnackBar.
  - **Inline Subtasks:** Checklist sub-tugas yang dapat diperluas (*expanded*) dan dicentang langsung dari kartu tanpa membuka form edit.
- **Kanban Board View ([`kanban_screen.dart`](lib/features/tasks/screens/kanban_screen.dart)):**
  - Papan kanban interaktif dengan **4 Kolom Status**:
    1. 🔘 **To Do**
    2. ⏱️ **In Progress**
    3. 🔍 **In Review**
    4. 🟢 **Done**
  - **Drag-and-Drop:** Tekan dan tahan kartu tugas untuk menyeretnya langsung antar kolom status, atau gunakan menu transisi status cepat.
- **Task Detail Sheet ([`task_detail_sheet.dart`](lib/features/tasks/screens/task_detail_sheet.dart)):**
  - Modal lembar geser untuk memeriksa catatan, mengubah status langsung via dropdown, mencentang sub-tugas, serta menambah sub-tugas baru secara instan.

### 3. 🎯 Atribut Tugas yang Lengkap
- **Judul & Deskripsi:** Catatan dan petunjuk pengerjaan.
- **Kategori / Label:** Label warna (*Sekolah*, *Coding*, *Personal*, *Kerja*, *Lainnya*).
- **Tingkat Prioritas (4 Level):** 🟢 *Low*, 🟡 *Medium*, 🟠 *High*, dan 🔴 *Urgent*.
- **Deadline (Due Date & Time):** Lengkap dengan waktu jam/menit dan badge visual ("Hari ini", "Besok", "Terlambat").
- **Sematkan Tugas (Pin):** Menyematkan tugas-tugas krusial agar selalu berada di urutan teratas.

### 4. 🔍 Pencarian, Filter, & Sorting Canggih
- Pencarian teks judul dan deskripsi secara *real-time*.
- Filter multi-dimensi berdasarkan **5 Status**, **Kategori**, dan **Prioritas**.
- **7 Opsi Pengurutan (Sorting):**
  - Tenggat Waktu Terdekat / Terjauh
  - Prioritas Tertinggi (Urgent) / Terendah
  - Terbaru / Terlama Dibuat
  - Alfabetis (A - Z)

### 5. 📊 Statistik & Analitik Produktivitas ([`statistics_screen.dart`](lib/features/tasks/screens/statistics_screen.dart))
- Grafik radial persentase penyelesaian (*Completion Rate*).
- **Daily Streak Tracker:** Penghitung hari produktif beruntun.
- Kartu ringkasan 4 kolom status Kanban.
- Grafik batang distribusi prioritas dan jumlah tugas per kategori.
- Fitur pembersihan tugas selesai secara massal.

### 6. ⚙️ Pengaturan & Manajemen Data ([`settings_screen.dart`](lib/features/tasks/screens/settings_screen.dart))
- **Profil Pengguna:** Edit nama, email, jabatan, dan avatar.
- **Pilihan Tema:** *Sistem*, *Mode Terang*, dan *Mode Gelap*.
- **Export Data (JSON):** Cadangkan seluruh tugas ke format JSON di Clipboard.
- **Import Data (JSON):** Pulihkan data tugas dari teks JSON cadangan.
- **Bagikan Tugas:** Format rapi siap kirim ke WhatsApp / Email.

---

## 🏗️ Struktur Folder (Clean Architecture / Feature-First)

```text
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart           # Nama aplikasi, storage keys, & kategori
│   ├── providers/
│   │   └── theme_provider.dart          # State management tema (Dark, Light, System)
│   ├── services/
│   │   └── storage_service.dart         # SQLite (sqflite) + SharedPreferences sync & backup
│   └── theme/
│       └── app_theme.dart               # Material Design 3, palet status kanban & prioritas
├── features/
│   ├── auth/
│   │   ├── models/
│   │   │   └── user_model.dart          # Model user, profil, avatar, & guest mode
│   │   ├── providers/
│   │   │   └── auth_provider.dart       # State management sesi login & update profile
│   │   └── screens/
│   │       ├── splash_screen.dart       # Splash screen animasi
│   │       └── login_screen.dart        # Form login, avatar selector, & guest mode
│   └── tasks/
│       ├── models/
│       │   ├── subtask_model.dart       # Model checklist sub-tugas
│       │   └── task_model.dart          # Model tugas komprehensif
│       ├── providers/
│       │   └── task_provider.dart       # State management CRUD, 4 status kanban, sorting, & backup
│       ├── screens/
│       │   ├── main_navigation_screen.dart # Material 3 NavigationBar (4 tab)
│       │   ├── task_list_screen.dart    # Dual swipe list view
│       │   ├── kanban_screen.dart       # Papan 4 kolom drag-and-drop
│       │   ├── task_detail_sheet.dart   # Detail sheet & checklist subtask
│       │   ├── add_edit_task_screen.dart# Form tambah/edit tugas
│       │   ├── statistics_screen.dart   # Analitik produktivitas & streak
│       │   └── settings_screen.dart     # Pengaturan tema, profil, & backup JSON
│       └── widgets/
│           ├── dashboard_stats_card.dart# Greeting pengguna, streak, & progress bar
│           ├── filter_sort_bar.dart     # Kolom pencarian, filter status/kategori, & sorting
│           ├── task_item_card.dart      # Kartu tugas list view (dual swipe, pin, subtasks)
│           ├── kanban_column_widget.dart# Kolom kanban dengan DragTarget
│           ├── kanban_card_widget.dart  # Kartu kanban dengan menu status cepat
│           └── empty_state_widget.dart  # Ilustrasi saat daftar tugas kosong
└── main.dart                            # MultiProvider setup & SplashScreen root
```

---

## 🚀 Cara Menjalankan Aplikasi

1. Unduh seluruh dependensi:
   ```bash
   flutter pub get
   ```

2. Jalankan analisis kode dan tes:
   ```bash
   flutter analyze
   flutter test
   ```

3. Jalankan aplikasi:
   ```bash
   flutter run
   ```

---

## 🐙 Panduan Git & Deploy ke GitHub

Jalankan perintah berikut di terminal PowerShell:

```powershell
# 1. Pastikan Anda berada di direktori proyek
cd "c:\Users\ATTAR\Documents\ANDROID APP"

# 2. Atur identitas Git jika belum disetel
git config user.name "Nama Anda"
git config user.email "email-anda@example.com"

# 3. Stage seluruh file dan commit dengan pesan konvensi
git add .
git commit -m "feat: initial production-ready enterprise task management app"

# 4. Hubungkan remote repository GitHub (ganti dengan URL repository Anda)
git remote add origin https://github.com/USERNAME/NAMA-REPO.git

# 5. Push ke GitHub branch main
git branch -M main
git push -u origin main
```
