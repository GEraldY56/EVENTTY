-- ============================================
-- CHECK DATABASE STATUS
-- ============================================
-- Run this first to see what's in the database
-- ============================================

-- Check all users in auth.users
SELECT 
    '=== AUTH.USERS ===' as section,
    email,
    id::text as user_id,
    created_at::text as created
FROM auth.users
ORDER BY created_at DESC;

-- Check all profiles
SELECT 
    '=== PROFILES ===' as section,
    COALESCE(email, 'NULL') as email,
    COALESCE(student_id, 'NULL') as student_id,
    COALESCE(role, 'NULL') as role,
    id::text as profile_id,
    created_at::text as created
FROM public.profiles
ORDER BY created_at DESC;

-- Check for orphaned profiles (no matching auth user)
SELECT 
    '=== ORPHANED PROFILES ===' as section,
    p.email,
    p.student_id,
    p.role,
    p.id::text as orphaned_id
FROM public.profiles p
LEFT JOIN auth.users au ON p.id = au.id
WHERE au.id IS NULL;

-- Check for orphaned auth users (no matching profile)
SELECT 
    '=== ORPHANED AUTH USERS ===' as section,
    au.email,
    au.id::text as orphaned_id
FROM auth.users au
LEFT JOIN public.profiles p ON au.id = p.id
WHERE p.id IS NULL;

-- Count totals
SELECT 
    '=== TOTALS ===' as section,
    (SELECT COUNT(*) FROM auth.users) as total_auth_users,
    (SELECT COUNT(*) FROM public.profiles) as total_profiles,
    (SELECT COUNT(*) FROM public.profiles WHERE email = 'admin@eventty.app') as admin_profiles,
    (SELECT COUNT(*) FROM auth.users WHERE email = 'admin@eventty.app') as admin_auth_users;
