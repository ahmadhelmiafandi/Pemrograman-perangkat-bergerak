# Assignment 1: Task Tracker Core

Aplikasi mobile Task Tracker Core berbasis Flutter & Provider (ChangeNotifier) yang mengimplementasikan manajemen state reaktif, operasi CRUD lengkap, pencarian dan filter ganda (AND logic), validasi form, serta tampilan responsif Material 3 (Portrait & Landscape).

---

## 1. Panduan Menjalankan Aplikasi (Run Instructions)

Pastikan lingkungan Flutter sudah siap (`flutter doctor` bersih), kemudian jalankan perintah berikut dari direktori root proyek:

```bash
# 1. Mengambil dependensi proyek
flutter pub get

# 2. Menjalankan analisis statis kode (harus bersih tanpa error/warning)
flutter analyze

# 3. Menjalankan pengujian otomatis unit & widget test
flutter test

# 4. Menjalankan aplikasi
flutter run
```

---

## 2. Fitur & Arsitektur Aplikasi

### Fitur Utama:
- **Manajemen Task (CRUD):**
  - **Create:** Menambah task baru via FAB (`FloatingActionButton`) dengan form tervalidasi.
  - **Read/Detail:** Layar detail penuh (`TaskDetailScreen`) menampilkan seluruh atribut task (judul, deskripsi, tanggal jatuh tempo, prioritas, dan status terhitung).
  - **Update:** Mengedit task yang sudah ada (form terisi otomatis), update terefleksi secara otomatis di seluruh layar.
  - **Delete:** Menghapus task dengan konfirmasi dialog modal (`AlertDialog`) atau usapan gesture (`Dismissible`).
  - **Toggle Status:** Mengubah status penyelesaian task secara instant dan *idempotent* dari card list maupun detail.
- **Search & Filter Kombinasi (AND Logic):**
  - Pencarian berdasarkan judul secara reaktif (*case-insensitive*).
  - Filter berdasarkan status (`Pending`, `Overdue`, `Completed`, `All`).
  - Filter berdasarkan prioritas (`High`, `Medium`, `Low`, `All`).
  - Ketiga filter bekerja secara simultan (logika **AND**). Hasil pencarian/filter yang kosong menampilkan UI khusus *Empty Search State*.
- **UI Responsif (Material 3):**
  - Mode **Portrait**: Tampilan 1 kolom menggunakan `ListView.separated`.
  - Mode **Landscape**: Tampilan 2 kolom secara otomatis menggunakan `GridView.builder` via `LayoutBuilder`.
  - Desain bebas *overflow* baik dalam posisi tegak maupun mendatar.
- **Validasi Form Kustom:**
  - Judul wajib diisi (tidak boleh kosong/spasi saja) dan minimal 3 karakter.
  - Tanggal jatuh tempo (*Due Date*) pada mode tambah task baru tidak boleh di masa lalu (diizinkan pada mode edit).

### Arsitektur Singkat:
Aplikasi menggunakan arsitektur *Clean Component Pattern* berbasis Flutter + Provider:
- **Domain Layer (`lib/features/tasks/domain/`):** Model immutable `Task` dan enum `TaskPriority` serta `TaskStatus` dengan logika atribut turunan `status`.
- **Provider Layer (`lib/features/tasks/presentation/providers/`):** `TaskProvider` menginduk pada `ChangeNotifier` sebagai *single source of truth*. Mengelola state data, status pencarian, dan filter.
- **Presentation Layer (`lib/features/tasks/presentation/screens/ & widgets/`):** Deklaratif UI (`TaskListScreen`, `TaskDetailScreen`, `TaskFormScreen`, `TaskCard`) yang berlangganan reaktif menggunakan `context.watch` dan mengeksekusi aksi menggunakan `context.read`.

---

## 3. Known Limitations (Batasan Aplikasi)

- State stored in-memory: Data task bersifat *in-memory* dan di-seed dengan 20 dummy tasks saat aplikasi dinyalakan. Persistence (SQLite/REST API) akan diimplementasikan pada Assignment berikutnya sesuai spesifikasi.

---

## 4. Bukti Verifikasi Tooling (`flutter analyze` & `flutter test`)

### Output `flutter analyze`:
```text
Analyzing tugas 1...                                            
No issues found! (ran in 3.5s)
```

