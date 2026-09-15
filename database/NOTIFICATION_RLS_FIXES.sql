-- ============================================================
-- EVENTTY - Notification RLS Policy Fixes
-- ============================================================
-- Problem: Admin cannot INSERT notifications for students
-- Root Cause: RLS policy context issue with is_admin() function
-- Solution: Multiple approaches documented below
-- ============================================================

-- ============================================================
-- APPROACH 1: Change Policy to Check Role Directly
-- ============================================================
-- Status: RECOMMENDED - Most reliable solution
-- Bypasses function context issues by querying profiles directly
-- ============================================================

DROP POLICY IF EXISTS notifications_insert_admin ON public.notifications;

CREATE POLICY notifications_insert_admin
ON public.notifications
FOR INSERT
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.profiles
        WHERE profiles.id = auth.uid()
        AND profiles.role = 'admin'
    )
);

-- ============================================================
-- APPROACH 2: RPC Function Workaround
-- ============================================================
-- Status: ALTERNATIVE - Use if direct INSERT must be avoided
-- Creates RPC function with SECURITY DEFINER to bypass RLS
-- ============================================================

CREATE OR REPLACE FUNCTION public.create_notification(
    p_user_id UUID,
    p_type TEXT,
    p_title TEXT,
    p_message TEXT,
    p_related_id UUID DEFAULT NULL
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_notification json;
BEGIN
    -- Verify caller is admin
    IF NOT public.is_admin() THEN
        RAISE EXCEPTION 'Only admin can create notifications';
    END IF;
    
    -- Insert notification and return it
    INSERT INTO public.notifications (
        user_id,
        type,
        title,
        message,
        related_id,
        is_read,
        created_at
    ) VALUES (
        p_user_id,
        p_type,
        p_title,
        p_message,
        p_related_id,
        FALSE,
        NOW()
    )
    RETURNING json_build_object(
        'id', id,
        'user_id', user_id,
        'type', type,
        'title', title,
        'message', message,
        'related_id', related_id,
        'is_read', is_read,
        'created_at', created_at
    ) INTO v_notification;
    
    RETURN v_notification;
END;
$$;

GRANT EXECUTE ON FUNCTION public.create_notification(UUID, TEXT, TEXT, TEXT, UUID) TO authenticated;

COMMENT ON FUNCTION public.create_notification IS 
'Create notification for a user. Only admin can call this function. Uses SECURITY DEFINER to bypass RLS issues.';

-- ============================================================
-- USAGE NOTES
-- ============================================================
-- 
-- Use APPROACH 1 (Direct INSERT with inline role check):
-- - Simpler, more maintainable
-- - No function call overhead
-- - Reliable in all contexts
--
-- Use APPROACH 2 (RPC Function) only if:
-- - You need additional business logic during insert
-- - You want to encapsulate notification creation
-- - You prefer API consistency via RPC
--
-- ============================================================
