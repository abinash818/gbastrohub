-- ==========================================
-- AadhiGuru Supabase Schema Setup
-- ==========================================

-- Enable Row Level Security (RLS) on all tables but allow public reads/writes for this prototype schema.
-- In a production environment, you should secure these policies based on auth.uid()

-- 1. Store Products Table
CREATE TABLE IF NOT EXISTS public.store_products (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  category text NOT NULL,
  name text NOT NULL,
  name_ta text,
  price numeric NOT NULL,
  original_price numeric,
  rating numeric DEFAULT 0,
  reviews integer DEFAULT 0,
  emoji text,
  badge text,
  description text,
  seller text DEFAULT 'AadhiGuru'
);

-- RLS for Store Products
ALTER TABLE public.store_products ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access on store_products" ON public.store_products;
CREATE POLICY "Allow public read access on store_products" ON public.store_products FOR SELECT USING (true);
DROP POLICY IF EXISTS "Allow public insert on store_products" ON public.store_products;
CREATE POLICY "Allow public insert on store_products" ON public.store_products FOR INSERT WITH CHECK (true);


-- 2. Service Bookings Table
CREATE TABLE IF NOT EXISTS public.service_bookings (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  full_name text NOT NULL,
  phone text NOT NULL,
  purpose text,
  service_id integer,
  service_title text,
  service_category text,
  booking_date date NOT NULL,
  time_slot text NOT NULL,
  status text DEFAULT 'pending'
);

-- RLS for Service Bookings
ALTER TABLE public.service_bookings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public insert on bookings" ON public.service_bookings;
CREATE POLICY "Allow public insert on bookings" ON public.service_bookings FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS "Allow users to view own bookings based on phone" ON public.service_bookings;
CREATE POLICY "Allow users to view own bookings based on phone" ON public.service_bookings FOR SELECT USING (true); -- Usually restricted by auth uid


-- 3. Matrimony Profiles Table
CREATE TABLE IF NOT EXISTS public.matrimony_profiles (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  user_id uuid REFERENCES auth.users(id),
  gender text NOT NULL,
  name text NOT NULL,
  age integer NOT NULL,
  religion text,
  caste text,
  sub_caste text,
  star text,
  rasi text,
  height text,
  education text,
  profession text,
  location text,
  income text,
  complexion text,
  diet text,
  mother_tongue text,
  father_occ text,
  mother_occ text,
  siblings text,
  marital_status text,
  avatar text,
  avatar_bg text,
  is_premium boolean DEFAULT false,
  is_verified boolean DEFAULT false,
  preview text,
  tags jsonb DEFAULT '[]'::jsonb
);

-- RLS for Matrimony Profiles
ALTER TABLE public.matrimony_profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read on matrimony_profiles" ON public.matrimony_profiles;
CREATE POLICY "Allow public read on matrimony_profiles" ON public.matrimony_profiles FOR SELECT USING (true);
DROP POLICY IF EXISTS "Allow public insert on matrimony_profiles" ON public.matrimony_profiles;
CREATE POLICY "Allow public insert on matrimony_profiles" ON public.matrimony_profiles FOR INSERT WITH CHECK (true);


-- 4. Classes Setup
CREATE TABLE IF NOT EXISTS public.classes (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  title_en text NOT NULL,
  title_ta text,
  class_date date NOT NULL,
  price numeric NOT NULL,
  attendees integer DEFAULT 0,
  is_active boolean DEFAULT true
);

-- RLS for Classes
ALTER TABLE public.classes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read on classes" ON public.classes;
CREATE POLICY "Allow public read on classes" ON public.classes FOR SELECT USING (true);
DROP POLICY IF EXISTS "Allow public insert on classes" ON public.classes;
CREATE POLICY "Allow public insert on classes" ON public.classes FOR INSERT WITH CHECK (true);


-- ==========================================
-- Insert Mock Data
-- ==========================================

