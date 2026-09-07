-- ============================================
-- EVENTTY - DATABASE CLEANUP
-- ============================================
-- Run ini DULU sebelum run DATABASE_COMPLETE.sql
-- Untuk hapus semua table dan policy lama
-- ============================================

-- Drop all policies first (IF EXISTS prevents errors)
DO $$ 
BEGIN
  -- Profiles policies
  DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
  DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
  
  -- Events policies
  DROP POLICY IF EXISTS "Anyone can view events" ON public.events;
  
  -- Registrations policies
  DROP POLICY IF EXISTS "Students can view own registrations" ON public.registrations;
  DROP POLICY IF EXISTS "Students can create registrations" ON public.registrations;
  DROP POLICY IF EXISTS "Students can update own pending registrations" ON public.registrations;
  
  -- Certificates policies
  DROP POLICY IF EXISTS "Students can view own certificates" ON public.certificates;
  
  -- Conversations policies
  DROP POLICY IF EXISTS "Students can view own conversations" ON public.conversations;
  DROP POLICY IF EXISTS "Students can create own conversations" ON public.conversations;
  
  -- Messages policies
  DROP POLICY IF EXISTS "Users can view messages in own conversations" ON public.messages;
  DROP POLICY IF EXISTS "Users can create messages in own conversations" ON public.messages;
  
  -- News & Announcements policies
  DROP POLICY IF EXISTS "Anyone can view news" ON public.news;
  DROP POLICY IF EXISTS "Anyone can view announcements" ON public.announcements;
  
  -- Bookmarks policies
  DROP POLICY IF EXISTS "Students can manage own bookmarks" ON public.bookmarks;
  
  -- Notifications policies
  DROP POLICY IF EXISTS "Users can view their own notifications" ON public.notifications;
  DROP POLICY IF EXISTS "Users can update their own notifications" ON public.notifications;
  DROP POLICY IF EXISTS "Users can delete their own notifications" ON public.notifications;
  
EXCEPTION
  WHEN OTHERS THEN
    -- Ignore errors, continue cleanup
    NULL;
END $$;

-- Drop triggers
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP TRIGGER IF EXISTS update_event_count ON public.registrations;
DROP TRIGGER IF EXISTS update_profiles_updated_at ON public.profiles;
DROP TRIGGER IF EXISTS update_events_updated_at ON public.events;
DROP TRIGGER IF EXISTS update_registrations_updated_at ON public.registrations;
DROP TRIGGER IF EXISTS update_conversations_updated_at ON public.conversations;
DROP TRIGGER IF EXISTS update_news_updated_at ON public.news;
DROP TRIGGER IF EXISTS update_announcements_updated_at ON public.announcements;

-- Drop functions
DROP FUNCTION IF EXISTS public.handle_new_user();
DROP FUNCTION IF EXISTS update_event_registered_count();
DROP FUNCTION IF EXISTS update_updated_at_column();

-- Drop tables in correct order (respect foreign keys)
DROP TABLE IF EXISTS public.notifications CASCADE;
DROP TABLE IF EXISTS public.bookmarks CASCADE;
DROP TABLE IF EXISTS public.messages CASCADE;
DROP TABLE IF EXISTS public.conversations CASCADE;
DROP TABLE IF EXISTS public.announcements CASCADE;
DROP TABLE IF EXISTS public.news CASCADE;
DROP TABLE IF EXISTS public.certificates CASCADE;
DROP TABLE IF EXISTS public.registrations CASCADE;
DROP TABLE IF EXISTS public.events CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;

-- Clean up auth.users (optional - hati-hati!)
-- DELETE FROM auth.users WHERE email IN ('12345@eventty.app', '00000@eventty.app');

-- ✅ CLEANUP COMPLETE!
-- Sekarang run DATABASE_COMPLETE.sql
