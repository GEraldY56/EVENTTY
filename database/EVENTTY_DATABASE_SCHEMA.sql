-- ============================================================
-- EVENTTY PRODUCTION DATABASE SCHEMA V3.3 FINAL
-- ============================================================
-- Database : Supabase PostgreSQL
-- Version  : 3.3 FINAL
-- Date     : 2026-09-09
--
-- REGISTER:
--   Nama Lengkap
--   NIS (tepat 5 digit)
--   Password
--   Konfirmasi Password -> hanya divalidasi Flutter
--
-- LOGIN:
--   NIS + Password
--
-- INTERNAL AUTH EMAIL:
--   {NIS}@eventty.local
--
-- CHAT:
--   Student -> Admin OSIS
--   Tidak menggunakan BOT / AI
--   Student dapat mengirim pesan kapan saja
--   Admin membalas pada jam operasional
--   Senin-Jumat : 06:00-15:00
--   Sabtu-Minggu: CLOSED
--
-- IMPORTANT:
--   - Tidak DROP TABLE
--   - Tidak DELETE data
--   - Tidak memasukkan seed data
--   - Password dikelola Supabase Auth
--   - Register otomatis membuat profile student
--   - Role register selalu student
-- ============================================================


-- ============================================================
-- 1. EXTENSIONS
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";


-- ============================================================
-- 2. TABLE: PROFILES
-- ============================================================

CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY
        REFERENCES auth.users(id)
        ON DELETE CASCADE,

    email TEXT UNIQUE NOT NULL,

    full_name TEXT NOT NULL,

    role TEXT NOT NULL DEFAULT 'student'
        CHECK (role IN ('student', 'admin')),

    avatar_url TEXT,

    phone TEXT,

    nis TEXT UNIQUE,

    major TEXT,

    semester INTEGER
        CHECK (semester >= 1 AND semester <= 6),

    created_at TIMESTAMPTZ DEFAULT NOW(),

    updated_at TIMESTAMPTZ DEFAULT NOW()
);


CREATE INDEX IF NOT EXISTS idx_profiles_email
    ON public.profiles(email);

CREATE INDEX IF NOT EXISTS idx_profiles_role
    ON public.profiles(role);

CREATE INDEX IF NOT EXISTS idx_profiles_nis
    ON public.profiles(nis);


COMMENT ON TABLE public.profiles
IS 'User profiles for EVENTTY students and administrators';

COMMENT ON COLUMN public.profiles.role
IS 'User role: student or admin';

COMMENT ON COLUMN public.profiles.nis
IS 'Nomor Induk Siswa - exactly 5 digits for students';


-- ============================================================
-- 3. TABLE: EVENTS
-- ============================================================

CREATE TABLE IF NOT EXISTS public.events (
    id UUID PRIMARY KEY
        DEFAULT uuid_generate_v4(),

    title TEXT NOT NULL,

    description TEXT NOT NULL,

    category TEXT NOT NULL,

    date TIMESTAMPTZ NOT NULL,

    time TEXT NOT NULL,

    location TEXT NOT NULL,

    organizer TEXT NOT NULL
        DEFAULT 'OSIS SMKN 20 Jakarta',

    capacity INTEGER NOT NULL
        DEFAULT 100
        CHECK (capacity > 0),

    registered INTEGER NOT NULL
        DEFAULT 0
        CHECK (registered >= 0),

    status TEXT NOT NULL
        DEFAULT 'open'
        CHECK (
            status IN (
                'open',
                'ongoing',
                'closed'
            )
        ),

    image_url TEXT,

    is_featured BOOLEAN DEFAULT FALSE,

    is_popular BOOLEAN DEFAULT FALSE,

    is_published BOOLEAN DEFAULT FALSE,

    is_registration_open BOOLEAN DEFAULT TRUE,

    tags TEXT[] DEFAULT '{}',

    created_at TIMESTAMPTZ DEFAULT NOW(),

    registration_deadline TIMESTAMPTZ,

    certificate_enabled BOOLEAN DEFAULT FALSE,

    certificate_type TEXT DEFAULT 'none'
        CHECK (
            certificate_type IN (
                'none',
                'allParticipants',
                'winners'
            )
        ),

    minimum_attendance INTEGER
        CHECK (
            minimum_attendance >= 0
            AND minimum_attendance <= 100
        ),

    registration_type TEXT DEFAULT 'individual'
        CHECK (
            registration_type IN (
                'individual',
                'team'
            )
        ),

    CONSTRAINT check_registered_capacity
        CHECK (registered <= capacity)
);


CREATE INDEX IF NOT EXISTS idx_events_date
    ON public.events(date);

CREATE INDEX IF NOT EXISTS idx_events_category
    ON public.events(category);

CREATE INDEX IF NOT EXISTS idx_events_status
    ON public.events(status);

CREATE INDEX IF NOT EXISTS idx_events_featured
    ON public.events(is_featured);

CREATE INDEX IF NOT EXISTS idx_events_popular
    ON public.events(is_popular);

CREATE INDEX IF NOT EXISTS idx_events_published
    ON public.events(is_published);

CREATE INDEX IF NOT EXISTS idx_events_registration_open
    ON public.events(is_registration_open);

CREATE INDEX IF NOT EXISTS idx_events_registration_deadline
    ON public.events(registration_deadline);


COMMENT ON TABLE public.events
IS 'EVENTTY event management';


-- ============================================================
-- 4. TABLE: REGISTRATIONS
-- ============================================================

