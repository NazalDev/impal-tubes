**DOKUMEN TEST CASE & METRIK PENGUJIAN**

*Modul: Login, Register, dan Kalender \- Aplikasi Volync*

Metode Pengujian: Black-Box Testing  
**Nazal Putra Pindha Dharmawara**  
**103012400080**  
**IF-48-GABUP.02**

## **1\. Test Case \- Login**

| ID | Skenario | Precondition | Data Uji | Expected Result | Actual Result | Status | Severity |
| :---: | ----- | ----- | ----- | ----- | ----- | :---: | ----- |
| LG-01 | Login dengan email & password valid | User terdaftar, di halaman Login | email: user@gmail.com, password: rahasia123 | Navigasi ke halaman utama (NavigationBarCustom) | Sesuai \- AuthSuccess memicu push ke halaman utama | **PASS** | \- |
| LG-02 | Email dikosongkan | Di halaman Login | email: "" | Muncul pesan "Email tidak boleh kosong" | Sesuai, validator menangkap field kosong | **PASS** | \- |
| LG-03 | Format email tidak valid | Di halaman Login | email: useratgmail.com | Muncul pesan "Format email tidak valid" | Sesuai, regex email menolak format ini | **PASS** | \- |
| LG-04 | Password kurang dari 6 karakter | Di halaman Login | password: 123 | Muncul pesan "Password minimal 6 karakter" | Sesuai validator panjang minimal | **PASS** | \- |
| LG-05 | Login dengan kredensial salah (ditolak server) | Akun tidak terdaftar / password salah | email & password format valid, tidak cocok | Popup pesan error dari server muncul | Sesuai \- AuthFailure memicu showPopup | **PASS** | \- |
| LG-06 | Error inline saat login gagal | Login gagal (server reject) | \- | Kotak error merah inline (\_loginError) tampil di form | Tidak pernah tampil \- variabel \_loginError tidak pernah di-set | **FAIL** | Minor |
| LG-07 | Menampilkan loading indicator | Submit login ditekan | \- | Spinner Loader() tampil selama proses autentikasi | Sesuai, state AuthLoading menampilkan Loader() | **PASS** | \- |

## **2\. Test Case \- Register (Sign Up)**

| ID | Skenario | Precondition | Data Uji | Expected Result | Actual Result | Status | Severity |
| :---: | ----- | ----- | ----- | ----- | ----- | :---: | ----- |
| RG-01 | Registrasi dengan semua data valid | Di halaman SignUp | username: budi, email: budi@gmail.com, password: budi123 | Event AuthSignUp terkirim ke sistem | Sesuai | **PASS** | \- |
| RG-02 | Username dikosongkan | Di halaman SignUp | username: "" | Muncul pesan "Username tidak boleh kosong" | Tidak ada validator untuk nameControl; form tetap dianggap valid | **FAIL** | Major |
| RG-03 | Format email tidak valid | Di halaman SignUp | email: budigmail.com | Muncul pesan "Format email tidak valid" | Sesuai | **PASS** | \- |
| RG-04 | Password kurang dari 6 karakter | Di halaman SignUp | password: abc | Muncul pesan "Panjang password minimal 6 karakter" | Sesuai | **PASS** | \- |
| RG-05 | Registrasi berhasil | Data valid & email belum terdaftar | Data lengkap & unik | Notifikasi/indikasi sukses ditampilkan sebelum pindah halaman | Navigator.pop() dipanggil langsung setelah dispatch event, tidak menunggu AuthSuccess | **FAIL** | Major |
| RG-06 | Registrasi gagal (email sudah terdaftar) | Email sudah dipakai akun lain | Email yang sudah ada di sistem | Popup error tampil di halaman SignUp | Halaman sudah ter-pop sebelum response diterima; popup berpotensi tidak tampil | **FAIL** | Critical |
| RG-07 | Tombol back membersihkan form | Isi sebagian form | Data apa saja di field | Semua controller (email, name, pass) ter-clear | Sesuai \- ketiganya di-clear() di leading icon | **PASS** | \- |

