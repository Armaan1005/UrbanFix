-- Add 'other' category to reports table
-- Run this in Supabase SQL Editor

-- Drop the existing constraint
ALTER TABLE public.reports 
DROP CONSTRAINT IF EXISTS reports_category_check;

-- Add new constraint with 'other' included
ALTER TABLE public.reports 
ADD CONSTRAINT reports_category_check 
CHECK (category IN ('pothole', 'garbage', 'streetlight', 'footpath', 'drain', 'other'));

-- Verify the change
SELECT conname, pg_get_constraintdef(oid) 
FROM pg_constraint 
WHERE conrelid = 'public.reports'::regclass 
AND conname = 'reports_category_check';
