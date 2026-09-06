-- ============================================
-- UPDATE EVENT IMAGES - Ganti dari Unsplash ke Local Assets
-- ============================================
-- Run script ini di Supabase SQL Editor untuk update gambar event
-- ============================================

-- Update Basketball Championship
UPDATE public.events
SET image_url = 'assets/images/detail/basket.jpeg'
WHERE id = '550e8400-e29b-41d4-a716-446655440001';

-- Update Career Day
UPDATE public.events
SET image_url = 'assets/images/detail/career.jpeg'
WHERE id = '550e8400-e29b-41d4-a716-446655440002';

-- Update AI Seminar
UPDATE public.events
SET image_url = 'assets/images/detail/seminar.jpeg'
WHERE id = '550e8400-e29b-41d4-a716-446655440003';

-- Update Coding Workshop
UPDATE public.events
SET image_url = 'assets/images/detail/workcod.jpeg'
WHERE id = '550e8400-e29b-41d4-a716-446655440004';

-- Verify updates
SELECT 
    '✅ EVENT IMAGES UPDATED' as status,
    title,
    image_url
FROM public.events
WHERE id IN (
    '550e8400-e29b-41d4-a716-446655440001',
    '550e8400-e29b-41d4-a716-446655440002',
    '550e8400-e29b-41d4-a716-446655440003',
    '550e8400-e29b-41d4-a716-446655440004'
)
ORDER BY title;