## **3\. Test Case \- Kalender**

| ID | Skenario | Precondition | Data Uji | Expected Result | Actual Result | Status | Severity |
| :---: | ----- | ----- | ----- | ----- | ----- | :---: | ----- |
| KL-01 | Membuka kalender dengan user login | User sudah login | userId valid | Loading \-\> daftar event bulan berjalan tampil | Sesuai | **PASS** | \- |
| KL-02 | Membuka kalender tanpa login | User belum login (currentUser \== null) | userId: null | Tampilkan pesan/redirect (mis. "Silakan login dahulu") | Tidak ada penanganan \- event tidak pernah di-dispatch, state tetap CalendarLoading selamanya | **FAIL** | Critical |
| KL-03 | Refresh data kalender | Halaman kalender sudah terbuka | Tekan ikon refresh | Data event ter-reload dari server | Sesuai | **PASS** | \- |
| KL-04 | Memilih hari yang memiliki event | Ada event pada tanggal tsb | Tap tanggal dengan event | List bawah terfilter menampilkan event hari itu saja | Sesuai | **PASS** | \- |
| KL-05 | Memilih hari tanpa event | Tidak ada event pada tanggal tsb | Tap tanggal kosong | Muncul teks "Tidak ada event pada hari ini" | Sesuai | **PASS** | \- |
| KL-06 | Satu hari dengan beberapa event beda status | Event pending & approved di tanggal sama | 2+ event beda status | Dot warna mengikuti prioritas (green \> teal \> yellow \> red \> grey) | Sesuai, urutan priority list diikuti dengan benar | **PASS** | \- |
| KL-07 | Event yang sudah lewat tanggal | startAt di masa lalu, status \!= finished | Event lampau | Dot berwarna abu-abu (kategori selesai) | Sesuai, isFinished mengecek startAt.isBefore(now) | **PASS** | \- |
| KL-08 | Navigasi ganti bulan | Di halaman kalender | Tekan panah kiri/kanan bulan | Kalender pindah bulan, event ikut terfilter | Sesuai \- onMonthChanged mengubah \_focusedMonth | **PASS** | \- |
| KL-09 | Tap salah satu event untuk lihat detail | Ada event pada list | Tap kartu event | Bottom sheet detail event terbuka | Sesuai \- \_openDetail memanggil showModalBottomSheet | **PASS** | \- |

## **4\. Rekap Metrik Pengujian**

| Metrik | Login | Register | Kalender | Total |
| ----- | :---: | :---: | :---: | :---: |
| **Total Test Case** | 7 | 7 | 9 | **23** |
| **Pass** | 6 | 4 | 8 | **18** |
| **Fail** | 1 | 3 | 1 | **5** |
| **Pass Rate** | 85.7% | 57.1% | 88.9% | **78.3%** |
| **Fail Rate** | 14.3% | 42.9% | 11.1% | **21.7%** |
| **Defect Count** | 1 | 3 | 1 | **5** |

**Defect Density (Sederhana)**

Formula: Defect Count / Total Test Case \= 5 / 23 \= 0.22 defect per test case.

**Distribusi Severity Defect**

| Severity | Jumlah | ID Defect |
| ----- | :---: | ----- |
| **Critical** | 2 | RG-06, KL-02 |
| **Major** | 2 | RG-02, RG-05 |
| **Minor** | 1 | LG-06 |

**Ringkasan Defect yang Ditemukan**

1\. LG-06 \- \_loginError adalah dead code, tidak pernah tampil ke user (Minor).

2\. RG-02 \- Username tidak divalidasi, form bisa disubmit meski username kosong (Major).

3\. RG-05 \- Halaman register menutup diri (pop) sebelum mengetahui hasil sign up sukses/gagal (Major).

