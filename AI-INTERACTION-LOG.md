# AI Interaction Log — Assignment 2 Task Tracker Core

Dokumen ini mencatat log interaksi dengan AI selama pengerjaan Assignment 1 dan Assignment 2 (P04 SQLite & P05 REST API) sesuai dengan kebijakan penggunaan AI pada matakuliah Pengembangan Perangkat Bergerak.

---

## Log Interaksi 1: Perancangan Search & Filter Kombinasi (AND Logic) di TaskProvider

- **Tujuan:** Memahami dan mengimplementasikan pencarian judul (case-insensitive) dan filter ganda (status + priority) secara reaktif pada `TaskProvider`.
- **Prompt yang Digunakan:**
  > "Bagaimana cara merancang getter `filteredTasks` di `TaskProvider` (ChangeNotifier) agar pencarian kata kunci judul (case-insensitive) dan filter enum `TaskStatus` serta `TaskPriority` bekerja bersamaan menggunakan logika AND tanpa mengubah list asli `_tasks`?"
- **Ringkasan Respons AI:**
  AI menyarankan penambahan tiga private state field (`_searchQuery`, `_statusFilter`, `_priorityFilter`) di `TaskProvider`, dengan getter `filteredTasks` yang melakukan iterasi/filtering bertahap pada salinan `_tasks`, lalu membungkus hasilnya dengan `List.unmodifiable()`.
- **Perubahan yang Dipilih / Diterapkan:**
  - Menambahkan field `_searchQuery`, `_statusFilter`, `_priorityFilter`.
  - Membuat setter `setSearchQuery`, `setStatusFilter`, `setPriorityFilter`, dan `clearFilters` di mana setiap setter memanggil `notifyListeners()`.
  - Membuat getter `filteredTasks` yang memproses `_tasks` menggunakan `.where()` secara independen untuk search, status, dan priority.
- **Perubahan yang Ditolak & Alasan:**
  - AI sempat menyarankan untuk membuat list terpisah `_filteredTasks` yang selalu di-update secara fisik di dalam setiap setter.
  - **Alasan Penolakan:** Pendekatan memelihara dua list terpisah berisiko membuat data desinkronisasi. Menggunakan *computed getter* (`filteredTasks`) jauh lebih aman, declarative, dan tidak berisiko memory/state leak.
- **Verifikasi Pemahaman:**
  - *Penjelasan:* `filteredTasks` adalah getter komputasi. Ketika `_searchQuery` atau filter berubah, setter memanggil `notifyListeners()`. `TaskListScreen` yang menggunakan `context.watch<TaskProvider>()` akan ter-rebuild dan membaca `provider.filteredTasks` yang baru secara instan.
  - *Bukti:* `flutter test` lulus 100% dan UI memperbarui item daftar saat pencarian/filter diubah.

---

## Log Interaksi 2: Penanganan Rotasi Layar & Layout Responsive di TaskListScreen

- **Tujuan:** Membuat tampilan responsif tanpa overflow pada orientasi Portrait dan Landscape.
- **Prompt yang Digunakan:**
  > "Bagaimana cara terbaik mengimplementasikan layout responsif di Flutter menggunakan `LayoutBuilder` untuk membedakan mode Portrait (1 kolom list) dan Landscape (2 kolom grid) tanpa menyebabkan overflow pada item `TaskCard`?"
- **Ringkasan Respons AI:**
  AI menyarankan penggunaan `LayoutBuilder` untuk mengecek `constraints.maxWidth >= 600`. Jika lebar $\ge 600$, gunakan `GridView.builder` dengan `crossAxisCount: 2`. Jika lebih kecil, gunakan `ListView.separated`. Untuk `TaskCard`, AI menyarankan penggunaan `Wrap` atau `Column` pada chip label agar tidak overflow di layar sempit.
- **Perubahan yang Dipilih / Diterapkan:**
  - Membungkus pembentukan list di `TaskListScreen` dengan `LayoutBuilder`.
  - Mengubah struktur `TaskCard` menggunakan layout flex yang aman dan membungkus tanggal serta chip status/priority dalam `Wrap`.
- **Perubahan yang Ditolak & Alasan:**
  - AI menyarankan penggunaan `MediaQuery.of(context).orientation == Orientation.landscape`.
  - **Alasan Penolakan:** `MediaQuery.orientation` mendeteksi orientasi perangkat, bukan lebar area layout yang tersedia. Jika aplikasi dijalankan di split-screen atau tablet, orientasi landscape belum tentu memiliki lebar yang cukup untuk 2 kolom. `LayoutBuilder` berbasis `constraints.maxWidth` jauh lebih tepat secara arsitektur responsif.
- **Verifikasi Pemahaman:**
  - *Penjelasan:* `LayoutBuilder` memberikan batasan ukuran konteks parent (`BoxConstraints`). Dengan mengecek `maxWidth`, tata letak secara dinamis beralih antara `ListView` (1 kolom) dan `GridView` (2 kolom).
  - *Bukti:* `flutter analyze` bersih dan tidak terjadi overflow pada pengujian layout.

---

## Log Interaksi 3: Validasi Custom Form & Due Date di TaskFormScreen

- **Tujuan:** Mengimplementasikan validasi input judul (wajib diisi, min 3 karakter) dan due date (tidak boleh masa lalu saat mode tambah task baru).
- **Prompt yang Digunakan:**
  > "Bagaimana cara melakukan validasi tanggal `dueDate` di Flutter form agar tanggal di masa lalu ditolak saat membuat task baru, namun diizinkan saat mengedit task yang sudah ada?"
- **Ringkasan Respons AI:**
  AI memberikan contoh logika pembandingan tanggal `DateTime` tanpa mempertimbangkan jam/menit/detik (hanya komponen tahun, bulan, tanggal) dan mengaitkannya dengan flag `_isEditing`.
