-- ============================================
-- EVENTTY - UPDATE EXISTING SUPABASE DATABASE
-- ============================================
-- Script ini untuk UPDATE database yang sudah ada
-- Aman untuk di-run berkali-kali (idempotent)
-- ============================================

-- ============================================
-- PART 1: ADD MISSING COLUMNS (IF NOT EXISTS)
-- ============================================

-- Update announcements table - add missing columns
DO $$ 
BEGIN
    -- Add category column
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'announcements' AND column_name = 'category'
    ) THEN
        ALTER TABLE public.announcements ADD COLUMN category TEXT DEFAULT 'General';
    END IF;

    -- Add priority column
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'announcements' AND column_name = 'priority'
    ) THEN
        ALTER TABLE public.announcements 
        ADD COLUMN priority TEXT DEFAULT 'medium' 
        CHECK (priority IN ('low', 'medium', 'high'));
    END IF;

    -- Add is_published column
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'announcements' AND column_name = 'is_published'
    ) THEN
        ALTER TABLE public.announcements ADD COLUMN is_published BOOLEAN DEFAULT true;
    END IF;
END $$;

-- Update news table - add is_published if missing
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'news' AND column_name = 'is_published'
    ) THEN
        ALTER TABLE public.news ADD COLUMN is_published BOOLEAN DEFAULT true;
    END IF;
END $$;

-- ============================================
-- PART 2: CREATE OR UPDATE USER VARO
-- ============================================

DO $$
DECLARE
    varo_user_id UUID;
    user_exists BOOLEAN;
BEGIN
    -- Check if user already exists
    SELECT EXISTS (
        SELECT 1 FROM auth.users WHERE email = '12345@eventty.app'
    ) INTO user_exists;

    IF NOT user_exists THEN
        -- Insert new user with password "indonesia"
        INSERT INTO auth.users (
            instance_id,
            id,
            aud,
            role,
            email,
            encrypted_password,
            email_confirmed_at,
            confirmation_sent_at,
            created_at,
            updated_at,
            raw_app_meta_data,
            raw_user_meta_data,
            is_super_admin,
            confirmation_token,
            email_change,
            email_change_token_new,
            recovery_token
        ) VALUES (
            '00000000-0000-0000-0000-000000000000',
            gen_random_uuid(),
            'authenticated',
            'authenticated',
            '12345@eventty.app',
            crypt('indonesia', gen_salt('bf')),
            NOW(),
            NOW(),
            NOW(),
            NOW(),
            '{"provider":"email","providers":["email"]}',
            '{"full_name":"Varo","role":"student"}',
            false,
            '',
            '',
            '',
            ''
        )
        RETURNING id INTO varo_user_id;

        RAISE NOTICE '✅ User Varo created with ID: %', varo_user_id;
    ELSE
        -- Get existing user ID
        SELECT id INTO varo_user_id 
        FROM auth.users 
        WHERE email = '12345@eventty.app';

        RAISE NOTICE 'ℹ️ User Varo already exists with ID: %', varo_user_id;
    END IF;

    -- Update or insert profile
    INSERT INTO public.profiles (
        id, 
        email, 
        full_name, 
        role, 
        student_id, 
        class, 
        phone
    ) VALUES (
        varo_user_id,
        '12345@eventty.app',
        'Varo',
        'student',
        '12345',
        'XII RPL 1',
        '081234567890'
    )
    ON CONFLICT (id) 
    DO UPDATE SET
        full_name = 'Varo',
        role = 'student',
        student_id = '12345',
        class = 'XII RPL 1',
        phone = '081234567890',
        updated_at = NOW();

    RAISE NOTICE '✅ Profile Varo updated successfully';
END $$;

-- ============================================
-- PART 3: INSERT/UPDATE SAMPLE EVENTS
-- ============================================

-- Delete old sample events first (if any)
DELETE FROM public.events WHERE id IN (
    '550e8400-e29b-41d4-a716-446655440001',
    '550e8400-e29b-41d4-a716-446655440002',
    '550e8400-e29b-41d4-a716-446655440003',
    '550e8400-e29b-41d4-a716-446655440004'
);

-- Insert 4 sample events
INSERT INTO public.events (
    id,
    title,
    description,
    category,
    date,
    time,
    location,
    organizer,
    capacity,
    registered,
    status,
    registration_type,
    certificate_enabled,
    certificate_type,
    image_url,
    is_featured,
    is_popular,
    is_published,
    is_registration_open,
    tags
) VALUES 
-- Event 1: Basketball Championship (Team, Winners Certificate)
(
    '550e8400-e29b-41d4-a716-446655440001',
    'SMKN 20 Basketball Championship 2024',
    'Kompetisi basket antar kelas untuk memperebutkan gelar juara dan trofi prestisius. Event ini akan menampilkan pertandingan seru dari berbagai kelas. Daftarkan timmu sekarang dan tunjukkan skill terbaik kalian! Juara 1, 2, 3 akan mendapatkan sertifikat pemenang.',
    'Sport - Basketball',
    '2024-12-15 08:00:00+07',
    '08:00 - 17:00 WIB',
    'GOR SMKN 20 Jakarta',
    'OSIS SMKN 20 Jakarta',
    80,
    0,
    'open',
    'team',
    true,
    'winners',
    'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=800',
    true,
    true,
    true,
    true,
    '["sport","basketball","competition","tournament"]'::jsonb
),

