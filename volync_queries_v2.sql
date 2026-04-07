-- ============================================================
-- VOLYNC DATABASE - Query Collection
-- SELECT | INSERT | UPDATE
-- 10 Data per Tabel
-- Tabel: event, registration, postdisc, replydisc
-- ============================================================


-- ============================================================
-- [1] TABEL: event
-- ============================================================

-- ── INSERT 10 Data Event ────────────────────────────────────
INSERT INTO event (user_id, title, description, location, start_at, end_at, status) VALUES
  ('31b2e5f8-9b46-4ed8-8a8d-a8aadc4baecb', 'Workshop AI & Machine Learning',   'Pelatihan dasar kecerdasan buatan',         'Jakarta Selatan',  '2025-08-01 09:00:00', '2025-08-01 17:00:00', 'published'),
  ('3bf991a3-1d09-4eb9-b87a-90ab5fc92d6d', 'Seminar Kewirausahaan Muda',        'Inspirasi bisnis dari pengusaha sukses',     'Bandung',          '2025-08-05 08:00:00', '2025-08-05 15:00:00', 'published'),
  ('4d18536d-7887-4783-8904-f0461991f7a8', 'Hackathon Nasional 2025',           'Kompetisi coding 24 jam',                   'Surabaya',         '2025-08-10 07:00:00', '2025-08-11 07:00:00', 'published'),
  ('6092c6b9-860a-45ac-aec0-b8f677626c8b', 'Webinar Desain UI/UX',              'Tren desain antarmuka modern',              'Online',           '2025-08-12 13:00:00', '2025-08-12 16:00:00', 'draft'),
  ('645828c9-cbbb-489f-b57c-6240c1dbf0ee', 'Konferensi Teknologi Hijau',        'Inovasi energi terbarukan',                 'Yogyakarta',       '2025-08-15 08:00:00', '2025-08-16 17:00:00', 'published'),
  ('c8f14bfd-5d82-4ed8-851b-e88d4216352c', 'Festival Musik & Seni',             'Pertunjukan seni dan budaya lokal',         'Bali',             '2025-08-20 16:00:00', '2025-08-20 22:00:00', 'published'),
  ('cf2732f2-b01a-454e-8bfb-53ea22b93b60', 'Pameran Startup Indonesia',         'Showcase produk startup terbaik',           'Jakarta Pusat',    '2025-08-22 09:00:00', '2025-08-23 18:00:00', 'draft'),
  ('d21c857c-53aa-413d-a3f5-97d9aa5fab79', 'Pelatihan Public Speaking',         'Teknik berbicara di depan umum',            'Semarang',         '2025-08-25 09:00:00', '2025-08-25 15:00:00', 'published'),
  ('e7a2c082-2607-4fde-a127-efceee684fb9', 'Bootcamp Web Development',          'Full-stack web dev intensif 3 hari',        'Malang',           '2025-09-01 08:00:00', '2025-09-03 17:00:00', 'published'),
  ('f646e105-7817-41e0-a95b-53b77b95abb9', 'Forum Diskusi Pendidikan Digital',  'Strategi transformasi pendidikan 4.0',      'Medan',            '2025-09-05 09:00:00', '2025-09-05 16:00:00', 'cancelled');

-- ── SELECT Event ────────────────────────────────────────────
-- Semua event
SELECT * FROM event;

-- Event berstatus published, diurutkan berdasarkan tanggal
SELECT id, title, location, start_at, end_at, status
FROM event
WHERE status = 'published'
ORDER BY start_at ASC;

-- Event yang akan datang
SELECT id, title, location, start_at
FROM event
WHERE start_at > NOW()
ORDER BY start_at ASC;

-- Event berdasarkan user tertentu
SELECT id, title, location, status
FROM event
WHERE user_id = '31b2e5f8-9b46-4ed8-8a8d-a8aadc4baecb';

-- ── UPDATE Event ────────────────────────────────────────────
-- Ubah status dari draft menjadi published
UPDATE event
SET status     = 'published',
    updated_at = NOW()
WHERE id = 4;

