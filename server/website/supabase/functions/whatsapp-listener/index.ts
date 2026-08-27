import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3';

Deno.serve(async (req) => {
  try {
    // Twilio sends data as URL Encoded form data
    const formData = await req.formData();
    const bodyStr = formData.get('Body')?.toString().trim().toUpperCase() || '';
    const fromPhone = formData.get('From')?.toString() || ''; // e.g., whatsapp:+919600666225

    const adminPhone = Deno.env.get('ADMIN_PHONE') || '+919600666225';
    const targetAdmin = `whatsapp:${adminPhone.startsWith('+') ? adminPhone : '+' + adminPhone}`;

    // Security Verification: Only the Admin can accept bookings!
    if (fromPhone !== targetAdmin) {
      console.error(`Unauthorized number attempted to command: ${fromPhone}`);
      return new Response('Unauthorized', { status: 403 });
    }

    // Connect to Supabase using Edge Function defaults
    const supabaseUrl = Deno.env.get('SUPABASE_URL') || '';
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || '';
    const supabase = createClient(supabaseUrl, supabaseKey);

    // If Admin replies ACCEPT or REJECT
    if (bodyStr === 'ACCEPT' || bodyStr === 'REJECT') {
      const newStatus = bodyStr === 'ACCEPT' ? 'accepted' : 'rejected';

      // 1. Find the oldest 'pending' booking to answer
      const { data: bookings, error: fetchErr } = await supabase
        .from('bookings')
        .select('*')
        .eq('status', 'pending')
        .order('created_at', { ascending: true }) // Oldest first (FIFO)
        .limit(1);

      if (fetchErr || !bookings || bookings.length === 0) {
        const errorTwiml = `<?xml version="1.0" encoding="UTF-8"?><Response><Message>No pending bookings found to ${bodyStr.toLowerCase()}.</Message></Response>`;
        return new Response(errorTwiml, { headers: { 'Content-Type': 'text/xml' } });
      }

      const activeBooking = bookings[0];

      // 2. Update the booking status in the database
      const { error: updateErr } = await supabase
        .from('bookings')
        .update({ status: newStatus })
        .eq('id', activeBooking.id);

      if (updateErr) throw updateErr;

      // 3. Notify the User immediately via Twilio API if Accepted
      if (newStatus === 'accepted') {
        const accountSid = Deno.env.get('TWILIO_ACCOUNT_SID');
        const authToken = Deno.env.get('TWILIO_AUTH_TOKEN');
        const twilioNumber = Deno.env.get('TWILIO_PHONE_NUMBER');

        if (accountSid && authToken && twilioNumber) {
          const authHeader = `Basic ${btoa(`${accountSid}:${authToken}`)}`;
          let userPhone = activeBooking.phone_number;
          if (!userPhone.startsWith('+')) userPhone = '+91' + userPhone;

          const userMessage = `✅ *Appointment Approved!*\n\nHi ${activeBooking.full_name}, your booking for *${activeBooking.purpose_of_booking}* on ${activeBooking.date} has been confirmed securely by Sri AadhiGuru.\n\nPlease arrive on time. Thank you!`;
          
          const payload = new URLSearchParams();
          payload.append('To', `whatsapp:${userPhone}`);
          payload.append('From', `whatsapp:${twilioNumber}`);
          payload.append('Body', userMessage);

          await fetch(`https://api.twilio.com/2010-04-01/Accounts/${accountSid}/Messages.json`, {
            method: 'POST',
            headers: { 'Authorization': authHeader, 'Content-Type': 'application/x-www-form-urlencoded' },
            body: payload,
          }).catch(err => console.error("Failed to notify user:", err));
        }
      }

      // 4. Return TwiML to instantly reply to the Admin
      const successTwiml = `<?xml version="1.0" encoding="UTF-8"?>
      <Response>
          <Message>Success! Booking for ${activeBooking.full_name} has been ${newStatus}.</Message>
      </Response>`;
      
      return new Response(successTwiml, { headers: { 'Content-Type': 'text/xml' }, status: 200 });
    }

    // Default TwiML if command not recognized
    const helpTwiml = `<?xml version="1.0" encoding="UTF-8"?><Response><Message>Unrecognized command. Reply with ACCEPT or REJECT to manage pending bookings.</Message></Response>`;
    return new Response(helpTwiml, { headers: { 'Content-Type': 'text/xml' }, status: 200 });

  } catch (error) {
    console.error('Webhook Error:', error);
    return new Response('Internal Server Error', { status: 500 });
  }
});
