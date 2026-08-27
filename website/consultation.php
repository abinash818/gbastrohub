<!DOCTYPE html>
<html lang="en">
<head>
 <meta charset="UTF-8">
 <meta name="viewport" content="width=device-width, initial-scale=1.0">
 <title>Book Consultation | Sri AadhiGuru Education</title>
 <link rel="stylesheet" href="style.css">
 <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;700&family=Playfair+Display:wght@700&display=swap" rel="stylesheet">
 <style>
 .consultation-hero {
 background: linear-gradient(135deg, #14142b, #1a1540);
 padding: 60px 0;
 text-align: center;
 }
 .consultation-hero h1 { margin-bottom: 10px; }
 .consultation-hero p {
 color: var(--text-gray);
 max-width: 600px;
 margin: 0 auto;
 }

 .consultation-grid {
 display: grid;
 grid-template-columns: 1fr 1fr;
 gap: 50px;
 max-width: 1000px;
 margin: 0 auto;
 align-items: start;
 }

 .plan-summary {
 background: var(--secondary-bg);
 border-radius: 16px;
 padding: 35px;
 border: 1px solid #2a2a50;
 }

 .plan-summary h3 {
 margin-bottom: 20px;
 text-align: center;
 }

 .plan-detail {
 display: flex;
 justify-content: space-between;
 padding: 12px 0;
 border-bottom: 1px solid rgba(255,255,255,0.05);
 }
 .plan-detail .label { color: var(--text-gray); }
 .plan-detail .value { color: var(--text-white); font-weight: 600; }
 .plan-total {
 display: flex;
 justify-content: space-between;
 padding: 20px 0 0;
 font-size: 1.3rem;
 }
 .plan-total .value {
 color: var(--accent-gold);
 font-size: 1.8rem;
 font-family: var(--font-heading);
 }

 .form-card {
 background: #1a1a35;
 border-radius: 16px;
 padding: 35px;
 border: 1px solid #2a2a50;
 }
 .form-card h3 {
 margin-bottom: 25px;
 text-align: center;
 }
 .consultation-form {
 display: grid;
 gap: 15px;
 }
 .consultation-form input,
 .consultation-form textarea,
 .consultation-form select {
 padding: 14px 18px;
 background: #0f0f22;
 border: 1px solid #2a2a50;
 color: var(--text-white);
 border-radius: 10px;
 font-family: var(--font-main);
 font-size: 0.95rem;
 width: 100%;
 outline: none;
 transition: border-color 0.3s;
 }
 .consultation-form input:focus,
 .consultation-form textarea:focus,
 .consultation-form select:focus {
 border-color: var(--accent-gold);
 }
 .consultation-form textarea {
 resize: vertical;
 min-height: 80px;
 }
 .consultation-form .btn {
 width: 100%;
 text-align: center;
 margin-top: 5px;
 }

 .secure-note {
 text-align: center;
 margin-top: 15px;
 color: var(--text-gray);
 font-size: 0.85rem;
 }

 @media (max-width: 768px) {
 .consultation-grid {
 grid-template-columns: 1fr;
 }
 }
 </style>
</head>
<body>

 <!-- Consultation Hero -->
 <section class="consultation-hero">
 <div class="container">
 <h1>Book Your Consultation</h1>
 <p>Fill in your birth details and complete payment to secure your consultation slot with Mr. Karunagaran.</p>
 </div>
 </section>

 <!-- Consultation Form -->
 <section>
 <div class="container">
 <div class="consultation-grid">
 <!-- Plan Summary -->
 <div class="plan-summary" id="planSummary">
 <h3>Selected Plan</h3>
 <div id="planDetails">
 <div class="plan-detail">
 <span class="label">Plan</span>
 <span class="value" id="summaryName">Quick Question</span>
 </div>
 <div class="plan-detail">
 <span class="label">Duration</span>
 <span class="value" id="summaryDuration">WhatsApp Response</span>
 </div>
 <div class="plan-detail">
 <span class="label">Includes</span>
 <span class="value" id="summaryIncludes">One question answer</span>
 </div>
 <div class="plan-total">
 <span class="label">Amount</span>
 <span class="value" id="summaryPrice">₹99</span>
 </div>
 </div>
 </div>

 <!-- Form -->
 <div class="form-card">
 <h3>Enter Your Birth Details</h3>
 <form action="payment_init.php" method="POST" class="consultation-form">
 <input type="hidden" name="plan_id" id="selected-plan" value="99">

 <label style="color: var(--text-gray); font-size: 0.9rem; margin-bottom: -5px;">Select Plan *</label>
 <select name="plan_id_display" id="planSelect" required onchange="updatePlan()">
 <option value="99">Quick Question — ₹99 (WhatsApp)</option>
 <option value="499">Basic Consultation — ₹499 (15 Min)</option>
 <option value="999">Detailed Consultation — ₹999 (30 Min)</option>
 <option value="1499">Premium Horoscope — ₹1499 (45 Min)</option>
 <option value="2999">Annual Plan — ₹2999 (60 Min)</option>
 </select>

 <input type="text" name="name" placeholder="Full Name *" required>
 <input type="tel" name="phone" placeholder="Phone Number *" required>
 <input type="date" name="dob" placeholder="Date of Birth (DD/MM/YYYY) *" required>
 <input type="time" name="tob" placeholder="Time of Birth *" required>
 <input type="text" name="pob" placeholder="Place of Birth (City) *" required>

 <button type="submit" class="btn btn-primary" id="submit-btn">Pay ₹99 & Book Now</button>
 </form>
 <p class="secure-note">🔒 Secure payment powered by PhonePe. Your data is safe.</p>
 </div>
 </div>
 </div>
 </section>

 <footer style="padding: 40px 0; text-align: center; color: var(--text-gray); border-top: 1px solid #2a2a50; margin-bottom: 80px;">
 <div class="container">
 <p><strong>Sri AadhiGuru Education</strong> | Prop: Mr. Karunagaran</p>
 <p style="font-size: 0.85rem; margin-top: 5px;">48/29, N Mada St, near Masilamanieswarar Temple, Thirumullaivoyal, Chennai 600062</p>
 <p style="margin-top: 15px;">
 <a href="terms.php" style="color: var(--accent-gold); text-decoration: none; margin: 0 10px;">Terms</a> |
 <a href="privacy.php" style="color: var(--accent-gold); text-decoration: none; margin: 0 10px;">Privacy</a> |
 <a href="refund.php" style="color: var(--accent-gold); text-decoration: none; margin: 0 10px;">Refund</a>
 </p>
 <p style="margin-top: 15px; font-size: 0.85rem;">&copy; 2026 Sri AadhiGuru Education. All Rights Reserved.</p>
 </div>
 </footer>

 <!-- Lead Funnel Bar -->
 <div class="lead-bar">
 <div class="container">
 <strong>Just ₹99?</strong> Get your answer on WhatsApp now.
 <a href="https://wa.me/919600666225?text=Hello%20Sir%2C%20I%20want%20to%20ask%20a%20quick%20question%20for%20%2399." class="btn btn-dark">Ask Now</a>
 </div>
 </div>

 <!-- WhatsApp Floating Button -->
 <a href="https://wa.me/919600666225?text=Hello%20Sir%2C%20I%20am%20interested%20in%20astrology%20consultation." class="whatsapp-float" title="Chat on WhatsApp">💬</a>

 <script>
 const plans = {
 '99': { name: 'Quick Question', duration: 'WhatsApp Response', includes: 'One question answer', price: '₹99' },
 '499': { name: 'Basic Consultation', duration: '15 Minutes', includes: 'Phone call + basic horoscope', price: '₹499' },
 '999': { name: 'Detailed Consultation', duration: '30 Minutes', includes: 'In-depth analysis + remedies', price: '₹999' },
 '1499': { name: 'Premium Horoscope', duration: '45 Minutes', includes: 'Complete horoscope + remedies', price: '₹1499' },
 '2999': { name: 'Annual Plan', duration: '60 Minutes', includes: 'Full year predictions + monthly guidance', price: '₹2999' }
 };

 function updatePlan() {
 const planId = document.getElementById('planSelect').value;
 document.getElementById('selected-plan').value = planId;
 document.getElementById('submit-btn').innerText = 'Pay ' + plans[planId].price + ' & Book Now';
 document.getElementById('summaryName').innerText = plans[planId].name;
 document.getElementById('summaryDuration').innerText = plans[planId].duration;
 document.getElementById('summaryIncludes').innerText = plans[planId].includes;
 document.getElementById('summaryPrice').innerText = plans[planId].price;
 }
 </script>
</body>
</html>