### Output `flutter test`:
```text
00:00 +0: loading E:/ppb/tugas 1/test/task_provider_test.dart
00:00 +0: E:/ppb/tugas 1/test/task_provider_test.dart: initial state memiliki 2 task
00:00 +1: E:/ppb/tugas 1/test/task_provider_test.dart: findById mengembalikan task yang benar
00:00 +2: E:/ppb/tugas 1/test/task_provider_test.dart: TODO(student): addTask menambah task dan memanggil notifyListeners
00:00 +3: E:/ppb/tugas 1/test/task_provider_test.dart: TODO(student): updateTask mengganti task dengan id sama
00:00 +4: E:/ppb/tugas 1/test/task_provider_test.dart: TODO(student): deleteTask menghapus task
00:00 +5: E:/ppb/tugas 1/test/task_provider_test.dart: TODO(student): toggleComplete membalik isCompleted
00:00 +6: E:/ppb/tugas 1/test/widget_test.dart: app mounts, shows loading lalu list setelah seed
00:01 +7: All tests passed!
```

---

## 5. Tangkapan Layar (Screenshots & Flow Preview)

*Catatan: Tangkapan layar diambil dari pengujian UI aplikasi.*
- **Flow CRUD:** Penambahan task baru via FAB -> Pengeditan dari layar detail -> Hapus task dengan konfirmasi dialog -> Toggle status checklist.
- **Search & Filter:** Uji coba memasukkan kata kunci pada search bar dikombinasikan dengan chip filter `Status: Pending` dan `Priority: High`.
- **Responsif:** Tampilan Portrait (1 kolom list) vs Landscape (2 kolom grid) tanpa overflow.

---

## 6. Log Interaksi AI

Log interaksi terperinci per percakapan dilampirkan pada file terpisah: [AI-INTERACTION-LOG.md](AI-INTERACTION-LOG.md).

---

## 7. Narasi Pemanfaatan AI (800 – 1200 Kata)

### 7.1 Strategi Pemanfaatan AI

Dalam menyelesaikan Assignment 1 ini, saya mengadopsi strategi pemanfaatan Generative AI secara terukur dan disiplin. AI difungsikan murni sebagai *asisten konsultasi arsitektur*, *pembantu diagnosis sintaks*, dan *sparring partner* untuk mengevaluasi efisiensi struktur data. Saya secara sengaja **tidak** menggunakan AI untuk me-generate keseluruhan codebase atau menulis logika bisnis inti tanpa analisis mandiri terlebih dahulu.

Bagian aplikasi yang saya kerjakan secara mandiri meliputi:
1. Pemahaman mendalam mengenai pola immutability pada model `Task` dan metode `copyWith`.
2. Pengisian method dasar CRUD di `TaskProvider` (`addTask`, `updateTask`, `deleteTask`, `toggleComplete`) berdasarkan konsep manipulasi list immutable di Dart.
3. Desain alur navigasi aplikasi (`TaskListScreen` $\rightarrow$ `TaskDetailScreen` $\rightarrow$ `TaskFormScreen`).

Sementara itu, bantuan AI dimanfaatkan secara spesifik untuk:
1. Mengeplorasi pendekatan terbaik dalam membuat getter komputatif yang menggabungkan tiga filter sekaligus (search text, status enum, priority enum) tanpa menyebabkan *side effect* pada state utama.
2. Mempelajari penanganan batasan tata letak responsif (*responsive constraint*) Flutter menggunakan `LayoutBuilder` agar terhindar dari *RenderFlex overflow* saat diuji pada berbagai ukuran layar dan rotasi perangkat.

Untuk mendapatkan hasil yang relevan dari AI, saya menyusun prompt secara terstruktur dengan menyertakan konteks spesifik: memberikan batasan teknologi (Flutter 3.22+, Provider 6, Material 3), aturan batas yang tidak boleh dilanggar (tidak mengubah class model atau signature method starter), serta ekspektasi output berupa penjelasan konsep dan perbandingan pendekatan teknis.

