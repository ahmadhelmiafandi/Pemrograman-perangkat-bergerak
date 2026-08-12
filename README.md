# Assignment 2: Serialization dan API — Task Tracker Core

Aplikasi Task Tracker Core berbasis **Flutter & Provider** yang mengimplementasikan arsitektur data **Offline-First (Jalur B: SQLite)** digabungkan dengan **Remote REST API (P05: Mock & Live Mode)** melalui **Repository Koordinator (`OfflineFirstTaskRepository`)**, penanganan error terstruktur berbasis *sealed class* `ApiError`, indikator koneksi UI real-time, serta pengujian terotomatisasi.

---

## 1. Panduan Menjalankan Aplikasi (Run Instructions)

Aplikasi dapat dijalankan dalam 2 mode:

### Mode A: Mode Mock (Default — Tanpa Server Eksternal)
Mode ini menggunakan `MockTaskApiClient` berbasis data *fixture* offline in-memory, sangat cocok untuk pengujian dan demo tanpa memerlukan koneksi internet:
```bash
# 1. Mengambil dependensi
flutter pub get

# 2. Menjalankan analisis statis
flutter analyze

# 3. Menjalankan pengujian otomatis (Unit & Widget tests)
flutter test

# 4. Menjalankan aplikasi dalam mode Mock
flutter run
```

### Mode B: Mode Live (REST API Server Nyata)
Mode ini terhubung ke backend REST API nyata menggunakan `--dart-define`:
```bash
flutter run \
  --dart-define=API_BASE_URL=https://your-server.example.com \
  --dart-define=API_TOKEN=your_token_here
```

---

## 2. Pilihan Jalur Lokal: Jalur B (SQLite Persistence)

Aplikasi ini memilih **Jalur B (SQLite Persistence)** sebagai *Local Source of Truth*:
* **Penjelasan & Alasan:** Data disimpang ke dalam database lokal SQLite (`tasks.db`) melalui `TaskDatabase` dan `LocalTaskDatasource`. Saat aplikasi dimatikan secara total (*kill app*) lalu dijalankan kembali (`flutter run`), seluruh data task (termasuk penambahan, pengeditan, penghapusan, dan toggle status) **tetap bertahan secara persisten**.
* **Pemisahan Marshaling:**
  - **SQLite (Baris Database):** Field `isCompleted` disimpan sebagai Integer (`1` untuk true, `0` untuk false) via `TaskMapper.toRow` / `fromRow`.
  - **REST API (JSON Payload):** Field `is_completed` dikirim sebagai Boolean native (`true` / `false`) via `Task.toJson` / `fromJson`.

---

## 3. Arsitektur & Pola Data Layer

Aplikasi menggunakan arsitektur **Clean Multi-Tier**:

```text
[ Presentation Layer ]  -->  TaskListScreen / TaskFormScreen (UI + Status Badge)
                                    ↓ (context.watch / context.read)
[ State Layer ]         -->  TaskProvider (ChangeNotifier + Error State)
                                    ↓ (TaskRepository Interface)
[ Repository Layer ]    -->  OfflineFirstTaskRepository (Koordinator)
                                 ↙                      ↘
[ Data Layer ]          --> LocalTaskDatasource         RemoteTaskDatasource
                            (SQLite tasks.db)         (MockTaskApiClient / HttpTaskApiClient)
```

* **Pola Repository Koordinator (`OfflineFirstTaskRepository`):**
  - **Operasi `save` & `remove`:** Selalu menulis ke SQLite lokal (*Local Source of Truth*) terlebih dahulu. Kemudian mencoba mengirim permintaan ke remote API secara *best-effort*.
  - **Ketahanan Koneksi (Offline-First):** Jika remote API mengalami kegagalan (*Network Error / 5xx*), error ditangkap secara aman tanpa merusak data SQLite lokal, aplikasi tidak crash, dan indikator koneksi di AppBar berubah menjadi `OFFLINE (SQLite)`.

---

## 4. Fitur & Penanganan Error UX

1. **Loading State:** Menampilkan `CircularProgressIndicator` saat proses I/O async berjalan.
2. **Empty State:** Menampilkan ilustrasi dan pesan saat daftar task kosong.
3. **Error UX & Manual Retry:** 
   - Kegagalan jaringan memunculkan tampilan `_ErrorView` (ikon `cloud_off`, pesan terstruktur, dan tombol **Retry** untuk memicu ulang `loadTasks()`).
   - Penanganan `ClientError (409 Conflict)` saat ID duplikat dan `NotFoundError (404)` saat task hilang.
