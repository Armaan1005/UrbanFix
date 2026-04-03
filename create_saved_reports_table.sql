-- Create saved_reports table for bookmarking reports
CREATE TABLE IF NOT EXISTS saved_reports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  report_id UUID NOT NULL REFERENCES reports(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, report_id)
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_saved_reports_user_id ON saved_reports(user_id);
CREATE INDEX IF NOT EXISTS idx_saved_reports_report_id ON saved_reports(report_id);

-- Enable RLS
ALTER TABLE saved_reports ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view their own saved reports"
  ON saved_reports FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own saved reports"
  ON saved_reports FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own saved reports"
  ON saved_reports FOR DELETE
  USING (auth.uid() = user_id);