**Contoh Prompt Konkret:**
> *"Saya sedang membangun fitur Search dan Filter pada aplikasi Flutter menggunakan `TaskProvider` (`ChangeNotifier`). Saya memiliki list dasar `_tasks` yang immutable. Bagaimana cara terbaik menyusun getter `filteredTasks` yang secara reaktif menyaring item berdasarkan teks judul (case-insensitive), `TaskStatus?`, dan `TaskPriority?` menggunakan logika AND? Tolong jelaskan perbandingan antara membuat computed getter vs memelihara list hasil filter terpisah di memori dari sudut pandang integritas state dan performa rebuild UI."*

---

### 7.2 Keputusan Menerima dan Menolak Saran AI

Sebagai bukti pemahaman teknis dan kontrol penuh terhadap kode aplikasi, berikut adalah dua kasus konkret pengambilan keputusan terhadap rekomendasi yang diberikan oleh AI:

#### Kasus 1: Menerima Saran Menggunakan Computed Getter untuk Filter Kombinasi
- **Saran AI:** AI merekomendasikan penggunaan *getter komputatif* (`List<Task> get filteredTasks`) yang mengevaluasi `_tasks` secara dinamis setiap kali getter diakses, alih-alih membuat variable list simpanan baru `_filteredTasks`.
- **Alasan Teknis Diterima:** Pendekatan ini menjamin *Single Source of Truth*. Dengan hanya menyimpan `_tasks` sebagai satu-satunya data utama di `TaskProvider`, tidak ada risiko ketidakcocokan data (*data desynchronization*) saat terjadi operasi CRUD. Setiap kali ada perubahan pencarian atau filter, setter hanya perlu memperbarui nilai variabel kriteria filter lalu memanggil `notifyListeners()`. Saat UI yang dipasang `context.watch<TaskProvider>()` memicu re-build, getter `filteredTasks` otomatis menghitung ulang hasil filter secara instan dan konsisten.

#### Kasus 2: Menolak Saran Penggunaan `MediaQuery` untuk Deteksi Layout Responsif
- **Saran AI:** Ketika saya berkonsultasi mengenai tata letak responsif untuk mode landscape, AI menyarankan untuk memeriksa orientasi layar menggunakan `MediaQuery.of(context).orientation == Orientation.landscape` lalu mengondisikan jumlah kolom grid.
- **Alasan Teknis Ditolak:** Saya menolak saran ini karena pemeriksaan orientasi fisik perangkat tidak mencerminkan lebar ruang render aktual yang tersedia untuk widget (*parent constraints*). Misalnya, pada perangkat lipat (*foldable*), mode *split-screen*, atau tablet, orientasi landscape tidak selalu menjamin tersedianya lebar piksel yang cukup untuk menampilkan 2 kolom grid dengan rapi. Sebaliknya, saya memilih menggunakan `LayoutBuilder` yang memeriksa `constraints.maxWidth >= 600`. Pendekatan berbasis batasan lebar piksel ini jauh lebih fleksibel, sesuai standar arsitektur responsif Flutter modern, dan terbukti mencegah bug *RenderFlex overflow*.

---

### 7.3 Cara Verifikasi Pemahaman

Untuk memastikan bahwa seluruh kode yang ditulis maupun yang dikembangkan dengan bantuan AI benar-benar valid dan saya kuasai sepenuhnya, saya menerapkan proses verifikasi tiga lapis:

1. **Verifikasi Statis & Tes Otomatis (`flutter analyze` & `flutter test`):**
   - Menjalankan `flutter analyze` secara berkala untuk memastikan tidak ada *warning*, *unused import*, atau penggunaan *deprecated API*. Hasil pengujian statis proyek saat ini menunjukkan **No issues found!**.
   - Menjalankan `flutter test` untuk memverifikasi bahwa 6 unit test inti pada `task_provider_test.dart` dan 1 widget test pada `widget_test.dart` seluruhnya lulus (**All 7 tests passed!**).

2. **Pengujian Manual di Perangkat/Emulator:**
   - Melakukan pengujian alur interaksi secara menyeluruh (*End-to-End*): membuat task baru, menguji penolakan validasi judul kosong dan tanggal di masa lalu, mengubah status task lewat checklist, memicu dialog hapus, melakukan pencarian kata kunci secara real-time, serta menguji kombinasi filter status dan prioritas.
   - Melakukan tes rotasi layar dari Portrait ke Landscape untuk memastikan state pencarian dan filter tidak hilang serta layout menyesuaikan dari 1 kolom menjadi 2 kolom grid tanpa adanya *overflow stripe*.

