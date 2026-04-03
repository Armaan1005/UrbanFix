import { createClient } from '@supabase/supabase-js'

const SUPABASE_URL = 'https://zcyuihxaabdahloljmve.supabase.co'
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpjeXVpaHhhYWJkYWhsb2xqbXZlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUzODQ1MjcsImV4cCI6MjA4MDk2MDUyN30.m7X16L9SlXFHtXXrD8pGN8SsINpYn28fmg30ReX4rc4'

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)

export type Report = {
    id: string
    category: string
    description: string
    address: string
    latitude: number
    longitude: number
    status: 'reported' | 'acknowledged' | 'in_progress' | 'resolved'
    upvotes: number
    image_url?: string
    created_at: string
    updated_at: string
}

export type TimelineEvent = {
    id: string
    report_id: string
    status: string
    message: string
    updated_by: string
    created_at: string
}