4. **Indikator Sync Real-time:** Status koneksi ditampilkan di AppBar secara transparan:
   - 🟢 `ONLINE` (Remote API terhubung).
   - 🟧 `OFFLINE (SQLite)` (Remote terputus, data tersimpan aman di SQLite lokal).

---

## 5. Konfigurasi Lingkungan Tanpa Secret (API Config)

Aplikasi tidak menyimpan *hardcoded credential* di dalam source code. Pengaturan dibaca via `ApiConfig` (`lib/features/tasks/data/remote/api_config.dart`) menggunakan `String.fromEnvironment`. 

Template contoh variabel lingkungan dilampirkan pada file [.env.example](.env.example).

---

## 6. Bukti Verifikasi Tooling (`flutter analyze` & `flutter test`)

### Output `flutter analyze`:
```text
Analyzing tugas 1...                                            
No issues found! (ran in 5.8s)
```

### Output `flutter test`:
```text
00:00 +0: loading test/api_error_test.dart
00:01 +2: test/api_error_test.dart: sealed switch pattern menangani semua subtype ApiError
00:01 +7: test/local_task_datasource_test.dart: LocalTaskDatasource Integration Tests (FFI)
00:01 +14: test/mock_task_api_client_test.dart: MockTaskApiClient Unit Tests
00:01 +16: test/offline_first_task_repository_test.dart: OfflineFirstTaskRepository Unit Tests
00:02 +26: All tests passed!
```

---

## 7. Narasi Pemanfaatan AI (800–1200 Kata)

### 7.1 Strategi Pemanfaatan AI
Dalam pengerjaan Assignment 2 ini, AI (Antigravity Assistant) dimanfaatkan secara terstruktur sebagai rekan *pair programming* pada area arsitektur data layer dan pengujian. AI digunakan untuk mendesain pola *sealed class* `ApiError` pada Dart 3, menyusun strategi repository koordinator `OfflineFirstTaskRepository`, serta membantu memverifikasi kelengkapan unit test. Sebaliknya, logika dasar state management `ChangeNotifier`, struktur antarmuka UI Material 3, serta validasi form dikerjakan secara mandiri berdasarkan pemahaman dari modul P01–P03.

Setiap prompt yang diajukan ke AI selalu disertai konteks kode spesifik dan batasan aturan main (misalnya: tanpa menambah package pihak ketiga di luar `sqflite`, `path`, `provider`, `http`, dan `sqflite_common_ffi`).

**Contoh Prompt Konkret:**
> *"Bagaimana cara merangkai `OfflineFirstTaskRepository` yang mengimplementasikan interface `TaskRepository` agar saat metode `save(Task task)` dipanggil, data selalu disimpan ke `LocalTaskDatasource` (SQLite) terlebih dahulu sebagai local source of truth, kemudian baru mencoba dikirimkan ke `RemoteTaskDatasource`? Jika remote melempar `NetworkError` atau HTTP 500, bagaimana cara menangkap error tersebut agar simpan ke SQLite lokal tetap sukses dan status `isOffline` menjadi true tanpa membuat aplikasi crash?"*

### 7.2 Keputusan Menerima dan Menolak Saran AI

Selama proses pengembangan, terdapat saran AI yang diterima dan ditolak berdasarkan pertimbangan teknis:

1. **Saran AI yang Ditolak (Format Marshaling Boolean SQLite):**
   * *Saran AI:* AI sempat menyarankan untuk mengonversi field `isCompleted` menjadi String `"true"` / `"false"` di dalam `TaskMapper.toRow` agar konsisten dengan tampilan teks.
   * *Alasan Penolakan:* Saran ini ditolak karena melanggar spesifikasi P04 dan prinsip dasar SQLite. SQLite tidak memiliki tipe boolean native, dan konvensional yang benar adalah mengonversinya ke Integer `1` (true) atau `0` (false). Menyimpan boolean sebagai String akan merusak query filter SQL `WHERE is_completed = 1` dan berpotensi menyebabkan `CastException` saat membaca kembali baris data. Oleh karena itu, mapper dipertahankan memakai `isCompleted ? 1 : 0` untuk SQLite dan boolean native `true`/`false` khusus untuk REST API JSON payload.

