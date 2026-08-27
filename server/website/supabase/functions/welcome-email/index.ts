import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY')

serve(async (req) => {
  const { record } = await req.json()

  // Prepare the Welcome Email HTML
  const emailHtml = `
    <div style="font-family: sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #eee; border-radius: 10px;">
      <h2 style="color: #1f8a70; text-align: center;">Welcome to Sri AadhiGuru Education!</h2>
      <p>Namaste <strong>${record.full_name || record.username || 'User'}</strong>,</p>
      <p>Thank you for creating an account with us. Your journey towards spiritual wisdom and professional excellence begins today!</p>
      
      <div style="background: #f9f9f9; padding: 15px; border-radius: 8px; margin: 20px 0;">
        <p style="margin: 0;"><strong>Logged in as:</strong> ${record.email}</p>
        <p style="margin: 5px 0 0 0;"><strong>Phone:</strong> ${record.phone || 'Not provided'}</p>
      </div>

      <p>You can now book astrology consultations, join our yoga classes, or explore our traditional store.</p>
      
      <a href="https://aadhiguru.in/dashboard" style="display: block; width: 200px; margin: 30px auto; padding: 12px; background: #1f8a70; color: white; text-decoration: none; text-align: center; border-radius: 5px; font-weight: bold;">Go to My Dashboard</a>
      
      <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;" />
      <p style="font-size: 0.8rem; color: #777; text-align: center;">
        Sri AadhiGuru Education <br />
        Thirumullaivoyal, Chennai, Tamil Nadu
      </p>
    </div>
  `

  try {
    const res = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${RESEND_API_KEY}`,
      },
      body: JSON.stringify({
        from: 'Sri AadhiGuru Education <welcome@aadhiguru.in>',
        to: [record.email],
        subject: 'Welcome to Sri AadhiGuru Education!',
        html: emailHtml,
      }),
    })

    const data = await res.json()
    return new Response(JSON.stringify(data), { status: 200 })
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 500 })
  }
})
