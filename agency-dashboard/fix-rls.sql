-- UrbanFix Dashboard - RLS Policy Fix
-- Run this in Supabase SQL Editor to allow dashboard to update reports

-- 1. Allow public to update reports (for dashboard)
DROP POLICY IF EXISTS "Allow public updates" ON reports;
CREATE POLICY "Allow public updates"
ON reports FOR UPDATE
TO public
USING (true)
WITH CHECK (true);

-- 2. Allow public to insert timeline events (optional)
DROP POLICY IF EXISTS "Allow public timeline inserts" ON timeline_events;
CREATE POLICY "Allow public timeline inserts"
ON timeline_events FOR INSERT
TO public
WITH CHECK (true);

-- 3. Verify policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE tablename IN ('reports', 'timeline_events')
ORDER BY tablename, policyname;
