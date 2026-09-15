-- ============================================================
-- EVENTTY SEED DATA (OPTIONAL)
-- ============================================================
-- Use this ONLY for development/testing
-- DO NOT run on production database with real data
-- ============================================================

-- ============================================================
-- SAMPLE EVENTS
-- ============================================================

INSERT INTO events (
    title,
    description,
    category,
    date,
    time,
    location,
    organizer,
    capacity,
    is_published,
    is_registration_open,
    certificate_enabled,
    certificate_type,
    registration_type,
    tags
) VALUES
(
    'Classmeet 2026',
    'Acara tahunan pertemuan seluruh siswa dengan berbagai kegiatan menarik termasuk lomba antar kelas, pertunjukan seni, dan bazar makanan.',
    'Classmeet',
    '2026-12-15 08:00:00+07',
    '08:00 - 15:00',
    'SMKN 20 Jakarta - Lapangan Utama',
    'OSIS SMKN 20 Jakarta',
    500,
    TRUE,
    TRUE,
    TRUE,
    'allParticipants',
    'individual',
    ARRAY['school-event', 'annual', 'fun']
),
(
    'Turnamen Basket Antar Kelas',
    'Kompetisi basket seru antar kelas untuk memperebutkan piala juara. Daftarkan tim kelasmu sekarang!',
    'Sports',
    '2026-11-20 09:00:00+07',
    '09:00 - 17:00',
    'SMKN 20 Jakarta - GOR',
    'OSIS SMKN 20 Jakarta',
    16, -- 16 teams max
    TRUE,
    TRUE,
    TRUE,
    'winners', -- Only winners get certificates
    'team', -- Team registration
    ARRAY['sports', 'competition', 'basketball']
),
(
    'Seminar AI & Teknologi Masa Depan',
    'Pelajari tentang perkembangan Artificial Intelligence dan bagaimana teknologi akan mengubah masa depan. Speaker: Expert dari industri tech.',
    'Seminar',
    '2026-10-10 13:00:00+07',
    '13:00 - 16:00',
    'SMKN 20 Jakarta - Auditorium',
    'OSIS SMKN 20 Jakarta',
    150,
    TRUE,
    TRUE,
    TRUE,
    'allParticipants',
    'individual',
    ARRAY['technology', 'AI', 'seminar']
),
(
    'Workshop Web Development',
    'Hands-on workshop untuk belajar membuat website modern dengan HTML, CSS, JavaScript, dan framework terkini. Laptop wajib dibawa!',
    'Workshop',
    '2026-10-25 10:00:00+07',
    '10:00 - 15:00',
    'SMKN 20 Jakarta - Lab Komputer 1',
    'OSIS SMKN 20 Jakarta',
    30, -- Limited seats
    TRUE,
    TRUE,
    TRUE,
    'allParticipants',
    'individual',
    ARRAY['workshop', 'coding', 'web-development']
),
(
    'Career Day 2026',
    'Expo karir dengan berbagai perusahaan dan universitas. Kesempatan emas untuk networking dan mencari info beasiswa!',
    'Career',
    '2026-11-05 09:00:00+07',
    '09:00 - 15:00',
    'SMKN 20 Jakarta - Aula Besar',
    'OSIS SMKN 20 Jakarta',
    300,
    TRUE,
    TRUE,
    FALSE, -- No certificate
    'none',
    'individual',
    ARRAY['career', 'university', 'scholarship']
);

-- ============================================================
-- SAMPLE CERTIFICATE TEMPLATE
-- ============================================================

INSERT INTO certificate_templates (
    name,
    description,
    layout_type,
    background_color,
    border_color,
    text_color,
    accent_color
) VALUES
(
    'Modern Certificate Template',
    'Clean and modern certificate design with gold accents',
    'modern',
    '#FFFFFF',
    '#C89B6D',
    '#1A1A1A',
    '#C89B6D'
),
(
    'Classic Certificate Template',
    'Traditional certificate design with elegant borders',
    'classic',
    '#FFF8E7',
    '#6B4F3A',
    '#2C1810',
    '#8B6F47'
);

-- ============================================================
-- SAMPLE ANNOUNCEMENT
-- ============================================================

INSERT INTO announcements (
    title,
    content,
    category,
    priority,
    author,
    author_id,
    is_pinned,
    is_published
) VALUES
(
    'Pendaftaran Classmeet 2026 Dibuka!',
    'Halo semuanya! 🎉

Pendaftaran untuk event Classmeet 2026 sudah dibuka. Jangan sampai kehabisan kuota ya!

Event ini akan berlangsung pada 15 Desember 2026 dengan berbagai kegiatan menarik:
- Lomba antar kelas
- Pertunjukan seni
- Bazar makanan
- Games dan doorprize

Segera daftar di aplikasi EVENTTY!',
    'Event',
    'high',
    'Admin OSIS',
    NULL, -- Will be filled with actual admin ID
    TRUE,
    TRUE
);

-- ============================================================
-- NOTES
-- ============================================================
-- After running this seed data:
--
-- 1. Sample events will appear in the app
-- 2. Students can test registration
-- 3. Admins can test event management
-- 4. You can test certificate generation
--
-- To remove all seed data, run:
-- DELETE FROM announcements;
-- DELETE FROM certificate_templates;
-- DELETE FROM events;
-- (This will cascade delete related data)
-- ============================================================