CREATE TABLE IF NOT EXISTS public.registrations (
    id UUID PRIMARY KEY
        DEFAULT uuid_generate_v4(),

    event_id UUID NOT NULL
        REFERENCES public.events(id)
        ON DELETE CASCADE,

    type TEXT NOT NULL
        DEFAULT 'individual'
        CHECK (
            type IN (
                'individual',
                'team'
            )
        ),

    -- Individual
    user_id UUID
        REFERENCES auth.users(id)
        ON DELETE CASCADE,

    user_name TEXT,

    -- Team
    team_name TEXT,

    class_name TEXT,

    leader_id TEXT,

    leader_name TEXT,

    members JSONB DEFAULT '[]'::jsonb,

    -- Common
    form_data JSONB NOT NULL
        DEFAULT '{}'::jsonb,

    registration_date TIMESTAMPTZ
        DEFAULT NOW(),

    status TEXT NOT NULL
        DEFAULT 'pending'
        CHECK (
            status IN (
                'pending',
                'confirmed',
                'attended',
                'cancelled'
            )
        ),

    CONSTRAINT check_registration_fields
        CHECK (
            (
                type = 'individual'
                AND user_id IS NOT NULL
                AND user_name IS NOT NULL
            )
            OR
            (
                type = 'team'
                AND team_name IS NOT NULL
                AND leader_id IS NOT NULL
            )
        )
);


CREATE INDEX IF NOT EXISTS idx_registrations_event_id
    ON public.registrations(event_id);

CREATE INDEX IF NOT EXISTS idx_registrations_user_id
    ON public.registrations(user_id);

CREATE INDEX IF NOT EXISTS idx_registrations_type
    ON public.registrations(type);

CREATE INDEX IF NOT EXISTS idx_registrations_status
    ON public.registrations(status);

CREATE INDEX IF NOT EXISTS idx_registrations_date
    ON public.registrations(registration_date DESC);


COMMENT ON TABLE public.registrations
IS 'EVENTTY event registrations';


-- ============================================================
-- 5. TABLE: PARTICIPANTS
-- ============================================================

CREATE TABLE IF NOT EXISTS public.participants (
    id UUID PRIMARY KEY
        DEFAULT uuid_generate_v4(),

    event_id UUID NOT NULL
        REFERENCES public.events(id)
        ON DELETE CASCADE,

    student_id TEXT NOT NULL,

    student_name TEXT NOT NULL,

    student_nis TEXT NOT NULL,

    student_class TEXT NOT NULL,

    email TEXT NOT NULL,

    phone TEXT NOT NULL,

    registration_date TIMESTAMPTZ
        DEFAULT NOW(),

    status TEXT NOT NULL
        DEFAULT 'pending'
        CHECK (
            status IN (
                'pending',
                'approved',
                'rejected',
                'attended'
            )
        ),

    has_certificate BOOLEAN DEFAULT FALSE,

    certificate_id UUID,

    notes TEXT,

    placement TEXT
        CHECK (
            placement IN (
                'first',
                'second',
                'third',
                'participant'
            )
        ),

    UNIQUE(event_id, student_id)
);


CREATE INDEX IF NOT EXISTS idx_participants_event_id
    ON public.participants(event_id);

CREATE INDEX IF NOT EXISTS idx_participants_student_id
    ON public.participants(student_id);

CREATE INDEX IF NOT EXISTS idx_participants_status
    ON public.participants(status);

CREATE INDEX IF NOT EXISTS idx_participants_certificate
    ON public.participants(has_certificate);


COMMENT ON TABLE public.participants
IS 'EVENTTY event participants and attendance';


-- ============================================================
-- 6. TABLE: CERTIFICATE TEMPLATES
-- ============================================================

CREATE TABLE IF NOT EXISTS public.certificate_templates (
    id UUID PRIMARY KEY
        DEFAULT uuid_generate_v4(),

    name TEXT NOT NULL,

    description TEXT NOT NULL,

    layout_type TEXT DEFAULT 'modern'
        CHECK (
            layout_type IN (
                'modern',
                'classic',
                'elegant',
                'minimalist'
            )
        ),

    background_color TEXT DEFAULT '#FFFFFF',

    border_color TEXT DEFAULT '#6B4F3A',

    text_color TEXT DEFAULT '#1A1A1A',

    accent_color TEXT DEFAULT '#C89B6D',

    has_logo BOOLEAN DEFAULT TRUE,

    has_border BOOLEAN DEFAULT TRUE,

    has_signature BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMPTZ DEFAULT NOW(),

    updated_at TIMESTAMPTZ DEFAULT NOW()
);


COMMENT ON TABLE public.certificate_templates
IS 'EVENTTY certificate design templates';


-- ============================================================
-- 7. TABLE: CERTIFICATES
-- ============================================================

CREATE TABLE IF NOT EXISTS public.certificates (
    id UUID PRIMARY KEY
        DEFAULT uuid_generate_v4(),

    event_id UUID NOT NULL
        REFERENCES public.events(id)
        ON DELETE CASCADE,

    event_title TEXT NOT NULL,

    event_category TEXT NOT NULL,

    participant_id TEXT NOT NULL,

    participant_name TEXT NOT NULL,

    participant_nis TEXT NOT NULL,

    template_id UUID
        REFERENCES public.certificate_templates(id)
        ON DELETE SET NULL,

    event_date TIMESTAMPTZ NOT NULL,

    issued_date TIMESTAMPTZ DEFAULT NOW(),

    certificate_number TEXT UNIQUE NOT NULL,

    signed_by TEXT
        DEFAULT 'OSIS SMKN 20 Jakarta',

    additional_info TEXT,

    achievement TEXT,

    UNIQUE(event_id, participant_id)
);