2. **Saran AI yang Diterima (Pola Exhaustive Switch pada Sealed Class `ApiError`):**
   * *Saran AI:* AI menyarankan penggunaan Dart 3 `sealed class` untuk hirarki `ApiError` beserta pemetaan fungsi `mapResponseToError(int status)`.
   * *Alasan Penerimaan:* Saran ini diterima karena *sealed class* menjamin keamanan tipe secara kompilasi (*compile-time safety*). Dengan *sealed class*, compiler Flutter akan memastikan bahwa seluruh kemungkinan subtype error (`NetworkError`, `ServerError`, `ClientError`, `NotFoundError`, `ParseError`) ditangani secara *exhaustive* dalam pernyataan `switch`, mencegah terjadinya bug cabang error yang terlewat pada UI.

### 7.3 Cara Verifikasi Pemahaman
Pemahaman dan kebenaran data layer diverifikasi melalui tiga tahap pengetesan yang ketat:
1. **Automated Unit Testing (`flutter test`):**
   Memastikan 26 unit test lulus 100%. Pengujian mencakup *round-trip data integrity* pada `TaskMapper` (SQLite) dan `Task.fromJson`/`toJson` (JSON REST API), pengujian headless SQLite via `sqflite_common_ffi`, pengujian hirarki `ApiError`, serta pengujian ketahanan repository koordinator saat terjadi `NetworkError`.
2. **Pengujian Manual Network Error Simulation:**
   Mengaktifkan flag `simulateNetworkError = true` pada `MockTaskApiClient`. Aplikasi diuji untuk memastikan bahwa tampilan `_ErrorView` dengan ikon `cloud_off` dan tombol **Retry** muncul dengan benar saat memuat data, serta tombol **Retry** mampu memicu kembali pemanggilan `loadTasks()`.
3. **Pengujian Persistensi Lintasi Restart (Jalur B):**
   Menambah dan mengubah task di aplikasi, menutup aplikasi secara total (*kill app*), lalu menjalankannya kembali dengan `flutter run`. Terbukti data tetap bertahan utuh di dalam file SQLite lokal `tasks.db`.

### 7.4 Penjelasan Alur Data & Alur Exception End-to-End

#### Alur Data End-to-End (UI $\rightarrow$ Provider $\rightarrow$ Repository Koordinator $\rightarrow$ Datasource):
1. **UI Layer:** Pengguna menekan tombol "Simpan" pada `TaskFormScreen`. UI memanggil `context.read<TaskProvider>().addTask(task)`.
2. **Provider Layer:** `TaskProvider` menyetir indikator loading (`_isLoading = true`), memanggil `await _repo.save(task)`, lalu menyegarkan data dengan `await loadTasks()` dan memicu `notifyListeners()`.
3. **Repository Layer:** `OfflineFirstTaskRepository` menerima objek `Task`. Pertama, repository mengeksekusi `_local.insert(task)` ke SQLite lokal. Karena SQLite adalah *Local Source of Truth*, data langsung tersimpan aman. Kedua, repository mengeksekusi `_remote.create(task)` ke REST API.
4. **Datasource Layer:** `RemoteTaskDatasource` memanggil `TaskApiClient.createTask(task)`. Jika menggunakan `MockTaskApiClient`, task dimasukkan ke list mock in-memory. Jika menggunakan `HttpTaskApiClient`, objek dikonversi ke JSON via `task.toJson()` dan dikirimkan lewat HTTP POST.

#### Alur Exception End-to-End (HTTP Status $\rightarrow$ ApiError $\rightarrow$ UI State):
1. **HTTP Level:** Saat terjadi kegagalan server (misalnya status HTTP `503` atau koneksi terputus/timeout), `HttpTaskApiClient` atau `MockTaskApiClient` menangkap respons tersebut.
2. **Error Mapping:** `mapResponseToError(503)` mengonversi status code menjadi instansi `ServerError(503)`. Jika koneksi terputus, dilempar instansi `NetworkError()`. Kedua kelas ini adalah subtype dari *sealed class* `ApiError`.
3. **Repository Handling:** `OfflineFirstTaskRepository` menangkap `on ApiError catch (_)`. Karena simpan lokal SQLite sudah berhasil terlebih dahulu, repository menetapkan flag `_isOffline = true` tanpa melempar crash exception ke atas.
4. **Provider & UI State:** `TaskProvider` menangkap exception jika ada, memperbarui properti `_error = e.message`, dan memanggil `notifyListeners()`. UI merender badge `OFFLINE (SQLite)` di AppBar atau menampilkan `_ErrorView` dengan tombol **Retry**, memungkinkan pengguna memulihkan koneksi secara manual.
