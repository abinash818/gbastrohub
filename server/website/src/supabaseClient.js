import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

let db;

if (supabaseUrl && supabaseAnonKey && supabaseUrl.startsWith('http')) {
  db = createClient(supabaseUrl, supabaseAnonKey);
} else {
  console.warn("Supabase credentials not found in env. Falling back to local data.");
  
  // A more robust chainable mock for local development without credentials
  const mockQueryBuilder = {
    select: () => mockQueryBuilder,
    insert: () => mockQueryBuilder,
    update: () => mockQueryBuilder,
    delete: () => mockQueryBuilder,
    eq: () => mockQueryBuilder,
    single: async () => ({ data: null, error: new Error("No supabase client configured") }),
    then: (callback) => callback({ data: null, error: new Error("No supabase client configured") })
  };

  db = {
    from: () => mockQueryBuilder,
    auth: {
      signUp: async () => ({ data: { user: null }, error: new Error("Supabase is not configured. Please add VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY to your .env file.") }),
      signInWithPassword: async () => ({ data: { user: null }, error: new Error("Supabase is not configured. Please add VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY to your .env file.") }),
      getUser: async () => ({ data: { user: null }, error: new Error("Supabase is not configured.") }),
      signOut: async () => ({ error: null })
    }
  };
}

const supabase = db;
export { supabase };