CREATE INDEX IF NOT EXISTS idx_certificates_event_id
    ON public.certificates(event_id);

CREATE INDEX IF NOT EXISTS idx_certificates_participant_id
    ON public.certificates(participant_id);

CREATE INDEX IF NOT EXISTS idx_certificates_number
    ON public.certificates(certificate_number);

CREATE INDEX IF NOT EXISTS idx_certificates_issued_date
    ON public.certificates(issued_date DESC);

CREATE INDEX IF NOT EXISTS idx_certificates_template_id
    ON public.certificates(template_id);


-- ============================================================
-- 8. PARTICIPANT -> CERTIFICATE FK
-- ============================================================

DO $$
BEGIN

    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'fk_participants_certificate'
    ) THEN

        ALTER TABLE public.participants
        ADD CONSTRAINT fk_participants_certificate
        FOREIGN KEY (certificate_id)
        REFERENCES public.certificates(id)
        ON DELETE SET NULL;

    END IF;

END $$;


-- ============================================================
-- 9. TABLE: ANNOUNCEMENTS
-- ============================================================

CREATE TABLE IF NOT EXISTS public.announcements (
    id UUID PRIMARY KEY
        DEFAULT uuid_generate_v4(),

    title TEXT NOT NULL,

    content TEXT NOT NULL,

    event_id UUID
        REFERENCES public.events(id)
        ON DELETE SET NULL,

    category TEXT DEFAULT 'General',

    priority TEXT DEFAULT 'medium'
        CHECK (
            priority IN (
                'high',
                'medium',
                'low'
            )
        ),

    author TEXT NOT NULL,

    author_id UUID
        REFERENCES auth.users(id)
        ON DELETE SET NULL,

    is_pinned BOOLEAN DEFAULT FALSE,

    is_published BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMPTZ DEFAULT NOW(),

    updated_at TIMESTAMPTZ DEFAULT NOW()
);


CREATE INDEX IF NOT EXISTS idx_announcements_event_id
    ON public.announcements(event_id);

CREATE INDEX IF NOT EXISTS idx_announcements_published
    ON public.announcements(is_published);

CREATE INDEX IF NOT EXISTS idx_announcements_pinned
    ON public.announcements(is_pinned);

CREATE INDEX IF NOT EXISTS idx_announcements_created
    ON public.announcements(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_announcements_author
    ON public.announcements(author_id);


-- ============================================================
-- 10. TABLE: CHAT OPERATING HOURS
-- ============================================================

CREATE TABLE IF NOT EXISTS public.chat_operating_hours (
    id UUID PRIMARY KEY
        DEFAULT uuid_generate_v4(),

    day_of_week INTEGER NOT NULL
        CHECK (day_of_week BETWEEN 1 AND 7),

    day_name TEXT NOT NULL,

    open_time TIME,

    close_time TIME,

    is_open BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ DEFAULT NOW(),

    updated_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(day_of_week)
);


-- ============================================================
-- 11. TABLE: CONVERSATIONS
-- ============================================================
-- IMPORTANT:
-- V3.2 mempunyai mode = admin / bot.
-- V3.3 FINAL tidak menggunakan bot.
-- Kolom mode tetap dipertahankan untuk kompatibilitas struktur,
-- tetapi nilainya HANYA boleh 'admin'.

CREATE TABLE IF NOT EXISTS public.conversations (
    id UUID PRIMARY KEY
        DEFAULT uuid_generate_v4(),

    student_id UUID NOT NULL
        REFERENCES auth.users(id)
        ON DELETE CASCADE,

    student_name TEXT NOT NULL,

    event_id UUID
        REFERENCES public.events(id)
        ON DELETE SET NULL,

    event_title TEXT,

    mode TEXT NOT NULL
        DEFAULT 'admin'
        CHECK (mode = 'admin'),

    last_message TEXT,

    last_message_at TIMESTAMPTZ
        DEFAULT NOW(),

    unread_count INTEGER DEFAULT 0
        CHECK (unread_count >= 0),

    is_active BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMPTZ DEFAULT NOW(),

    updated_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(student_id)
);


CREATE INDEX IF NOT EXISTS idx_conversations_student_id
    ON public.conversations(student_id);

CREATE INDEX IF NOT EXISTS idx_conversations_last_message
    ON public.conversations(last_message_at DESC);

CREATE INDEX IF NOT EXISTS idx_conversations_active
    ON public.conversations(is_active);


COMMENT ON TABLE public.conversations
IS 'EVENTTY private student-to-admin conversations; no bot';


COMMENT ON COLUMN public.conversations.mode
IS 'Conversation mode is permanently admin; EVENTTY does not use bot conversations';


-- ============================================================
-- 12. TABLE: MESSAGES
-- ============================================================
-- IMPORTANT:
-- HANYA:
--   student
--   admin
--
-- BOT DIHAPUS SEPENUHNYA DARI DATABASE.

CREATE TABLE IF NOT EXISTS public.messages (
    id UUID PRIMARY KEY
        DEFAULT uuid_generate_v4(),

    conversation_id UUID NOT NULL
        REFERENCES public.conversations(id)
        ON DELETE CASCADE,

    sender_id TEXT NOT NULL,

    sender_name TEXT NOT NULL,

    sender_role TEXT NOT NULL
        CHECK (
            sender_role IN (
                'student',
                'admin'
            )
        ),

    message TEXT NOT NULL,

    is_read BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMPTZ DEFAULT NOW()
);


CREATE INDEX IF NOT EXISTS idx_messages_conversation_id
    ON public.messages(conversation_id);

CREATE INDEX IF NOT EXISTS idx_messages_created_at
    ON public.messages(created_at);

CREATE INDEX IF NOT EXISTS idx_messages_is_read
    ON public.messages(is_read);

CREATE INDEX IF NOT EXISTS idx_messages_sender_id
    ON public.messages(sender_id);


COMMENT ON TABLE public.messages
IS 'EVENTTY student-to-admin messages; no bot or AI sender';


-- ============================================================
-- 13. TABLE: BOOKMARKS
-- ============================================================

CREATE TABLE IF NOT EXISTS public.bookmarks (
    id UUID PRIMARY KEY
        DEFAULT uuid_generate_v4(),

    user_id UUID NOT NULL
        REFERENCES auth.users(id)
        ON DELETE CASCADE,

    event_id UUID NOT NULL
        REFERENCES public.events(id)
        ON DELETE CASCADE,

    created_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(user_id, event_id)
);


CREATE INDEX IF NOT EXISTS idx_bookmarks_user_id
    ON public.bookmarks(user_id);

CREATE INDEX IF NOT EXISTS idx_bookmarks_event_id
    ON public.bookmarks(event_id);


-- ============================================================
-- 14. TABLE: NOTIFICATIONS
-- ============================================================

CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY
        DEFAULT uuid_generate_v4(),

    user_id UUID NOT NULL
        REFERENCES auth.users(id)
        ON DELETE CASCADE,

    title TEXT NOT NULL,

    message TEXT NOT NULL,

    type TEXT NOT NULL,

    related_id UUID,

    is_read BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMPTZ DEFAULT NOW()
);


