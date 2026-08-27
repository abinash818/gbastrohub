import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { action, bookingDetails, userPhone } = await req.json();

    const accountSid = Deno.env.get('TWILIO_ACCOUNT_SID');
    const authToken = Deno.env.get('TWILIO_AUTH_TOKEN');
    const twilioNumber = Deno.env.get('TWILIO_PHONE_NUMBER');
    const adminPhone = Deno.env.get('ADMIN_PHONE') || '+917305801121';

    if (!accountSid || !authToken || !twilioNumber) {
      throw new Error('Twilio credentials completely missing in environment variables');
    }

    const authHeader = `Basic ${btoa(`${accountSid}:${authToken}`)}`;
    const twilioUrl = `https://api.twilio.com/2010-04-01/Accounts/${accountSid}/Messages.json`;

    let toPhone = '';
    let message = '';

    if (action === 'notify-admin') {
      // Send Alert to Admin/Author
      toPhone = adminPhone;
      const timeStr = bookingDetails.time || 'To be confirmed';
      message = `🔔 *New Appointment Request*\n\n*Service:* ${bookingDetails.serviceName}\n*Client:* ${bookingDetails.userName}\n*Date:* ${bookingDetails.date}\n*Time:* ${timeStr}\n\n*Action Required:*\nReply with the word *ACCEPT* to instantly approve this booking!`;
    } else if (action === 'notify-user') {
      // Send Approval Alert to User
      toPhone = userPhone;
      message = `✅ *Appointment Approved!*\n\nHi ${bookingDetails.userName}, your booking for *${bookingDetails.serviceName}* on ${bookingDetails.date} at ${bookingDetails.time} has been confirmed securely by Sri AadhiGuru.\n\nPlease arrive on time. Thank you!`;
    } else {
      throw new Error('Invalid action provided to Twilio edge function');
    }

    // Format phone numbers for WhatsApp (ensure it has whatsapp: prefix and country code)
    if (!toPhone.startsWith('+')) {
      toPhone = '+91' + toPhone; // Default to India if no code provided
    }

    const payload = new URLSearchParams();
    payload.append('To', `whatsapp:${toPhone}`);
    payload.append('From', `whatsapp:${twilioNumber}`);
    payload.append('Body', message);

    const twilioResponse = await fetch(twilioUrl, {
      method: 'POST',
      headers: {
        'Authorization': authHeader,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: payload,
    });

    const twilioData = await twilioResponse.json();

    if (!twilioResponse.ok) {
      console.error('Twilio Error:', twilioData);
      throw new Error(`Twilio rejected the message: ${twilioData.message}`);
    }

    return new Response(JSON.stringify({ success: true, messageId: twilioData.sid }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    });
  } catch (error) {
    console.error('Edge Function Error:', error.message);
    return new Response(JSON.stringify({ success: false, error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    });
  }
});
