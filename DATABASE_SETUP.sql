-- ============================================
-- EVENTTY - DATABASE SETUP LENGKAP
-- ============================================
-- File ini berisi SEMUA setup database:
-- 1. Create tables & schema
-- 2. Setup RLS policies
-- 3. Create triggers & functions
-- 4. Create user Varo (Student: NIS 12345)
-- 5. Create user Admin (Admin: NIS 00000)
-- 6. Insert sample events
-- ============================================
-- 
-- CARA PAKAI:
-- 1. Buka Supabase Dashboard → SQL Editor
-- 2. Copy SEMUA isi file ini
-- 3. Paste dan Run
-- 4. Tunggu sampai selesai (~30 detik)
-- 5. Selesai! Database siap dipakai
-- 
-- ============================================
-- USERS YANG AKAN DIBUAT:
-- 
-- STUDENT (Varo):
--   Full Name: Varo
--   Email: 12345@eventty.app
--   Password: indonesia
--   NIS: 12345
--   Kelas: XII RPL 1
-- 
-- ADMIN:
--   Full Name: Admin EVENTTY
--   Email: 00000@eventty.app
--   Password: indonesia
--   NIS: 00000
-- 
-- ============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- PART 1: CREATE TABLES
-- ============================================

-- 1. PROFILES TABLE (User profiles)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('admin', 'student')),
    student_id TEXT,
    class TEXT,
    phone TEXT,
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. EVENTS TABLE
CREATE TABLE IF NOT EXISTS public.events (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    category TEXT NOT NULL,
    date TIMESTAMP WITH TIME ZONE NOT NULL,
    time TEXT NOT NULL,
    location TEXT NOT NULL,
    organizer TEXT NOT NULL,
    capacity INTEGER NOT NULL,
    registered INTEGER DEFAULT 0,
    status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'closed', 'ongoing', 'completed')),
    registration_type TEXT NOT NULL CHECK (registration_type IN ('individual', 'team')),
    certificate_enabled BOOLEAN DEFAULT false,
    certificate_type TEXT CHECK (certificate_type IN ('none', 'all_participants', 'winners')),
    minimum_attendance INTEGER,
    image_url TEXT,
    documentation JSONB DEFAULT '[]'::jsonb,
    highlights JSONB DEFAULT '[]'::jsonb,
    is_featured BOOLEAN DEFAULT false,
    is_popular BOOLEAN DEFAULT false,
    is_published BOOLEAN DEFAULT true,
    is_registration_open BOOLEAN DEFAULT true,
    tags JSONB DEFAULT '[]'::jsonb,
    registration_deadline TIMESTAMP WITH TIME ZONE,
    created_by UUID REFERENCES public.profiles(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. REGISTRATIONS TABLE
CREATE TABLE IF NOT EXISTS public.registrations (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    event_id UUID REFERENCES public.events(id) ON DELETE CASCADE NOT NULL,
    student_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    student_name TEXT NOT NULL,
    student_email TEXT NOT NULL,
    student_phone TEXT NOT NULL,
    student_class TEXT,
    registration_type TEXT NOT NULL CHECK (registration_type IN ('individual', 'team')),
    team_name TEXT,
    class_name TEXT,
    leader_id TEXT,
    leader_name TEXT,
    team_members JSONB,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'cancelled', 'confirmed', 'attended')),
    form_data JSONB,
    additional_data JSONB,
    registered_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(event_id, student_id)
);