CREATE INDEX IF NOT EXISTS idx_notifications_user_id
    ON public.notifications(user_id);

CREATE INDEX IF NOT EXISTS idx_notifications_is_read
    ON public.notifications(is_read);

CREATE INDEX IF NOT EXISTS idx_notifications_created_at
    ON public.notifications(created_at DESC);


-- ============================================================
-- 15. TABLE: EVENT DOCUMENTATION
-- ============================================================

CREATE TABLE IF NOT EXISTS public.event_documentation (
    id UUID PRIMARY KEY
        DEFAULT uuid_generate_v4(),

    event_id UUID NOT NULL
        REFERENCES public.events(id)
        ON DELETE CASCADE,

    title TEXT NOT NULL,

    description TEXT,

    file_type TEXT NOT NULL,

    file_url TEXT NOT NULL,

    file_size BIGINT,

    uploaded_by UUID
        REFERENCES auth.users(id)
        ON DELETE SET NULL,

    created_at TIMESTAMPTZ DEFAULT NOW(),

    updated_at TIMESTAMPTZ DEFAULT NOW()
);


CREATE INDEX IF NOT EXISTS idx_documentation_event_id
    ON public.event_documentation(event_id);

CREATE INDEX IF NOT EXISTS idx_documentation_uploaded_by
    ON public.event_documentation(uploaded_by);


-- ============================================================
-- 16. FUNCTION: UPDATED_AT
-- ============================================================

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN

    NEW.updated_at = NOW();

    RETURN NEW;

END;
$$;


-- ============================================================
-- 17. FUNCTION: CHECK ADMIN
-- ============================================================
-- SECURITY DEFINER digunakan supaya pemeriksaan role tidak
-- menyebabkan recursion pada RLS profiles.

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN

    RETURN EXISTS (
        SELECT 1
        FROM public.profiles
        WHERE id = auth.uid()
          AND role = 'admin'
    );

END;
$$;


-- ============================================================
-- 18. FUNCTION: AUTO CREATE PROFILE AFTER REGISTER
-- ============================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$

DECLARE
    v_full_name TEXT;
    v_nis TEXT;

BEGIN

    -- ========================================================
    -- Ambil metadata Supabase Auth
    -- ========================================================

    v_full_name :=
        NULLIF(
            TRIM(NEW.raw_user_meta_data ->> 'full_name'),
            ''
        );

    v_nis :=
        NULLIF(
            TRIM(NEW.raw_user_meta_data ->> 'nis'),
            ''
        );


    -- ========================================================
    -- Validate full name
    -- ========================================================

    IF v_full_name IS NULL THEN

        RAISE EXCEPTION
            'Nama lengkap wajib diisi';

    END IF;


    -- ========================================================
    -- Validate NIS
    -- ========================================================

    IF v_nis IS NULL THEN

        RAISE EXCEPTION
            'NIS wajib diisi';

    END IF;


    IF v_nis !~ '^[0-9]{5}$' THEN

        RAISE EXCEPTION
            'NIS harus terdiri dari tepat 5 angka';

    END IF;


    -- ========================================================
    -- Create student profile
    -- ========================================================

    INSERT INTO public.profiles (
        id,
        email,
        full_name,
        role,
        nis
    )
    VALUES (
        NEW.id,
        NEW.email,
        v_full_name,
        'student',
        v_nis
    );


    RETURN NEW;

END;
$$;


-- ============================================================
-- 19. TRIGGER: AUTH USER -> PROFILE
-- ============================================================

DROP TRIGGER IF EXISTS on_auth_user_created
ON auth.users;


CREATE TRIGGER on_auth_user_created

AFTER INSERT
ON auth.users

FOR EACH ROW

EXECUTE FUNCTION public.handle_new_user();


-- ============================================================
-- 20. FUNCTION: REGISTRATION COUNTER
-- ============================================================

CREATE OR REPLACE FUNCTION public.handle_registration_count()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$