-- Ubah lokasi dan deskripsi event
UPDATE event
SET location    = 'Gedung Sate, Bandung',
    description = 'Seminar eksklusif bersama 20 pembicara nasional',
    updated_at  = NOW()
WHERE id = 2;

-- Batalkan event
UPDATE event
SET status     = 'cancelled',
    updated_at = NOW()
WHERE id = 7;

-- Perpanjang waktu event
UPDATE event
SET end_at     = '2025-09-04 17:00:00',
    updated_at = NOW()
WHERE id = 9;


-- ============================================================
-- [2] TABEL: registration
-- ============================================================

-- ── INSERT 10 Data Registrasi ───────────────────────────────
INSERT INTO registration (user_id, event_id, status, notes) VALUES
  ('3bf991a3-1d09-4eb9-b87a-90ab5fc92d6d', 1,  'approved',  'Sudah konfirmasi kehadiran'),
  ('4d18536d-7887-4783-8904-f0461991f7a8', 1,  'pending',   NULL),
  ('6092c6b9-860a-45ac-aec0-b8f677626c8b', 2,  'approved',  'Peserta VIP'),
  ('645828c9-cbbb-489f-b57c-6240c1dbf0ee', 3,  'approved',  'Tim 3 orang'),
  ('c8f14bfd-5d82-4ed8-851b-e88d4216352c', 3,  'rejected',  'Kuota penuh'),
  ('cf2732f2-b01a-454e-8bfb-53ea22b93b60', 5,  'pending',   'Menunggu pembayaran'),
  ('d21c857c-53aa-413d-a3f5-97d9aa5fab79', 6,  'approved',  NULL),
  ('e7a2c082-2607-4fde-a127-efceee684fb9', 8,  'approved',  'Peserta reguler'),
  ('f646e105-7817-41e0-a95b-53b77b95abb9', 9,  'pending',   'Menunggu verifikasi'),
  ('31b2e5f8-9b46-4ed8-8a8d-a8aadc4baecb', 9,  'approved',  'Mentor sekaligus peserta');

-- ── SELECT Registrasi ────────────────────────────────────────
-- Semua registrasi
SELECT * FROM registration;

-- Registrasi berstatus approved beserta judul event
SELECT r.id, r.user_id, e.title AS judul_event, r.status, r.registered_at
FROM registration r
JOIN event e ON r.event_id = e.id
WHERE r.status = 'approved'
ORDER BY r.registered_at DESC;

-- Jumlah peserta per event
SELECT e.title, COUNT(r.id) AS total_peserta
FROM registration r
JOIN event e ON r.event_id = e.id
GROUP BY e.title
ORDER BY total_peserta DESC;

-- Registrasi berdasarkan event tertentu
SELECT r.id, r.user_id, r.status, r.notes, r.registered_at
FROM registration r
WHERE r.event_id = 9;

-- ── UPDATE Registrasi ────────────────────────────────────────
-- Setujui registrasi yang masih pending
UPDATE registration
SET status     = 'approved',
    notes      = 'Disetujui oleh admin',
    updated_at = NOW()
WHERE id = 2;

-- Tolak registrasi karena kuota penuh
UPDATE registration
SET status     = 'rejected',
    notes      = 'Kuota event telah penuh',
    updated_at = NOW()
WHERE id = 7;

-- Batalkan registrasi atas permintaan peserta
UPDATE registration
SET status     = 'cancelled',
    notes      = 'Peserta membatalkan sendiri',
    updated_at = NOW()
WHERE id = 10;

-- Update catatan registrasi
UPDATE registration
SET notes      = 'Peserta membawa tim, total 5 orang',
    updated_at = NOW()
WHERE id = 4;


-- ============================================================
-- [3] TABEL: postdisc (Post Diskusi)
-- ============================================================