- **Perubahan yang Dipilih / Diterapkan:**
  - Mengimplementasikan `_validateDueDate()` yang membandingkan `DateTime(year, month, day)` pilihan pengguna dengan `DateTime(now.year, now.month, now.day)`.
  - Menampilkan pesan error secara inline di bawah `ListTile` picker tanggal serta memberikan umpan balik `SnackBar` saat `_submit()`.
- **Perubahan yang Ditolak & Alasan:**
  - AI menyarankan langsung membandingkan `_dueDate.isBefore(DateTime.now())`.
  - **Alasan Penolakan:** Membandingkan langsung dengan `DateTime.now()` akan menolak tanggal hari ini karena komponen jam/menit/detik dari `DateTime.now()` lebih besar dari waktu pilih tanggal jam 00:00. Pembandingan harus dilakukan murni pada level tanggal (`year, month, day`).
- **Verifikasi Pemahaman:**
  - *Penjelasan:* Pembentukan `DateTime(y, m, d)` menghilangkan offset waktu (jam/menit/detik), sehingga memilih tanggal hari ini dihitung valid (bukan masa lalu).
  - *Bukti:* Form menolak tanggal kemarin saat buat task baru dan menerima tanggal hari ini.

---

## Log Interaksi 4: Perancangan Data Layer SQLite & TaskMapper (P04 - Jalur B)

- **Tujuan:** Mengonversi tipe data Dart (`DateTime`, `TaskPriority` enum, `bool`) ke tipe data SQLite `Map<String, Object?>` secara eksplisit dan konsisten.
- **Prompt yang Digunakan:**
  > "Bagaimana cara merancang `TaskMapper.toRow` dan `TaskMapper.fromRow` di SQLite agar tipe boolean `isCompleted` disimpan sebagai Integer 0/1, `priority` sebagai String nama enum, dan `dueDate` sebagai ISO-8601 string tanpa ada kehilangan data (*lossless round-trip*)?"
- **Ringkasan Respons AI:**
  AI menyarankan penggunaan `toIso8601String()` dan `DateTime.parse()` untuk tanggal, `.name` dan `byName()` untuk enum, serta operator kondisi `isCompleted ? 1 : 0` dan `(row[...] as int) != 0` untuk boolean.
- **Perubahan yang Dipilih / Diterapkan:**
  - Membuat `TaskMapper` dengan `toRow` dan `fromRow` sesuai saran AI.
  - Menulis `task_mapper_test.dart` untuk memverifikasi *round-trip data integrity*.
- **Perubahan yang Ditolak & Alasan:**
  - AI sempat menyarankan untuk mengonversi `isCompleted` menjadi String `'true'` / `'false'`.
  - **Alasan Penolakan:** SQLite tidak memiliki tipe boolean native. Menyimpan boolean sebagai String akan merusak query SQL `WHERE is_completed = 1` dan menyebabkan error parsing tipe. Integer 0/1 adalah standar konvensi SQLite.
- **Verifikasi Pemahaman:**
  - *Penjelasan:* `toRow` memetakan tipe Dart ke representasi SQLite; `fromRow` mengembalikan ke objek `Task`. Pemrosesan integer 0/1 konsisten di kedua arah.
  - *Bukti:* `flutter test test/task_mapper_test.dart` dan `flutter test test/local_task_datasource_test.dart` lulus 100%.

---

## Log Interaksi 5: Perancangan Repository Koordinator Offline-First (Assignment 2)

- **Tujuan:** Merangkai `OfflineFirstTaskRepository` yang menggabungkan SQLite (Local Source of Truth) dan REST API / Mock RemoteDatasource tanpa crash saat offline.
- **Prompt yang Digunakan:**
  > "Bagaimana cara merancang `OfflineFirstTaskRepository` agar saat `save(Task task)` dipanggil, data selalu disimpan ke SQLite lokal terlebih dahulu, lalu dikirim ke REST API? Jika REST API melempar `NetworkError` atau HTTP 500, bagaimana menagkapnya agar simpan lokal tetap sukses dan status `isOffline` bernilai true?"
- **Ringkasan Respons AI:**
  AI menyarankan alur eksekusi sekuensial: simpan lokal (SQLite) $\rightarrow$ try kirim remote $\rightarrow$ catch `ApiError` / `Exception` $\rightarrow$ set `_isOffline = true` tanpa melempar exception ke UI.
- **Perubahan yang Dipilih / Diterapkan:**
  - Membuat `OfflineFirstTaskRepository` dengan pola sekuensial tersebut.
  - Menambahkan chip indikator status sync `ONLINE` / `OFFLINE (SQLite)` di AppBar `TaskListScreen`.
  - Menulis unit test `test/offline_first_task_repository_test.dart`.
- **Perubahan yang Ditolak & Alasan:**
  - AI sempat menyarankan pemanggilan auto-retry terus menerus dalam loop tanpa batas saat remote gagal.
  - **Alasan Penolakan:** Auto-retry tanpa batas boros daya dan membebani thread. Spesifikasi Assignment 2 mewajibkan *manual retry* yang dipicu secara eksplisit oleh pengguna melalui tombol **Retry** atau pull-to-refresh.
- **Verifikasi Pemahaman:**
  - *Penjelasan:* Karena SQLite adalah *Local Source of Truth*, penulisan lokal menjamin data tersimpan persisten. Error remote yang ditangkap mencegah aplikasi crash dan mengabarkan status offline ke UI secara transparan.
  - *Bukti:* Unit test `offline_first_task_repository_test.dart` lulus 100% dan simulasi network error berjalan aman tanpa crash.