-- 4. CERTIFICATES TABLE
CREATE TABLE IF NOT EXISTS public.certificates (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    event_id UUID REFERENCES public.events(id) ON DELETE CASCADE NOT NULL,
    event_title TEXT NOT NULL,
    event_category TEXT NOT NULL DEFAULT 'Event',
    student_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    student_name TEXT NOT NULL,
    student_nis TEXT,
    certificate_type TEXT NOT NULL CHECK (certificate_type IN ('participation', 'winner', 'speaker')),
    certificate_number TEXT UNIQUE NOT NULL,
    winner_position TEXT,
    achievement TEXT,
    template_id TEXT,
    event_date TIMESTAMP WITH TIME ZONE,
    issue_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    signed_by TEXT DEFAULT 'OSIS SMKN 20 Jakarta',
    additional_info TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. CONVERSATIONS TABLE
CREATE TABLE IF NOT EXISTS public.conversations (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    student_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    student_name TEXT NOT NULL,
    event_id UUID REFERENCES public.events(id) ON DELETE SET NULL,
    event_title TEXT,
    mode TEXT NOT NULL DEFAULT 'bot' CHECK (mode IN ('bot', 'admin')),
    last_message TEXT,
    last_message_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    unread_count INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. MESSAGES TABLE
CREATE TABLE IF NOT EXISTS public.messages (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    conversation_id UUID REFERENCES public.conversations(id) ON DELETE CASCADE NOT NULL,
    sender_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    sender_name TEXT NOT NULL,
    sender_role TEXT NOT NULL CHECK (sender_role IN ('student', 'admin', 'bot', 'system')),
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. NEWS TABLE
CREATE TABLE IF NOT EXISTS public.news (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    category TEXT NOT NULL,
    author TEXT NOT NULL,
    author_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    publish_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    image_url TEXT,
    views INTEGER DEFAULT 0,
    is_pinned BOOLEAN DEFAULT false,
    is_published BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. ANNOUNCEMENTS TABLE
CREATE TABLE IF NOT EXISTS public.announcements (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    event_id UUID REFERENCES public.events(id) ON DELETE CASCADE,
    category TEXT DEFAULT 'General',
    priority TEXT DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high')),
    author TEXT NOT NULL,
    author_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    is_pinned BOOLEAN DEFAULT false,
    is_published BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 9. BOOKMARKS TABLE
CREATE TABLE IF NOT EXISTS public.bookmarks (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    student_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    event_id UUID REFERENCES public.events(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(student_id, event_id)
);

-- ============================================
-- PART 2: ROW LEVEL SECURITY (RLS)
-- ============================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.registrations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.certificates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.news ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookmarks ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view own profile" ON public.profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = id);

-- Events policies
CREATE POLICY "Anyone can view events" ON public.events
    FOR SELECT USING (true);

-- Registrations policies
CREATE POLICY "Students can view own registrations" ON public.registrations
    FOR SELECT USING (student_id = auth.uid());

CREATE POLICY "Students can create registrations" ON public.registrations
    FOR INSERT WITH CHECK (student_id = auth.uid());

CREATE POLICY "Students can update own pending registrations" ON public.registrations
    FOR UPDATE USING (student_id = auth.uid() AND status = 'pending');

-- Certificates policies
CREATE POLICY "Students can view own certificates" ON public.certificates
    FOR SELECT USING (student_id = auth.uid());

-- Conversations policies
CREATE POLICY "Students can view own conversations" ON public.conversations
    FOR SELECT USING (student_id = auth.uid());

CREATE POLICY "Students can create own conversations" ON public.conversations
    FOR INSERT WITH CHECK (student_id = auth.uid());

-- Messages policies  
CREATE POLICY "Users can view messages in own conversations" ON public.messages
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.conversations
            WHERE id = conversation_id AND student_id = auth.uid()
        )
    );

CREATE POLICY "Users can create messages in own conversations" ON public.messages
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.conversations
            WHERE id = conversation_id AND student_id = auth.uid()
        )
    );

-- News & Announcements policies
CREATE POLICY "Anyone can view news" ON public.news
    FOR SELECT USING (true);

CREATE POLICY "Anyone can view announcements" ON public.announcements
    FOR SELECT USING (true);

-- Bookmarks policies
CREATE POLICY "Students can manage own bookmarks" ON public.bookmarks
    FOR ALL USING (student_id = auth.uid());

-- ============================================
-- PART 3: TRIGGERS & FUNCTIONS
-- ============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply triggers
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_events_updated_at BEFORE UPDATE ON public.events
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_registrations_updated_at BEFORE UPDATE ON public.registrations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_conversations_updated_at BEFORE UPDATE ON public.conversations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_news_updated_at BEFORE UPDATE ON public.news
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_announcements_updated_at BEFORE UPDATE ON public.announcements
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to auto-create profile when user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, full_name, role)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', 'User'),
        COALESCE(NEW.raw_user_meta_data->>'role', 'student')
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger on auth.users
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Function to update event registered count
CREATE OR REPLACE FUNCTION update_event_registered_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' AND NEW.status IN ('approved', 'confirmed', 'attended') THEN
        UPDATE public.events 
        SET registered = registered + 1 
        WHERE id = NEW.event_id;
    ELSIF TG_OP = 'UPDATE' THEN
        IF OLD.status NOT IN ('approved', 'confirmed', 'attended') 
           AND NEW.status IN ('approved', 'confirmed', 'attended') THEN
            UPDATE public.events 
            SET registered = registered + 1 
            WHERE id = NEW.event_id;
        ELSIF OLD.status IN ('approved', 'confirmed', 'attended') 
              AND NEW.status NOT IN ('approved', 'confirmed', 'attended') THEN
            UPDATE public.events 
            SET registered = registered - 1 
            WHERE id = NEW.event_id;
        END IF;
    ELSIF TG_OP = 'DELETE' AND OLD.status IN ('approved', 'confirmed', 'attended') THEN
        UPDATE public.events 
        SET registered = registered - 1 
        WHERE id = OLD.event_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for registration count
CREATE TRIGGER update_event_count
    AFTER INSERT OR UPDATE OR DELETE ON public.registrations
    FOR EACH ROW EXECUTE FUNCTION update_event_registered_count();

-- ============================================
-- PART 4: CREATE USER VARO (STUDENT)
-- ============================================

DO $$
DECLARE
    varo_user_id UUID;
    user_exists BOOLEAN;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '============================================';
    RAISE NOTICE '👤 Creating Student User: Varo';
    RAISE NOTICE '============================================';
    
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

        RAISE NOTICE 'ℹ️  User Varo already exists with ID: %', varo_user_id;
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

    RAISE NOTICE '✅ Profile Varo created/updated successfully';
    RAISE NOTICE '';
END $$;

-- ============================================
-- PART 5: CREATE USER ADMIN
-- ============================================

DO $$
DECLARE
    new_admin_id UUID;
    orphaned_profile_id UUID;
    cleanup_count INT := 0;
    has_trigger BOOLEAN := false;
BEGIN
    RAISE NOTICE '============================================';
    RAISE NOTICE '👤 Creating Admin User';
    RAISE NOTICE '============================================';
    RAISE NOTICE '';
    
    -- === PHASE 1: SMART CLEANUP ===
    RAISE NOTICE '📋 PHASE 1: Smart cleanup...';
    
    -- Delete admin from auth.users (if exists)
    DELETE FROM auth.users WHERE email = '00000@eventty.app' OR email = 'admin@eventty.app';
    GET DIAGNOSTICS cleanup_count = ROW_COUNT;
    IF cleanup_count > 0 THEN
        RAISE NOTICE '   🗑️  Deleted % admin from auth.users', cleanup_count;
    END IF;
    
    -- Delete admin profiles
    DELETE FROM public.profiles WHERE email = '00000@eventty.app' OR email = 'admin@eventty.app' OR student_id = '00000';
    GET DIAGNOSTICS cleanup_count = ROW_COUNT;
    IF cleanup_count > 0 THEN
        RAISE NOTICE '   🗑️  Deleted % admin profile(s)', cleanup_count;
    END IF;
    
    -- Delete orphaned profiles
    FOR orphaned_profile_id IN 
        SELECT p.id 
        FROM public.profiles p
        LEFT JOIN auth.users au ON p.id = au.id
        WHERE au.id IS NULL
    LOOP
        DELETE FROM public.profiles WHERE id = orphaned_profile_id;
        RAISE NOTICE '   🗑️  Deleted orphaned profile: %', orphaned_profile_id;
    END LOOP;
    
    RAISE NOTICE '   ✅ Cleanup complete';
    RAISE NOTICE '';
    
    -- === PHASE 2: GENERATE UNIQUE ID ===
    RAISE NOTICE '📋 PHASE 2: Generate unique ID...';
    
    new_admin_id := gen_random_uuid();
    
    WHILE EXISTS (SELECT 1 FROM auth.users WHERE id = new_admin_id) 
       OR EXISTS (SELECT 1 FROM public.profiles WHERE id = new_admin_id) 
    LOOP
        new_admin_id := gen_random_uuid();
    END LOOP;
    
    RAISE NOTICE '   ✅ Generated unique ID: %', new_admin_id;
    RAISE NOTICE '';
    
    -- === PHASE 3: CREATE AUTH USER ===
    RAISE NOTICE '📋 PHASE 3: Creating auth.users entry...';
    
    INSERT INTO auth.users (
        instance_id,
        id,
        aud,
        role,
        email,
        encrypted_password,
        email_confirmed_at,
        recovery_sent_at,
        last_sign_in_at,
        raw_app_meta_data,
        raw_user_meta_data,
        created_at,
        updated_at,
        confirmation_token,
        email_change,
        email_change_token_new,
        recovery_token
    )
    VALUES (
        '00000000-0000-0000-0000-000000000000',
        new_admin_id,
        'authenticated',
        'authenticated',
        '00000@eventty.app',
        crypt('indonesia', gen_salt('bf')),
        NOW(),
        NOW(),
        NOW(),
        jsonb_build_object('provider', 'email', 'providers', ARRAY['email']),
        jsonb_build_object('full_name', 'Admin EVENTTY', 'role', 'admin'),
        NOW(),
        NOW(),
        '',
        '',
        '',
        ''
    );
    
    RAISE NOTICE '   ✅ Auth user created';
    RAISE NOTICE '';
    
    -- === PHASE 4: CHECK FOR TRIGGER ===
    RAISE NOTICE '📋 PHASE 4: Checking for auto-created profile...';
    
    -- Check if trigger already created profile
    IF EXISTS (SELECT 1 FROM public.profiles WHERE id = new_admin_id) THEN
        has_trigger := true;
        RAISE NOTICE '   🔔 TRIGGER DETECTED! Profile auto-created by trigger';
        RAISE NOTICE '   🔄 Updating existing profile with correct data...';
        
        -- Update the auto-created profile with our data
        UPDATE public.profiles SET
            email = '00000@eventty.app',
            full_name = 'Admin EVENTTY',
            role = 'admin',
            student_id = '00000',
            phone = '081234567890',
            updated_at = NOW()
        WHERE id = new_admin_id;
        
        RAISE NOTICE '   ✅ Profile updated successfully';
    ELSE
        RAISE NOTICE '   ℹ️  No trigger detected, creating profile manually...';
        
        -- No trigger, create profile manually
        INSERT INTO public.profiles (
            id,
            email,
            full_name,
            role,
            student_id,
            phone,
            created_at,
            updated_at
        )
        VALUES (
            new_admin_id,
            '00000@eventty.app',
            'Admin EVENTTY',
            'admin',
            '00000',
            '081234567890',
            NOW(),
            NOW()
        );
        
        RAISE NOTICE '   ✅ Profile created successfully';
    END IF;
    
    RAISE NOTICE '';
    
    -- === PHASE 5: VERIFICATION ===
    RAISE NOTICE '📋 PHASE 5: Final verification...';
    
    IF NOT EXISTS (SELECT 1 FROM auth.users WHERE id = new_admin_id AND email = '00000@eventty.app') THEN
        RAISE EXCEPTION 'FATAL: Auth user verification failed!';
    END IF;
    RAISE NOTICE '   ✅ Auth user verified';
    
    IF NOT EXISTS (SELECT 1 FROM public.profiles WHERE id = new_admin_id AND email = '00000@eventty.app' AND student_id = '00000') THEN
        RAISE EXCEPTION 'FATAL: Profile verification failed!';
    END IF;
    RAISE NOTICE '   ✅ Profile verified';
    
    RAISE NOTICE '   ✅ IDs perfectly matched';
    RAISE NOTICE '';
    
    -- === SUCCESS MESSAGE ===
    RAISE NOTICE '✅ Admin user created successfully!';
    RAISE NOTICE '';

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '';
        RAISE NOTICE '❌ ERROR OCCURRED!';
        RAISE NOTICE 'Error: %', SQLERRM;
        RAISE NOTICE 'Detail: %', SQLSTATE;
        RAISE;
END $$;

-- ============================================
-- PART 6: INSERT SAMPLE EVENTS
-- ============================================

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
    'assets/images/detail/basket.jpeg',
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
    'assets/images/detail/career.jpeg',
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
    'assets/images/detail/seminar.jpeg',
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
    'assets/images/detail/workcod.jpeg',
    true,
    false,
    true,
    true,
    '["technology","coding","web-development","workshop","programming"]'::jsonb
)
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- PART 7: FINAL VERIFICATION
-- ============================================