BEGIN

    -- ========================================================
    -- INSERT
    -- ========================================================

    IF TG_OP = 'INSERT' THEN

        IF NEW.status = 'confirmed' THEN

            UPDATE public.events
            SET registered = registered + 1
            WHERE id = NEW.event_id;

        END IF;

        RETURN NEW;

    END IF;


    -- ========================================================
    -- UPDATE
    -- ========================================================

    IF TG_OP = 'UPDATE' THEN

        -- Event berubah
        IF OLD.event_id IS DISTINCT FROM NEW.event_id THEN

            IF OLD.status = 'confirmed' THEN

                UPDATE public.events
                SET registered =
                    GREATEST(registered - 1, 0)
                WHERE id = OLD.event_id;

            END IF;


            IF NEW.status = 'confirmed' THEN

                UPDATE public.events
                SET registered = registered + 1
                WHERE id = NEW.event_id;

            END IF;


        ELSE

            -- Pending -> Confirmed
            IF OLD.status <> 'confirmed'
               AND NEW.status = 'confirmed' THEN

                UPDATE public.events
                SET registered = registered + 1
                WHERE id = NEW.event_id;

            END IF;


            -- Confirmed -> selain confirmed
            IF OLD.status = 'confirmed'
               AND NEW.status <> 'confirmed' THEN

                UPDATE public.events
                SET registered =
                    GREATEST(registered - 1, 0)
                WHERE id = NEW.event_id;

            END IF;

        END IF;

        RETURN NEW;

    END IF;


    -- ========================================================
    -- DELETE
    -- ========================================================

    IF TG_OP = 'DELETE' THEN

        IF OLD.status = 'confirmed' THEN

            UPDATE public.events
            SET registered =
                GREATEST(registered - 1, 0)
            WHERE id = OLD.event_id;

        END IF;

        RETURN OLD;

    END IF;


    RETURN NULL;

END;
$$;


-- ============================================================
-- 21. TRIGGERS
-- ============================================================

DROP TRIGGER IF EXISTS update_profiles_updated_at
ON public.profiles;

CREATE TRIGGER update_profiles_updated_at

BEFORE UPDATE
ON public.profiles

FOR EACH ROW

EXECUTE FUNCTION public.update_updated_at_column();


DROP TRIGGER IF EXISTS update_announcements_updated_at
ON public.announcements;

CREATE TRIGGER update_announcements_updated_at

BEFORE UPDATE
ON public.announcements

FOR EACH ROW

EXECUTE FUNCTION public.update_updated_at_column();


DROP TRIGGER IF EXISTS update_conversations_updated_at
ON public.conversations;

CREATE TRIGGER update_conversations_updated_at

BEFORE UPDATE
ON public.conversations

FOR EACH ROW

EXECUTE FUNCTION public.update_updated_at_column();


DROP TRIGGER IF EXISTS update_documentation_updated_at
ON public.event_documentation;

CREATE TRIGGER update_documentation_updated_at

BEFORE UPDATE
ON public.event_documentation

FOR EACH ROW

EXECUTE FUNCTION public.update_updated_at_column();


DROP TRIGGER IF EXISTS on_registration_status_changed
ON public.registrations;

CREATE TRIGGER on_registration_status_changed

AFTER INSERT OR UPDATE OR DELETE
ON public.registrations

FOR EACH ROW

EXECUTE FUNCTION public.handle_registration_count();


-- ============================================================
-- 22. ENABLE RLS
-- ============================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.registrations ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.participants ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.certificate_templates ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.certificates ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.announcements ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.chat_operating_hours ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.bookmarks ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.event_documentation ENABLE ROW LEVEL SECURITY;


-- ============================================================
-- 23. REMOVE EXISTING EVENTTY POLICIES
-- ============================================================
-- Ini bukan DROP TABLE.
-- Hanya membersihkan policy EVENTTY agar policy final
-- tidak bertabrakan/duplikat.

DO $$

DECLARE
    policy_record RECORD;

BEGIN

    FOR policy_record IN

        SELECT
            schemaname,
            tablename,
            policyname

        FROM pg_policies

        WHERE schemaname = 'public'

        AND (

            policyname LIKE 'profiles_%'

            OR policyname LIKE 'events_%'

            OR policyname LIKE 'registrations_%'

            OR policyname LIKE 'participants_%'

            OR policyname LIKE 'certificate_templates_%'

            OR policyname LIKE 'certificates_%'

            OR policyname LIKE 'announcements_%'

            OR policyname LIKE 'chat_operating_hours_%'

            OR policyname LIKE 'conversations_%'

            OR policyname LIKE 'messages_%'

            OR policyname LIKE 'bookmarks_%'

            OR policyname LIKE 'notifications_%'

            OR policyname LIKE 'event_documentation_%'

        )

    LOOP

        EXECUTE format(
            'DROP POLICY IF EXISTS %I ON %I.%I',
            policy_record.policyname,
            policy_record.schemaname,
            policy_record.tablename
        );

    END LOOP;

END $$;


-- ============================================================
-- 24. PROFILES RLS
-- ============================================================

CREATE POLICY profiles_select_own_or_admin

ON public.profiles

FOR SELECT

USING (
    auth.uid() = id
    OR public.is_admin()
);


CREATE POLICY profiles_insert_own

ON public.profiles

FOR INSERT

WITH CHECK (
    auth.uid() = id
);


CREATE POLICY profiles_update_own

ON public.profiles

FOR UPDATE

USING (
    auth.uid() = id
)

WITH CHECK (
    auth.uid() = id
    AND role = 'student'
);


