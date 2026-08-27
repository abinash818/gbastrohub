import { serve } from "https://deno.land/std@0.177.0/http/server.ts";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

// Helper function to generate HMAC SHA256 signature using Web Crypto API
async function generateHmacSha256(secret: string, data: string) {
  const enc = new TextEncoder();
  const key = await crypto.subtle.importKey(
    "raw",
    enc.encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"]
  );
  const signatureBuffer = await crypto.subtle.sign("HMAC", key, enc.encode(data));
  const signatureArray = Array.from(new Uint8Array(signatureBuffer));
  return signatureArray.map(b => b.toString(16).padStart(2, '0')).join('');
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { razorpay_order_id, razorpay_payment_id, razorpay_signature } = await req.json();

    if (!razorpay_order_id || !razorpay_payment_id || !razorpay_signature) {
      throw new Error('Missing required signature payload');
    }

    const keySecret = Deno.env.get('RAZORPAY_KEY_SECRET');
    if (!keySecret) {
      throw new Error('Razorpay secret not configured securely on server.');
    }

    // Razorpay signature verification logic
    // The signature must be verified by creating an HMAC SHA256 of "order_id|payment_id"
    const dataToSign = `${razorpay_order_id}|${razorpay_payment_id}`;
    const generatedSignature = await generateHmacSha256(keySecret, dataToSign);

    if (generatedSignature === razorpay_signature) {
      // Signature is legit! Proceed with marking payment as successful in the DB
      // Normally, here you connect to Supabase Client and update the user's booking/profile status.
      
      return new Response(JSON.stringify({ success: true, message: 'Payment verified successfully' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      });
    } else {
      throw new Error('Payment verification failed: Invalid Signature');
    }
  } catch (error) {
    return new Response(JSON.stringify({ success: false, error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    });
  }
});