3. **Verifikasi Pemahaman Konseptual (Verbalisasi Mandiri):**
   - Saya memverifikasi pemahaman saya dengan menjelaskan alur data dan skenario reaktivitas tanpa melihat kode, memastikan saya dapat menelusuri bagaimana pemanggilan method di UI berdampak pada pembaruan state provider dan pemicuan re-build widget tree.

---

### 7.4 Penjelasan Alur End-to-End: Fitur Search & Filter Kombinasi (AND Logic)

Sebagai bagian dari pembuktian penguasaan materi, berikut adalah penjelasan alur kerja *End-to-End* pada fitur **Search & Filter Kombinasi** dari input pengguna hingga rendering akhir di layar:

```text
[Input Pengguna pada SearchBar / FilterChip]
                 │
                 ▼
 [Panggilan Aksi: context.read<TaskProvider>()]
                 │
                 ▼
[Mutasi State & Pemicuan: notifyListeners()]
                 │
                 ▼
  [Langganan Reaktif: context.watch<TaskProvider>()]
                 │
                 ▼
[Evaluasi Computed Getter: provider.filteredTasks]
                 │
                 ▼
    [Rebuild UI Deklaratif: TaskListScreen]
```

1. **Input Pengguna & Panggilan Aksi (`context.read`):**
   Saat pengguna mengetikkan kata kunci pada `SearchBar` atau mengetuk salah satu `FilterChip` di `TaskListScreen`, event handler (seperti `onChanged` atau `onSelected`) dipanggil. Di dalam event handler ini, aplikasi menggunakan `context.read<TaskProvider>()` untuk mengakses instance provider secara kontekstual tanpa mendaftarkan widget event handler tersebut untuk re-build. Panggilan seperti `context.read<TaskProvider>().setSearchQuery(value)` atau `setStatusFilter(status)` dieksekusi.

2. **Mutasi State Internal & Pemicuan Notification:**
   Di dalam `TaskProvider`, variabel state private (seperti `_searchQuery` atau `_statusFilter`) diperbarui dengan nilai baru. Segera setelah mutasi nilai variabel tersebut selesai, method `notifyListeners()` dipanggil. Method ini memancarkan sinyal pemberitahuan kepada seluruh objek pembaca (*listeners*) yang sedang aktif berlangganan pada instance `TaskProvider`.

3. **Langganan Reaktif & Pemicuan Rebuild (`context.watch`):**
   Pada method `build()` milik `TaskListScreen`, terdapat deklarasi `final provider = context.watch<TaskProvider>();`. Penggunaan `context.watch` menandakan bahwa `TaskListScreen` mendengarkan perubahan dari `TaskProvider`. Ketika `notifyListeners()` terpancar, Flutter menandai `TaskListScreen` sebagai widget yang "kotor" (*dirty*) dan menjadwalkan ulang eksekusi method `build()`.

4. **Kalkulasi Reaktif via Computed Getter (`filteredTasks`):**
   Saat method `build()` mengeksekusi ulang, kode membaca properti `provider.filteredTasks`. Pada titik ini, getter `filteredTasks` dievaluasi secara dinamis:
   - Mulai dari salinan list utama `_tasks`.
   - Melakukan penyaringan kata kunci judul (*case-insensitive*) jika `_searchQuery` tidak kosong.
   - Melakukan penyaringan status jika `_statusFilter` tidak null.
   - Melakukan penyaringan prioritas jika `_priorityFilter` tidak null.
   Ketiga kondisi penyaringan ini diterapkan berturut-turut (logika **AND**).

5. **Rendering UI Deklaratif & Handling Empty State:**
   Hasil dari `filteredTasks` kemudian dikirim ke `LayoutBuilder`. Jika `filteredTasks` menghasilkan list kosong, UI secara otomatis menampilkan *Empty Search State* yang dilengkapi tombol untuk membersihkan filter. Jika list berisi data, `LayoutBuilder` akan merender daftar `TaskCard` menggunakan `ListView` (mode Portrait) atau `GridView` (mode Landscape) sesuai batasan lebar layar secara instan dan lancar.