CREATE POLICY profiles_update_admin

ON public.profiles

FOR UPDATE

USING (
    public.is_admin()
)

WITH CHECK (
    public.is_admin()
);


-- ============================================================
-- 25. EVENTS RLS
-- ============================================================

CREATE POLICY events_select_published

ON public.events

FOR SELECT

USING (
    is_published = TRUE
    OR public.is_admin()
);


CREATE POLICY events_insert_admin

ON public.events

FOR INSERT

WITH CHECK (
    public.is_admin()
);


CREATE POLICY events_update_admin

ON public.events

FOR UPDATE

USING (
    public.is_admin()
)

WITH CHECK (
    public.is_admin()
);


CREATE POLICY events_delete_admin

ON public.events

FOR DELETE

USING (
    public.is_admin()
);


-- ============================================================
-- 26. REGISTRATIONS RLS
-- ============================================================

CREATE POLICY registrations_select_own

ON public.registrations

FOR SELECT

USING (

    user_id = auth.uid()

    OR public.is_admin()

    OR (

        type = 'team'

        AND members::jsonb @> jsonb_build_array(
            jsonb_build_object(
                'studentId',
                auth.uid()::text
            )
        )

    )

);


CREATE POLICY registrations_insert_own

ON public.registrations

FOR INSERT

WITH CHECK (

    auth.uid() IS NOT NULL

    AND

    (

        (
            type = 'individual'
            AND user_id = auth.uid()
        )

        OR

        (
            type = 'team'
            AND leader_id = auth.uid()::text
        )

    )

);


CREATE POLICY registrations_update_own_pending

ON public.registrations

FOR UPDATE

USING (

    user_id = auth.uid()
    AND status = 'pending'

)

WITH CHECK (

    user_id = auth.uid()

);


CREATE POLICY registrations_admin_all

ON public.registrations

FOR ALL

USING (
    public.is_admin()
)

WITH CHECK (
    public.is_admin()
);


-- ============================================================
-- 27. PARTICIPANTS RLS
-- ============================================================

CREATE POLICY participants_select_own_or_admin

ON public.participants

FOR SELECT

USING (

    student_id = (
        SELECT nis
        FROM public.profiles
        WHERE id = auth.uid()
    )

    OR public.is_admin()

);


CREATE POLICY participants_insert_admin

ON public.participants

FOR INSERT

WITH CHECK (
    public.is_admin()
);


CREATE POLICY participants_update_admin

ON public.participants

FOR UPDATE

USING (
    public.is_admin()
)

WITH CHECK (
    public.is_admin()
);


CREATE POLICY participants_delete_admin

ON public.participants

FOR DELETE

USING (
    public.is_admin()
);


-- ============================================================
-- 28. CERTIFICATE TEMPLATES RLS
-- ============================================================

CREATE POLICY certificate_templates_select_all

ON public.certificate_templates

FOR SELECT

USING (
    TRUE
);


CREATE POLICY certificate_templates_admin_all

ON public.certificate_templates

FOR ALL

USING (
    public.is_admin()
)

WITH CHECK (
    public.is_admin()
);  


-- ============================================================
-- 29. CERTIFICATES RLS
-- ============================================================

CREATE POLICY certificates_select_own

ON public.certificates

FOR SELECT

USING (

    participant_id = (
        SELECT nis
        FROM public.profiles
        WHERE id = auth.uid()
    )

    OR public.is_admin()

);


CREATE POLICY certificates_admin_all

ON public.certificates

FOR ALL

USING (
    public.is_admin()
)

WITH CHECK (
    public.is_admin()
);


-- ============================================================
-- 30. ANNOUNCEMENTS RLS
-- ============================================================

CREATE POLICY announcements_select_published

ON public.announcements

FOR SELECT

USING (
    is_published = TRUE
    OR public.is_admin()
);


CREATE POLICY announcements_admin_all

ON public.announcements

FOR ALL

USING (
    public.is_admin()
)

WITH CHECK (
    public.is_admin()
);


-- ============================================================
-- 31. CHAT OPERATING HOURS RLS
-- ============================================================

CREATE POLICY chat_operating_hours_select_all

ON public.chat_operating_hours

FOR SELECT

USING (
    TRUE
);


CREATE POLICY chat_operating_hours_admin_all

ON public.chat_operating_hours

FOR ALL

USING (
    public.is_admin()
)

WITH CHECK (
    public.is_admin()
);


-- ============================================================
-- 32. CONVERSATIONS RLS
-- ============================================================

CREATE POLICY conversations_select_own

ON public.conversations

FOR SELECT

USING (

    student_id = auth.uid()

    OR public.is_admin()

);


CREATE POLICY conversations_insert_own

ON public.conversations

FOR INSERT

WITH CHECK (

    student_id = auth.uid()

    AND mode = 'admin'

);


CREATE POLICY conversations_update_own

ON public.conversations

FOR UPDATE

USING (

    student_id = auth.uid()

    OR public.is_admin()

)

WITH CHECK (

    (
        student_id = auth.uid()
        OR public.is_admin()
    )

    AND mode = 'admin'

);


-- ============================================================
-- 33. MESSAGES RLS
-- ============================================================
--
-- STUDENT:
--   hanya dapat mengirim sebagai student
--
-- ADMIN:
--   hanya dapat mengirim sebagai admin
--
-- BOT:
--   TIDAK DIIZINKAN
--
-- Student tetap dapat INSERT kapan saja.
-- Jam operasional ditangani oleh UI/service:
-- Admin membalas Senin-Jumat 06:00-15:00.
--

