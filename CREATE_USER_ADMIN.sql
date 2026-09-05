-- ============================================
-- CREATE ADMIN USER (NIS: 00000, Password: indonesia)
-- ============================================
-- TRIGGER-AWARE - Handles auto-created profiles
-- ============================================

DO $$
DECLARE
    new_admin_id UUID;
    orphaned_profile_id UUID;
    cleanup_count INT := 0;
    has_trigger BOOLEAN := false;
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '============================================';
    RAISE NOTICE '🚀 Admin User Creation - TRIGGER-AWARE MODE';
    RAISE NOTICE '============================================';
    RAISE NOTICE '';
    
    -- === PHASE 1: SMART CLEANUP ===
    RAISE NOTICE '📋 PHASE 1: Smart cleanup...';
    
    -- Delete admin from auth.users (if exists)
    DELETE FROM auth.users WHERE email = '00000@eventty.app' OR email = 'admin@eventty.app';
    GET DIAGNOSTICS cleanup_count = ROW_COUNT;
    IF cleanup_count > 0 THEN
        RAISE NOTICE '   🗑️ Deleted % admin from auth.users', cleanup_count;
    END IF;
    
    -- Delete admin profiles
    DELETE FROM public.profiles WHERE email = '00000@eventty.app' OR email = 'admin@eventty.app' OR student_id = '00000';
    GET DIAGNOSTICS cleanup_count = ROW_COUNT;
    IF cleanup_count > 0 THEN
        RAISE NOTICE '   🗑️ Deleted % admin profile(s)', cleanup_count;
    END IF;
    
    -- Delete orphaned profiles
    FOR orphaned_profile_id IN 
        SELECT p.id 
        FROM public.profiles p
        LEFT JOIN auth.users au ON p.id = au.id
        WHERE au.id IS NULL
    LOOP
        DELETE FROM public.profiles WHERE id = orphaned_profile_id;
        RAISE NOTICE '   🗑️ Deleted orphaned profile: %', orphaned_profile_id;
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
        RAISE NOTICE '   ℹ️ No trigger detected, creating profile manually...';
        
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
    RAISE NOTICE '============================================';
    RAISE NOTICE '✅ ADMIN USER CREATED SUCCESSFULLY!';
    RAISE NOTICE '============================================';
    RAISE NOTICE '';
    IF has_trigger THEN
        RAISE NOTICE '🔔 Note: Your database has a trigger that auto-creates profiles';
        RAISE NOTICE '   The profile was updated with correct admin data.';
        RAISE NOTICE '';
    END IF;
    RAISE NOTICE '📧 Email    : admin@eventty.app';
    RAISE NOTICE '👤 Name     : Admin EVENTTY';
    RAISE NOTICE '🎫 NIS      : 00000';
    RAISE NOTICE '🔒 Password : indonesia';
    RAISE NOTICE '👔 Role     : admin';
    RAISE NOTICE '🆔 User ID  : %', new_admin_id;
    RAISE NOTICE '';
    RAISE NOTICE '🔐 LOGIN DI APP:';
    RAISE NOTICE '   Full Name: Admin EVENTTY';
    RAISE NOTICE '   NIS: 00000';
    RAISE NOTICE '   Password: indonesia';
    RAISE NOTICE '';
    RAISE NOTICE '============================================';
    RAISE NOTICE '🎉 Ready to test login!';
    RAISE NOTICE '============================================';
    RAISE NOTICE '';

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '';
        RAISE NOTICE '============================================';
        RAISE NOTICE '❌ ERROR OCCURRED!';
        RAISE NOTICE '============================================';
        RAISE NOTICE 'Error: %', SQLERRM;
        RAISE NOTICE 'Detail: %', SQLSTATE;
        RAISE NOTICE '';
        RAISE NOTICE 'Transaction rolled back - database unchanged.';
        RAISE NOTICE '============================================';
        RAISE;
END $$;

-- Show final result
SELECT 
    '✅ AUTH USER' as status,
    email,
    id::text as user_id,
    created_at::text as created
FROM auth.users 
WHERE email = '00000@eventty.app'

UNION ALL

SELECT 
    '✅ PROFILE' as status,
    email,
    id::text as user_id,
    CONCAT('NIS: ', student_id, ' | Role: ', role, ' | Name: ', full_name) as created
FROM public.profiles 
WHERE email = '00000@eventty.app'

ORDER BY status DESC;