-- ── INSERT 10 Data Post Diskusi ─────────────────────────────
INSERT INTO postdisc (user_id, event_id, title, body) VALUES
  ('31b2e5f8-9b46-4ed8-8a8d-a8aadc4baecb', 1,  'Tips Persiapan Workshop AI',          'Apa saja yang perlu disiapkan sebelum mengikuti workshop ini?'),
  ('3bf991a3-1d09-4eb9-b87a-90ab5fc92d6d', 1,  'Rekomendasi Tools AI untuk Pemula',   'Saya merekomendasikan Google Colab dan Kaggle untuk belajar ML.'),
  ('4d18536d-7887-4783-8904-f0461991f7a8', 2,  'Sharing Pengalaman Wirausaha',        'Perjalanan saya membangun bisnis dari nol selama 2 tahun.'),
  ('6092c6b9-860a-45ac-aec0-b8f677626c8b', 3,  'Ide Project Hackathon',               'Ada yang punya ide untuk tema smart city? Yuk diskusi!'),
  ('645828c9-cbbb-489f-b57c-6240c1dbf0ee', 3,  'Mencari Anggota Tim Hackathon',       'Butuh 1 orang backend developer untuk tim kami.'),
  ('c8f14bfd-5d82-4ed8-851b-e88d4216352c', 5,  'Tren Energi Surya di Indonesia',      'Panel surya semakin terjangkau, ini peluang besar!'),
  ('cf2732f2-b01a-454e-8bfb-53ea22b93b60', NULL,'Perkenalan Komunitas Volync',         'Halo semua! Senang bergabung di komunitas ini.'),
  ('d21c857c-53aa-413d-a3f5-97d9aa5fab79', 8,  'Teknik Mengatasi Demam Panggung',     'Berikut 5 teknik yang saya gunakan untuk tampil percaya diri.'),
  ('e7a2c082-2607-4fde-a127-efceee684fb9', 9,  'Kurikulum Bootcamp Web Dev',          'Apakah bootcamp ini cocok untuk pemula absolut?'),
  ('f646e105-7817-41e0-a95b-53b77b95abb9', 9,  'Review Pengalaman Bootcamp',          'Sudah selesai mengikuti bootcamp, ini kesan saya secara jujur.');

-- ── SELECT Post Diskusi ──────────────────────────────────────
-- Semua post diskusi
SELECT * FROM postdisc;

-- Post diskusi beserta judul event terkait
SELECT p.id, p.user_id, p.title, e.title AS judul_event, p.created_at
FROM postdisc p
LEFT JOIN event e ON p.event_id = e.id
ORDER BY p.created_at DESC;

-- Post diskusi terkait event tertentu
SELECT p.id, p.user_id, p.title, p.body
FROM postdisc p
WHERE p.event_id = 9;

-- Post umum tanpa event (komunitas)
SELECT p.id, p.user_id, p.title, p.body
FROM postdisc p
WHERE p.event_id IS NULL;

-- ── UPDATE Post Diskusi ──────────────────────────────────────
-- Edit judul dan isi post
UPDATE postdisc
SET title      = 'Tips Lengkap Persiapan Workshop AI 2025',
    body       = 'Persiapkan laptop, koneksi internet stabil, dan akun Google Colab.',
    updated_at = NOW()
WHERE id = 1;

-- Kaitkan post umum ke event tertentu
UPDATE postdisc
SET event_id   = 1,
    updated_at = NOW()
WHERE id = 7;

-- Perbaiki isi post
UPDATE postdisc
SET body       = 'Saya butuh backend developer yang menguasai Node.js atau Laravel.',
    updated_at = NOW()
WHERE id = 5;

-- Hapus relasi event dari post (jadikan post umum)
UPDATE postdisc
SET event_id   = NULL,
    updated_at = NOW()
WHERE id = 6;


-- ============================================================
-- [4] TABEL: replydisc (Reply Diskusi)
-- ============================================================