4\. RG-06 \- Popup error gagal register berpotensi tidak tampil karena halaman sudah ditutup lebih dulu (Critical).

5\. KL-02 \- Tidak ada fallback UI ketika user belum login saat membuka halaman kalender, spinner loading tidak pernah berhenti (Critical).

## **5\. Analisis Hasil Pengujian**

Dari 23 test case yang dijalankan pada modul Login, Register, dan Kalender, ditemukan 5 defect dengan pass rate keseluruhan 78,3% dan fail rate 21,7%. Berikut analisisnya.

**1\. Fitur yang paling banyak gagal**

Modul Register (Sign Up) adalah yang paling bermasalah, dengan 3 dari 7 test case gagal (fail rate 42,9%) \- jauh di atas Login (14,3%) dan Kalender (11,1%). Dari sisi jumlah defect absolut, Register dan lainnya sama-sama menyumbang, tapi dari segi rasio kegagalan terhadap jumlah pengujian, Register paling buruk. Dari sisi severity, Kalender (KL-02) dan Register (RG-06) sama-sama menyumbang defect Critical, jadi keduanya butuh perhatian tinggi meski Register unggul dalam jumlah kasus gagal.

**2\. Penyebab kegagalan**

Akar masalahnya bukan satu bug acak, melainkan pola yang berulang: kurangnya validasi input (RG-02: username tidak divalidasi) dan penanganan alur asinkron yang tidak lengkap (RG-05, RG-06: halaman ditutup sebelum menunggu hasil dari server; KL-02: tidak ada fallback saat state prasyarat \- user belum login \- tidak terpenuhi). Ini menunjukkan pengembang cenderung fokus pada "happy path" (kondisi ideal), tapi lupa menangani state gagal, kosong, atau tidak terduga. LG-06 sedikit berbeda sifatnya \- itu dead code (variabel dideklarasikan tapi tidak pernah dipakai), indikasi refactoring yang tidak tuntas.

**3\. Cara memperbaikinya**

Register: tambahkan validator wajib isi pada nameControl; ubah logika navigasi agar Navigator.pop()/pindah halaman baru terjadi setelah menerima state AuthSuccess, bukan langsung setelah dispatch event. Tambahkan juga listener untuk AuthSuccess di halaman SignUp (sekarang hanya ada listener untuk AuthFailure).

Kalender: tambahkan pengecekan userId \== null di awal \_loadCalendar, lalu emit state khusus (mis. CalendarUnauthenticated) yang menampilkan pesan/redirect, bukan membiarkan state CalendarLoading menggantung.

Login: hapus \_loginError yang tidak terpakai, atau implementasikan penggunaannya secara konsisten dengan showPopup.

**4\. Prioritas perbaikan**

Urutkan berdasarkan severity dan dampak ke pengalaman pengguna:

1\. RG-06 (Critical) \- user bisa gagal mendaftar tanpa tahu alasannya.

2\. KL-02 (Critical) \- aplikasi bisa "macet" (infinite loading) untuk user yang belum login.

3\. RG-05 (Major) \- alur sukses register tidak memberi feedback jelas.

4\. RG-02 (Major) \- data tidak lengkap bisa lolos ke database.

5\. LG-06 (Minor) \- bisa ditunda, tidak mengganggu fungsi inti.

**5\. Kelayakan rilis minggu ini**

Belum layak dirilis dalam kondisi saat ini. Dua defect Critical (RG-06 dan KL-02) langsung berdampak pada fungsi inti \- pendaftaran akun dan akses kalender bagi user tanpa sesi aktif \- dan berpotensi membuat user baru gagal masuk ke aplikasi sejak awal (first impression rusak), atau membuat aplikasi terlihat hang. Idealnya, minimal kedua defect Critical dan dua defect Major diperbaiki serta di-retest dulu sebelum rilis; defect Minor (LG-06) bisa dijadwalkan untuk rilis berikutnya (patch) tanpa menahan jadwal.