INSERT INTO public.store_products (category, name, name_ta, price, original_price, rating, reviews, emoji, badge, description, seller) VALUES
('Astrology', 'KP Astrology Book Set', 'கே.பி ஜோதிட புத்தக தொகுப்பு', 850, 1200, 4.8, 124, '📚', 'Best Seller', 'Complete 3-volume set for KP Astrology practitioners.', 'AadhiGuru'),
('Puja', 'Navgraha Yantra Set', 'நவகிரக யந்திர தொகுப்பு', 1499, 1999, 4.6, 89, '🔯', 'Top Rated', 'Energized copper Navgraha Yantras with installation guide.', 'AadhiGuru'),
('Yoga', 'Anti-Slip Yoga Mat', 'யோகா மேட்', 699, 999, 4.5, 213, '🧘', 'New', '6mm thick eco-friendly TPE mat with alignment lines.', 'AadhiGuru'),
('Vastu', 'Vastu Pyramid Set (9 pcs)', 'வாஸ்து பிரமிட் தொகுப்பு', 399, 599, 4.7, 156, '🔺', 'Popular', 'Crystal Vastu pyramids for positive energy flow.', 'AadhiGuru');

INSERT INTO public.classes (title_en, title_ta, class_date, price, attendees) VALUES
('Introduction to Vastu Shastra', 'வாஸ்து சாஸ்திரம் அறிமுகம்', '2026-04-10', 1500, 12),
('Advanced KP Astrology', 'உயர்தர கே.பி ஜோதிடம்', '2026-04-15', 3000, 8);


-- 5. Bookings Notification Setup (Twilio & Razorpay Integration Workflow)
CREATE TABLE IF NOT EXISTS public.bookings (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  full_name text NOT NULL,
  gender text NOT NULL,
  phone_number text NOT NULL,
  calling_location text NOT NULL,
  meeting_location text NOT NULL,
  purpose_of_booking text NOT NULL,
  date date NOT NULL,
  time_slot text NOT NULL,
  status text DEFAULT 'pending', -- pending, accepted, rejected
  payment_status text DEFAULT 'unpaid', -- unpaid, partial, paid
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- RLS for Bookings
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public insert on bookings" ON public.bookings;
CREATE POLICY "Allow public insert on bookings" ON public.bookings FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS "Allow public select on bookings for payment flow" ON public.bookings;
CREATE POLICY "Allow public select on bookings for payment flow" ON public.bookings FOR SELECT USING (true);
DROP POLICY IF EXISTS "Allow public update on bookings for accept/reject/payment" ON public.bookings;
CREATE POLICY "Allow public update on bookings for accept/reject/payment" ON public.bookings FOR UPDATE USING (true);

-- Trigger for Edge Function
CREATE OR REPLACE FUNCTION trigger_whatsapp_notification()
RETURNS TRIGGER AS $$
BEGIN
  -- We assume standard Supabase Edge function webhook URL logic here
  -- For local environments, you can use pg_net or webhook endpoints directly via UI.
  -- To do this natively via SQL in Supabase:
  PERFORM net.http_post(
      url:='https://' || current_setting('request.headers')::json->>'origin' || '/functions/v1/send-whatsapp',
      headers:='{"Content-Type": "application/json", "Authorization": "Bearer YOUR_SERVICE_ROLE_KEY"}'::jsonb,
      body:=json_build_object(
        'type', TG_OP,
        'table', TG_TABLE_NAME,
        'record', row_to_json(NEW),
        'old_record', row_to_json(OLD)
      )::jsonb
  );
  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  -- Fallback for environments where pg_net is not enabled simply return new so inserts do not fail
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_booking_activity ON public.bookings;
CREATE TRIGGER on_booking_activity
AFTER INSERT OR UPDATE ON public.bookings
FOR EACH ROW EXECUTE FUNCTION trigger_whatsapp_notification();
-- 6. User Profiles Table (Automatic Sync)
CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid REFERENCES auth.users(id) PRIMARY KEY,
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  username text UNIQUE,
  full_name text,
  avatar_url text,
  role text DEFAULT 'user',
  email text UNIQUE,
  phone text
);

-- RLS for Profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public profiles are viewable by everyone." ON public.profiles;
CREATE POLICY "Public profiles are viewable by everyone." ON public.profiles FOR SELECT USING (true);
DROP POLICY IF EXISTS "Users can insert their own profile." ON public.profiles;
CREATE POLICY "Users can insert their own profile." ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);
DROP POLICY IF EXISTS "Users can update own profile." ON public.profiles;
CREATE POLICY "Users can update own profile." ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- Trigger Function: Handle New User
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, username, full_name, avatar_url, role, email, phone)
  VALUES (
    NEW.id,
    NEW.raw_user_meta_data->>'username',
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'avatar_url',
    COALESCE(NEW.raw_user_meta_data->>'role', 'user'),
    NEW.email,
    NEW.raw_user_meta_data->>'phone'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger: On Auth User Created
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