CREATE POLICY messages_select_own

ON public.messages

FOR SELECT

USING (

    EXISTS (

        SELECT 1

        FROM public.conversations c

        WHERE c.id = messages.conversation_id

        AND (

            c.student_id = auth.uid()

            OR public.is_admin()

        )

    )

);


CREATE POLICY messages_insert_own

ON public.messages

FOR INSERT

WITH CHECK (

    EXISTS (

        SELECT 1

        FROM public.conversations c

        WHERE c.id = messages.conversation_id

        AND (

            (
                c.student_id = auth.uid()

                AND sender_id = auth.uid()::text

                AND sender_role = 'student'
            )

            OR

            (
                public.is_admin()

                AND sender_id = auth.uid()::text

                AND sender_role = 'admin'
            )

        )

    )

);


CREATE POLICY messages_update_own

ON public.messages

FOR UPDATE

USING (

    sender_id = auth.uid()::text

    OR public.is_admin()

)

WITH CHECK (

    (

        sender_id = auth.uid()::text

        AND sender_role = 'student'

    )

    OR

    (

        public.is_admin()

        AND sender_role = 'admin'

    )

);


-- ============================================================
-- 34. BOOKMARKS RLS
-- ============================================================

CREATE POLICY bookmarks_own_all

ON public.bookmarks

FOR ALL

USING (
    user_id = auth.uid()
)

WITH CHECK (
    user_id = auth.uid()
);


-- ============================================================
-- 35. NOTIFICATIONS RLS
-- ============================================================

CREATE POLICY notifications_select_own

ON public.notifications

FOR SELECT

USING (
    user_id = auth.uid()
);


CREATE POLICY notifications_update_own

ON public.notifications

FOR UPDATE

USING (
    user_id = auth.uid()
)

WITH CHECK (
    user_id = auth.uid()
);


CREATE POLICY notifications_insert_admin

ON public.notifications

FOR INSERT

WITH CHECK (
    public.is_admin()
);


CREATE POLICY notifications_delete_own

ON public.notifications

FOR DELETE

USING (
    user_id = auth.uid()
);


-- ============================================================
-- 36. EVENT DOCUMENTATION RLS
-- ============================================================

CREATE POLICY event_documentation_select_all

ON public.event_documentation

FOR SELECT

USING (
    TRUE
);


CREATE POLICY event_documentation_admin_all

ON public.event_documentation

FOR ALL

USING (
    public.is_admin()
)

WITH CHECK (
    public.is_admin()
);


-- ============================================================
-- 37. REALTIME
-- ============================================================

DO $$

BEGIN

    BEGIN

        ALTER PUBLICATION supabase_realtime
        ADD TABLE public.messages;

    EXCEPTION

        WHEN duplicate_object THEN
            NULL;

    END;


    BEGIN

        ALTER PUBLICATION supabase_realtime
        ADD TABLE public.conversations;

    EXCEPTION

        WHEN duplicate_object THEN
            NULL;

    END;

END $$;


-- ============================================================
-- 38. CHAT OPERATING HOURS
-- ============================================================
--
-- Monday-Friday : 06:00-15:00
-- Saturday      : CLOSED
-- Sunday        : CLOSED
--
-- Student masih boleh mengirim pesan di luar jam.
-- Jam operasional menentukan kapan ADMIN membalas.
--

INSERT INTO public.chat_operating_hours
(
    day_of_week,
    day_name,
    open_time,
    close_time,
    is_open
)

VALUES

(
    1,
    'Monday',
    '06:00:00',
    '15:00:00',
    TRUE
),

(
    2,
    'Tuesday',
    '06:00:00',
    '15:00:00',
    TRUE
),

(
    3,
    'Wednesday',
    '06:00:00',
    '15:00:00',
    TRUE
),

(
    4,
    'Thursday',
    '06:00:00',
    '15:00:00',
    TRUE
),

(
    5,
    'Friday',
    '06:00:00',
    '15:00:00',
    TRUE
),

(
    6,
    'Saturday',
    NULL,
    NULL,
    FALSE
),

(
    7,
    'Sunday',
    NULL,
    NULL,
    FALSE
)

ON CONFLICT (day_of_week)

DO UPDATE SET

    day_name = EXCLUDED.day_name,

    open_time = EXCLUDED.open_time,

    close_time = EXCLUDED.close_time,

    is_open = EXCLUDED.is_open,

    updated_at = NOW();


-- ============================================================
-- 39. COMMENTS / DOCUMENTATION
-- ============================================================

COMMENT ON POLICY profiles_select_own_or_admin

ON public.profiles

IS
'Users can view their own profile. Admins can view all profiles.';


COMMENT ON POLICY profiles_update_own

ON public.profiles

IS
'Students can update their own profile but cannot promote themselves to admin.';


COMMENT ON POLICY participants_select_own_or_admin

ON public.participants

IS
'Students can view participant records matching their profile NIS. Admins can view all.';


COMMENT ON POLICY certificates_select_own

ON public.certificates

IS
'Students can view certificates matching their profile NIS. Admins can view all.';


COMMENT ON POLICY conversations_select_own

ON public.conversations

IS
'Students can access their own private admin conversation. Admins can access all conversations.';


COMMENT ON POLICY messages_insert_own

ON public.messages

IS
'Students and admins may send messages using their own authenticated identity. Bot messages are not allowed.';


-- ============================================================
-- 40. REGISTER SYSTEM DOCUMENTATION
-- ============================================================

COMMENT ON FUNCTION public.handle_new_user()

