-- ==========================================
-- AadhiGuru Production Security Hardening
-- ==========================================

-- 1. Ensure RLS is enabled on ALL tables
ALTER TABLE public.store_products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.service_bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.matrimony_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- 2. Add user_id to tables if missing to link with Auth
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS user_id uuid REFERENCES auth.users(id) DEFAULT auth.uid();
ALTER TABLE public.service_bookings ADD COLUMN IF NOT EXISTS user_id uuid REFERENCES auth.users(id) DEFAULT auth.uid();

-- 3. Define Admin Check Function
-- Assuming we use a 'role' column in the 'profiles' table
CREATE OR REPLACE FUNCTION is_admin() 
RETURNS boolean AS $$
BEGIN
  RETURN (
    SELECT role = 'admin' 
    FROM public.profiles 
    WHERE id = auth.uid()
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Secure Policies for 'store_products'
DROP POLICY IF EXISTS "Allow public read access on store_products" ON public.store_products;
CREATE POLICY "Allow public read access on store_products" ON public.store_products FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow admin to manage store_products" ON public.store_products;
CREATE POLICY "Allow admin to manage store_products" ON public.store_products 
FOR ALL USING (is_admin()) WITH CHECK (is_admin());

-- 5. Secure Policies for 'bookings'
DROP POLICY IF EXISTS "Allow users to view own bookings" ON public.bookings;
CREATE POLICY "Allow users to view own bookings" ON public.bookings 
FOR SELECT USING (auth.uid() = user_id OR is_admin());

DROP POLICY IF EXISTS "Allow users to insert own bookings" ON public.bookings;
CREATE POLICY "Allow users to insert own bookings" ON public.bookings 
FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Allow users to delete own pending bookings" ON public.bookings;
CREATE POLICY "Allow users to delete own pending bookings" ON public.bookings 
FOR DELETE USING (auth.uid() = user_id AND status = 'pending');

DROP POLICY IF EXISTS "Allow admin to update bookings" ON public.bookings;
CREATE POLICY "Allow admin to update bookings" ON public.bookings 
FOR UPDATE USING (is_admin()) WITH CHECK (is_admin());

-- 6. Secure Policies for 'matrimony_profiles'
DROP POLICY IF EXISTS "Allow public read on matrimony_profiles" ON public.matrimony_profiles;
CREATE POLICY "Allow public read on matrimony_profiles" ON public.matrimony_profiles FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow users to manage own matrimony profile" ON public.matrimony_profiles;
CREATE POLICY "Allow users to manage own matrimony profile" ON public.matrimony_profiles 
FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- 7. Secure Policies for 'profiles'
DROP POLICY IF EXISTS "Public profiles are viewable by everyone." ON public.profiles;
CREATE POLICY "Public profiles are viewable by everyone." ON public.profiles FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can update own profile." ON public.profiles;
CREATE POLICY "Users can update own profile." ON public.profiles 
FOR UPDATE USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

-- 8. Secure Policies for 'classes'
DROP POLICY IF EXISTS "Allow public read on classes" ON public.classes;
CREATE POLICY "Allow public read on classes" ON public.classes FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow admin to manage classes" ON public.classes;
CREATE POLICY "Allow admin to manage classes" ON public.classes 
FOR ALL USING (is_admin()) WITH CHECK (is_admin());

-- 9. Storage Security (Supabase Storage)
-- Note: These usually need to be run in the storage schema or UI
-- but here is the logic for a 'service-docs' bucket
/*
CREATE POLICY "Allow authenticated uploads" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'service-docs' AND auth.role() = 'authenticated');
CREATE POLICY "Allow users to see own uploads" ON storage.objects FOR SELECT USING (bucket_id = 'service-docs' AND auth.uid() = owner);
*/

-- 10. Database Functions Security
ALTER FUNCTION trigger_whatsapp_notification() SECURITY DEFINER;
ALTER FUNCTION handle_new_user() SECURITY DEFINER;
