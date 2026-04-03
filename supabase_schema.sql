-- UrbanFix Database Schema for Supabase
-- Copy and paste this entire file into Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TABLES
-- ============================================

-- Users table (extends Supabase auth.users)
CREATE TABLE IF NOT EXISTS public.users (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  name TEXT NOT NULL,
  phone TEXT,
  city TEXT DEFAULT 'Chennai',
  ward TEXT,
  avatar_url TEXT,
  points INTEGER DEFAULT 0,
  rank INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Reports table
CREATE TABLE IF NOT EXISTS public.reports (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  issue_number TEXT UNIQUE NOT NULL,
  user_id UUID REFERENCES public.users(id) NOT NULL,
  category TEXT NOT NULL CHECK (category IN ('pothole', 'garbage', 'streetlight', 'footpath', 'drain')),
  status TEXT DEFAULT 'reported' CHECK (status IN ('reported', 'acknowledged', 'under_review', 'in_progress', 'resolved', 'rejected')),
  title TEXT NOT NULL,
  description TEXT,
  image_url TEXT NOT NULL,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  address TEXT NOT NULL,
  upvotes INTEGER DEFAULT 0,
  comments_count INTEGER DEFAULT 0,
  assigned_agency_id UUID,
  estimated_resolution_time TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Upvotes table
CREATE TABLE IF NOT EXISTS public.upvotes (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  report_id UUID REFERENCES public.reports(id) ON DELETEdone CASCADE,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(report_id, user_id)
);

-- Timeline events table
CREATE TABLE IF NOT EXISTS public.timeline_events (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  report_id UUID REFERENCES public.reports(id) ON DELETE CASCADE,
  status TEXT NOT NULL,
  message TEXT NOT NULL,
  updated_by TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Evidence table
CREATE TABLE IF NOT EXISTS public.evidence (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  report_id UUID REFERENCES public.reports(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  uploaded_by TEXT NOT NULL,
  caption TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Badges table
CREATE TABLE IF NOT EXISTS public.badges (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  icon TEXT NOT NULL,
  earned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Agencies table
CREATE TABLE IF NOT EXISTS public.agencies (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name TEXT NOT NULL,
  contact TEXT,
  zone TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- INDEXES
-- ============================================

CREATE INDEX IF NOT EXISTS idx_reports_user_id ON public.reports(user_id);
CREATE INDEX IF NOT EXISTS idx_reports_status ON public.reports(status);
CREATE INDEX IF NOT EXISTS idx_reports_category ON public.reports(category);
CREATE INDEX IF NOT EXISTS idx_reports_created_at ON public.reports(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_reports_latitude ON public.reports(latitude);
CREATE INDEX IF NOT EXISTS idx_reports_longitude ON public.reports(longitude);
CREATE INDEX IF NOT EXISTS idx_upvotes_report_id ON public.upvotes(report_id);
CREATE INDEX IF NOT EXISTS idx_upvotes_user_id ON public.upvotes(user_id);
CREATE INDEX IF NOT EXISTS idx_timeline_report_id ON public.timeline_events(report_id);

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.upvotes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.timeline_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.evidence ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.agencies ENABLE ROW LEVEL SECURITY;

-- Users table policies
CREATE POLICY "Users can view all profiles" ON public.users
  FOR SELECT USING (true);

CREATE POLICY "Users can insert own profile" ON public.users
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.users
  FOR UPDATE USING (auth.uid() = id);

-- Reports table policies
CREATE POLICY "Anyone can view reports" ON public.reports
  FOR SELECT USING (true);

CREATE POLICY "Authenticated users can create reports" ON public.reports
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own reports" ON public.reports
  FOR UPDATE USING (auth.uid() = user_id);

-- Upvotes table policies
CREATE POLICY "Anyone can view upvotes" ON public.upvotes
  FOR SELECT USING (true);

CREATE POLICY "Authenticated users can upvote" ON public.upvotes
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can remove own upvotes" ON public.upvotes
  FOR DELETE USING (auth.uid() = user_id);

-- Timeline events policies
CREATE POLICY "Anyone can view timeline events" ON public.timeline_events
  FOR SELECT USING (true);

CREATE POLICY "Authenticated users can add timeline events" ON public.timeline_events
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- Evidence policies
CREATE POLICY "Anyone can view evidence" ON public.evidence
  FOR SELECT USING (true);

CREATE POLICY "Authenticated users can upload evidence" ON public.evidence
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- Badges policies
CREATE POLICY "Anyone can view badges" ON public.badges
  FOR SELECT USING (true);

CREATE POLICY "System can award badges" ON public.badges
  FOR INSERT WITH CHECK (true);

-- Agencies policies
CREATE POLICY "Anyone can view agencies" ON public.agencies
  FOR SELECT USING (true);

-- ============================================
-- FUNCTIONS & TRIGGERS
-- ============================================

-- Sequence for issue numbers
CREATE SEQUENCE IF NOT EXISTS issue_number_seq START 1;

-- Function to auto-generate issue number
CREATE OR REPLACE FUNCTION generate_issue_number()
RETURNS TRIGGER AS $$
BEGIN
  NEW.issue_number := 'RPT-' || TO_CHAR(NOW(), 'YYYY') || '-' || 
                      LPAD(NEXTVAL('issue_number_seq')::TEXT, 6, '0');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-generate issue number
DROP TRIGGER IF EXISTS set_issue_number ON public.reports;
CREATE TRIGGER set_issue_number
  BEFORE INSERT ON public.reports
  FOR EACH ROW
  EXECUTE FUNCTION generate_issue_number();

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
DROP TRIGGER IF EXISTS update_users_updated_at ON public.users;
CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON public.users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_reports_updated_at ON public.reports;
CREATE TRIGGER update_reports_updated_at
  BEFORE UPDATE ON public.reports
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Function to update upvote count
CREATE OR REPLACE FUNCTION update_report_upvotes()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.reports
    SET upvotes = upvotes + 1
    WHERE id = NEW.report_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.reports
    SET upvotes = upvotes - 1
    WHERE id = OLD.report_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update upvote count
DROP TRIGGER IF EXISTS update_upvote_count ON public.upvotes;
CREATE TRIGGER update_upvote_count
  AFTER INSERT OR DELETE ON public.upvotes
  FOR EACH ROW
  EXECUTE FUNCTION update_report_upvotes();

-- Function to create user profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, name, phone, avatar_url)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'name', 'User'),
    COALESCE(NEW.raw_user_meta_data->>'phone', ''),
    COALESCE(NEW.raw_user_meta_data->>'avatar_url', '')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create user profile on signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- SAMPLE DATA (Optional - for testing)
-- ============================================

-- Insert sample agency
INSERT INTO public.agencies (name, contact, zone) VALUES
  ('Chennai Corporation - Zone 5', '+91-44-12345678', 'T. Nagar')
ON CONFLICT DO NOTHING;

-- ============================================
-- STORAGE POLICIES (Run after creating bucket)
-- ============================================

-- These will be applied after you create the 'report-images' bucket
-- in the Supabase Storage UI

-- Allow public read access
-- CREATE POLICY "Public can view images"
-- ON storage.objects FOR SELECT
-- USING (bucket_id = 'report-images');

-- Allow authenticated users to upload
-- CREATE POLICY "Authenticated users can upload"
-- ON storage.objects FOR INSERT
-- WITH CHECK (
--   bucket_id = 'report-images' 
--   AND auth.role() = 'authenticated'
-- );

-- Allow users to update their own uploads
-- CREATE POLICY "Users can update own uploads"
-- ON storage.objects FOR UPDATE
-- USING (auth.uid()::text = owner)
-- WITH CHECK (bucket_id = 'report-images');

-- Allow users to delete their own uploads
-- CREATE POLICY "Users can delete own uploads"
-- ON storage.objects FOR DELETE
-- USING (auth.uid()::text = owner AND bucket_id = 'report-images');

-- ============================================
-- COMPLETION MESSAGE
-- ============================================

DO $$
BEGIN
  RAISE NOTICE '✅ UrbanFix database schema created successfully!';
  RAISE NOTICE '📋 Next steps:';
  RAISE NOTICE '1. Create storage bucket: report-images';
  RAISE NOTICE '2. Enable realtime for: reports, upvotes, timeline_events';
  RAISE NOTICE '3. Copy your Project URL and API keys';
END $$;