-- Event 2: Career Day 2024 (Individual, All Participants Certificate)
(
    '550e8400-e29b-41d4-a716-446655440002',
    'Career Day 2024 - Future Tech Leaders',
    'Seminar karir dengan pembicara dari perusahaan teknologi ternama seperti Google, Tokopedia, dan Gojek. Dapatkan insight tentang dunia kerja IT, tips sukses berkarir, dan networking dengan profesional. E-Certificate untuk SEMUA peserta yang hadir!',
    'Education - Career',
    '2024-12-20 09:00:00+07',
    '09:00 - 15:00 WIB',
    'Aula Utama SMKN 20',
    'OSIS & BKK SMKN 20',
    200,
    0,
    'open',
    'individual',
    true,
    'all_participants',
    'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800',
    true,
    true,
    true,
    true,
    '["career","seminar","technology","education"]'::jsonb
),

-- Event 3: AI Seminar (Individual, All Participants Certificate)
(
    '550e8400-e29b-41d4-a716-446655440003',
    'AI Seminar: Artificial Intelligence in Modern Era',
    'Seminar tentang perkembangan dan implementasi Artificial Intelligence di era modern. Pembicara expert dari industri akan membahas aplikasi AI, machine learning, dan future of technology. Cocok untuk semua siswa yang tertarik dengan teknologi. E-Certificate untuk SEMUA peserta!',
    'Technology - Seminar',
    '2025-01-10 13:00:00+07',
    '13:00 - 16:00 WIB',
    'Aula SMKN 20 Jakarta',
    'OSIS & Tim IT SMKN 20',
    150,
    0,
    'open',
    'individual',
    true,
    'all_participants',
    'https://images.unsplash.com/photo-1677442136019-21780ecad995?w=800',
    true,
    true,
    true,
    true,
    '["technology","AI","artificial-intelligence","seminar"]'::jsonb
),

-- Event 4: Coding Workshop (Individual, No Certificate)
(
    '550e8400-e29b-41d4-a716-446655440004',
    'Coding Workshop: Web Development Basics',
    'Workshop coding untuk pemula tentang dasar-dasar web development. Belajar HTML, CSS, dan JavaScript dari nol! Hands-on practice dengan mentor berpengalaman. Laptop wajib dibawa. Perfect untuk yang baru mulai belajar coding.',
    'Technology - Workshop',
    '2025-01-25 13:00:00+07',
    '13:00 - 17:00 WIB',
    'Lab Komputer SMKN 20',
    'OSIS & Tim IT SMKN 20',
    40,
    0,
    'open',
    'individual',
    false,
    'none',
    'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=800',
    true,
    false,
    true,
    true,
    '["technology","coding","web-development","workshop","programming"]'::jsonb
);

-- ============================================
-- PART 4: VERIFICATION & SUMMARY
-- ============================================

DO $$
DECLARE
    table_count INT;
    user_count INT;
    event_count INT;
    announcement_count INT;
BEGIN
    SELECT COUNT(*) INTO table_count 
    FROM information_schema.tables 
    WHERE table_schema = 'public';

    SELECT COUNT(*) INTO user_count 
    FROM public.profiles 
    WHERE email = '12345@eventty.app';

    SELECT COUNT(*) INTO event_count 
    FROM public.events;

    SELECT COUNT(*) INTO announcement_count 
    FROM public.announcements;

    RAISE NOTICE '';
    RAISE NOTICE '============================================';
    RAISE NOTICE '✅ UPDATE COMPLETE!';
    RAISE NOTICE '============================================';
    RAISE NOTICE '';
    RAISE NOTICE '📊 DATABASE STATUS:';
    RAISE NOTICE '- Tables: %', table_count;
    RAISE NOTICE '- User Varo: % (exists)', user_count;
    RAISE NOTICE '- Events: % total', event_count;
    RAISE NOTICE '- Announcements: % total', announcement_count;
    RAISE NOTICE '';
    RAISE NOTICE '👤 USER VARO:';
    RAISE NOTICE '- Email: 12345@eventty.app';
    RAISE NOTICE '- Password: indonesia';
    RAISE NOTICE '- NIS: 12345';
    RAISE NOTICE '- Kelas: XII RPL 1';
    RAISE NOTICE '';
    RAISE NOTICE '✅ Ready to test! Login dengan NIS: 12345';
    RAISE NOTICE '============================================';
    RAISE NOTICE '';
END $$;

-- Show current data
SELECT '=== USER VARO ===' as info, email, full_name, student_id as nis, class
FROM public.profiles
WHERE email = '12345@eventty.app'

UNION ALL

SELECT '=== SAMPLE EVENTS ===' as info, title, category, date::text, capacity::text
FROM public.events
WHERE id IN (
    '550e8400-e29b-41d4-a716-446655440001',
    '550e8400-e29b-41d4-a716-446655440002',
    '550e8400-e29b-41d4-a716-446655440003',
    '550e8400-e29b-41d4-a716-446655440004'
)
ORDER BY info DESC;