DO $$
DECLARE
    table_count INT;
    user_count INT;
    admin_count INT;
    event_count INT;
BEGIN
    SELECT COUNT(*) INTO table_count 
    FROM information_schema.tables 
    WHERE table_schema = 'public';

    SELECT COUNT(*) INTO user_count 
    FROM public.profiles 
    WHERE email = '12345@eventty.app';

    SELECT COUNT(*) INTO admin_count 
    FROM public.profiles 
    WHERE email = '00000@eventty.app';

    SELECT COUNT(*) INTO event_count 
    FROM public.events;

    RAISE NOTICE '';
    RAISE NOTICE '============================================';
    RAISE NOTICE '🎉 SETUP COMPLETE!';
    RAISE NOTICE '============================================';
    RAISE NOTICE '';
    RAISE NOTICE '📊 DATABASE STATUS:';
    RAISE NOTICE '- Tables Created: %', table_count;
    RAISE NOTICE '- Student User (Varo): % ✅', user_count;
    RAISE NOTICE '- Admin User: % ✅', admin_count;
    RAISE NOTICE '- Sample Events: % ✅', event_count;
    RAISE NOTICE '';
    RAISE NOTICE '👤 STUDENT USER (VARO):';
    RAISE NOTICE '   Full Name: Varo';
    RAISE NOTICE '   Email: 12345@eventty.app';
    RAISE NOTICE '   Password: indonesia';
    RAISE NOTICE '   NIS: 12345';
    RAISE NOTICE '   Kelas: XII RPL 1';
    RAISE NOTICE '';
    RAISE NOTICE '👤 ADMIN USER:';
    RAISE NOTICE '   Full Name: Admin EVENTTY';
    RAISE NOTICE '   Email: 00000@eventty.app';
    RAISE NOTICE '   Password: indonesia';
    RAISE NOTICE '   NIS: 00000';
    RAISE NOTICE '';
    RAISE NOTICE '🔐 CARA LOGIN DI APP:';
    RAISE NOTICE '   - Masukkan NIS (12345 atau 00000)';
    RAISE NOTICE '   - Masukkan Password: indonesia';
    RAISE NOTICE '';
    RAISE NOTICE '🚀 NEXT STEPS:';
    RAISE NOTICE '1. Pastikan file .env sudah diisi dengan Supabase URL & Key';
    RAISE NOTICE '2. Restart aplikasi Flutter';
    RAISE NOTICE '3. Login dengan NIS dan password di atas';
    RAISE NOTICE '4. Aplikasi siap digunakan!';
    RAISE NOTICE '';
    RAISE NOTICE '============================================';
    RAISE NOTICE '';
END $$;

-- Show created users
SELECT 
    'USER CREATED' as status,
    full_name,
    email,
    role,
    student_id as nis,
    COALESCE(class, '-') as class
FROM public.profiles
WHERE email IN ('12345@eventty.app', '00000@eventty.app')
ORDER BY role;

-- Show created events
SELECT 
    'EVENT CREATED' as status,
    title,
    category,
    date::date as event_date,
    capacity,
    CASE WHEN is_featured THEN '⭐ Featured' ELSE '' END as featured
FROM public.events
ORDER BY date
LIMIT 4;