-- ── INSERT 10 Data Reply ────────────────────────────────────
INSERT INTO replydisc (post_id, user_id, body) VALUES
  (1, '3bf991a3-1d09-4eb9-b87a-90ab5fc92d6d', 'Saya sarankan install Python dan Jupyter Notebook terlebih dahulu.'),
  (1, '4d18536d-7887-4783-8904-f0461991f7a8', 'Jangan lupa bawa charger dan catatan!'),
  (2, '6092c6b9-860a-45ac-aec0-b8f677626c8b', 'Setuju! Kaggle sangat membantu untuk dataset latihan.'),
  (3, '645828c9-cbbb-489f-b57c-6240c1dbf0ee', 'Keren! Bisa ceritakan tantangan terbesar yang dihadapi?'),
  (4, 'c8f14bfd-5d82-4ed8-851b-e88d4216352c', 'Ide smart city bagus, saya tertarik untuk kolaborasi!'),
  (5, 'cf2732f2-b01a-454e-8bfb-53ea22b93b60', 'Saya bisa bergabung, skill: Node.js dan Express.'),
  (6, 'd21c857c-53aa-413d-a3f5-97d9aa5fab79', 'Di daerah saya sudah mulai banyak yang pasang panel surya.'),
  (7, 'e7a2c082-2607-4fde-a127-efceee684fb9', 'Selamat datang! Komunitas ini sangat aktif dan supportif.'),
  (8, 'f646e105-7817-41e0-a95b-53b77b95abb9', 'Terima kasih tipsnya, sangat membantu untuk presentasi besok!'),
  (9, '31b2e5f8-9b46-4ed8-8a8d-a8aadc4baecb', 'Cocok untuk pemula, mentor sangat sabar menjelaskan.');

-- ── SELECT Reply Diskusi ─────────────────────────────────────
-- Semua reply
SELECT * FROM replydisc;

-- Reply beserta judul post terkait
SELECT r.id, r.user_id, p.title AS judul_post, r.body, r.created_at
FROM replydisc r
JOIN postdisc p ON r.post_id = p.id
ORDER BY r.created_at ASC;

-- Reply berdasarkan post tertentu
SELECT r.id, r.user_id, r.body, r.created_at
FROM replydisc r
WHERE r.post_id = 1
ORDER BY r.created_at ASC;

-- Jumlah reply per post
SELECT p.title, COUNT(r.id) AS total_reply
FROM replydisc r
JOIN postdisc p ON r.post_id = p.id
GROUP BY p.title
ORDER BY total_reply DESC;

-- ── UPDATE Reply Diskusi ─────────────────────────────────────
-- Edit isi reply
UPDATE replydisc
SET body       = 'Install Python 3.11, Jupyter Notebook, dan library scikit-learn sebelum hari H.',
    updated_at = NOW()
WHERE id = 1;

-- Koreksi isi reply
UPDATE replydisc
SET body       = 'Ide smart city memang menarik, saya siap berkolaborasi dalam tim!',
    updated_at = NOW()
WHERE id = 5;

-- Tambahkan informasi ke reply yang sudah ada
UPDATE replydisc
SET body       = 'Saya bisa bergabung! Skill: Node.js, Express, dan sedikit PostgreSQL.',
    updated_at = NOW()
WHERE id = 6;

-- Perbaiki reply yang kurang lengkap
UPDATE replydisc
SET body       = 'Cocok untuk pemula absolut, mentornya sabar dan materi disusun dengan baik.',
    updated_at = NOW()
WHERE id = 10;


-- ============================================================
-- QUERY GABUNGAN (JOIN)
-- ============================================================

-- Dashboard: Semua event beserta jumlah peserta & jumlah diskusi
SELECT
  e.id,
  e.title                  AS judul_event,
  e.location               AS lokasi,
  e.status,
  COUNT(DISTINCT r.id)     AS jumlah_peserta,
  COUNT(DISTINCT p.id)     AS jumlah_diskusi
FROM event e
LEFT JOIN registration r ON r.event_id = e.id AND r.status = 'approved'
LEFT JOIN postdisc p     ON p.event_id = e.id
GROUP BY e.id, e.title, e.location, e.status
ORDER BY e.start_at ASC;

-- Detail lengkap sebuah event: post & semua reply-nya
SELECT
  e.title          AS judul_event,
  p.title          AS judul_post,
  p.body           AS isi_post,
  r.body           AS isi_reply,
  r.created_at     AS waktu_reply
FROM event e
JOIN postdisc  p ON p.event_id = e.id
JOIN replydisc r ON r.post_id  = p.id
WHERE e.id = 1
ORDER BY r.created_at ASC;
