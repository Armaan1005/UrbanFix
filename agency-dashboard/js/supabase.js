// Supabase Configuration
const SUPABASE_URL = 'https://zcyuihxaabdahloljmve.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpjeXVpaHhhYWJkYWhsb2xqbXZlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUzODQ1MjcsImV4cCI6MjA4MDk2MDUyN30.m7X16L9SlXFHtXXrD8pGN8SsINpYn28fmg30ReX4rc4';

// Initialize Supabase client
const supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

console.log('Supabase client initialized with URL:', SUPABASE_URL);