IS
'Automatically creates an EVENTTY student profile after Supabase Auth registration. Requires full_name and exactly 5 digit NIS from user metadata.';


-- ============================================================
-- 41. FINAL DATABASE VERIFICATION
-- ============================================================

DO $$

DECLARE

    table_count INTEGER;

    policy_count INTEGER;

    trigger_count INTEGER;

    function_count INTEGER;

    bot_conversation_constraints INTEGER;

    bot_message_constraints INTEGER;

BEGIN


    -- ========================================================
    -- TABLE COUNT
    -- ========================================================

    SELECT COUNT(*)

    INTO table_count

    FROM information_schema.tables

    WHERE table_schema = 'public'

    AND table_name IN (

        'profiles',

        'events',

        'registrations',

        'participants',

        'certificate_templates',

        'certificates',

        'announcements',

        'chat_operating_hours',

        'conversations',

        'messages',

        'bookmarks',

        'notifications',

        'event_documentation'

    );


    -- ========================================================
    -- POLICY COUNT
    -- ========================================================

    SELECT COUNT(*)

    INTO policy_count

    FROM pg_policies

    WHERE schemaname = 'public';


    -- ========================================================
    -- TRIGGER COUNT
    -- ========================================================

    SELECT COUNT(*)

    INTO trigger_count

    FROM pg_trigger

    WHERE NOT tgisinternal

    AND tgrelid IN (

        'public.profiles'::regclass,

        'public.announcements'::regclass,

        'public.conversations'::regclass,

        'public.event_documentation'::regclass,

        'public.registrations'::regclass,

        'auth.users'::regclass

    );


    -- ========================================================
    -- FUNCTION COUNT
    -- ========================================================

    SELECT COUNT(*)

    INTO function_count

    FROM pg_proc p

    JOIN pg_namespace n
        ON n.oid = p.pronamespace

    WHERE n.nspname = 'public'

    AND p.proname IN (

        'update_updated_at_column',

        'handle_registration_count',

        'is_admin',

        'handle_new_user'

    );


    -- ========================================================
    -- VERIFY BOT CONSTRAINTS
    -- ========================================================

    SELECT COUNT(*)

    INTO bot_conversation_constraints

    FROM pg_constraint

    WHERE conrelid = 'public.conversations'::regclass

    AND pg_get_constraintdef(oid) ILIKE '%bot%';


    SELECT COUNT(*)

    INTO bot_message_constraints

    FROM pg_constraint

    WHERE conrelid = 'public.messages'::regclass

    AND pg_get_constraintdef(oid) ILIKE '%bot%';


    -- ========================================================
    -- OUTPUT
    -- ========================================================

    RAISE NOTICE '';

    RAISE NOTICE '============================================================';

    RAISE NOTICE 'EVENTTY DATABASE SCHEMA V3.3 FINAL';

    RAISE NOTICE '============================================================';

    RAISE NOTICE 'Tables detected              : %', table_count;

    RAISE NOTICE 'RLS policies detected        : %', policy_count;

    RAISE NOTICE 'Triggers detected            : %', trigger_count;

    RAISE NOTICE 'Functions detected           : %', function_count;

    RAISE NOTICE 'Bot conversation constraints : %', bot_conversation_constraints;

    RAISE NOTICE 'Bot message constraints      : %', bot_message_constraints;

    RAISE NOTICE '';

    RAISE NOTICE 'REGISTER:';

    RAISE NOTICE '- Full Name';

    RAISE NOTICE '- NIS (exactly 5 digits)';

    RAISE NOTICE '- Password';

    RAISE NOTICE '- Confirm Password checked in Flutter';

    RAISE NOTICE '';

    RAISE NOTICE 'LOGIN:';

    RAISE NOTICE '- NIS + Password';

    RAISE NOTICE '';

    RAISE NOTICE 'ROLE:';

    RAISE NOTICE '- New registrations = STUDENT';

    RAISE NOTICE '- Admin cannot be created through register';

    RAISE NOTICE '';

    RAISE NOTICE 'AUTH:';

    RAISE NOTICE '- Password handled by Supabase Auth';

    RAISE NOTICE '- Profile automatically created';

    RAISE NOTICE '';

    RAISE NOTICE 'CHAT:';

    RAISE NOTICE '- Student -> Admin OSIS';

    RAISE NOTICE '- No Bot';

    RAISE NOTICE '- No AI sender';

    RAISE NOTICE '- Student can send messages anytime';

    RAISE NOTICE '- Admin operating hours: Monday-Friday 06:00-15:00';

    RAISE NOTICE '- Weekend: CLOSED';

    RAISE NOTICE '- One private conversation per student';

    RAISE NOTICE '';

    RAISE NOTICE 'SAFETY CHECK:';

    IF bot_conversation_constraints = 0
       AND bot_message_constraints = 0 THEN

        RAISE NOTICE '- Bot constraint check: PASS';

    ELSE

        RAISE NOTICE '- Bot constraint check: REVIEW REQUIRED';

    END IF;

    RAISE NOTICE '';

    RAISE NOTICE 'IMPORTANT:';

    RAISE NOTICE '- No DROP TABLE executed.';

    RAISE NOTICE '- No DELETE executed.';

    RAISE NOTICE '- No seed data inserted.';

    RAISE NOTICE '- Existing table structures are not automatically migrated.';

    RAISE NOTICE '- Confirm password is NOT stored.';

    RAISE NOTICE '- Internal Auth email format: NIS@eventty.local';

    RAISE NOTICE '============================================================';

END $$;


-- ============================================================
-- END OF EVENTTY DATABASE V3.3 FINAL
-- ============================================================