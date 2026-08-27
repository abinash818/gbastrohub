import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { supabase } from '../supabaseClient';
import './AppointmentForm.css';
import SuccessModal from './SuccessModal';
import Toast from './Toast';

const AppointmentForm = () => {
  const [showSuccess, setShowSuccess] = useState(false);
  const [loading, setLoading] = useState(false);
  const [toast, setToast] = useState(null);
  const [formData, setFormData] = useState({
    fullName: '',
    phone: '',
    email: '',
    date: '',
    purpose: '',
    notes: ''
  });

  const handleChange = (e) => {
    const { name, value } = e.target;
    if (name) {
      setFormData(prev => ({ ...prev, [name]: value }));
    } else {
      // For the select or date if they don't have name (I will add names)
      setFormData(prev => ({ ...prev, [e.target.dataset.name]: value }));
    }
  };

  const navigate = useNavigate();

  const handleBooking = async (e) => {
    e.preventDefault();
    
    const userPhone = localStorage.getItem('userPhone');
    if (!userPhone) {
      if (window.confirm("You need to login or sign up to book an appointment. Proceed to Login?")) {
        navigate('/login');
      }
      return;
    }

    setLoading(true);

    try {
      const { error } = await supabase
        .from('bookings')
        .insert([{
          full_name: formData.fullName,
          gender: 'Not Specified', // Default as it's not in the form
          phone_number: formData.phone,
          calling_location: 'Web Inquiry', // Default
          meeting_location: 'Online/In-person', // Default
          purpose_of_booking: formData.purpose,
          date: formData.date,
          time_slot: 'To be confirmed', // Default
          status: 'pending',
          payment_status: 'unpaid'
        }]);

      if (error) throw error;
      
      // SEND WHATSAPP TO ADMIN
      try {
        const { data: invData, error: invError } = await supabase.functions.invoke('send-whatsapp', {
          body: {
            action: 'notify-admin',
            bookingDetails: {
              serviceName: formData.purpose,
              userName: formData.fullName,
              date: formData.date,
              time: 'To be confirmed'
            }
          }
        });
        if (invError) console.error('Supabase Function Error:', invError);
        if (invData) console.log('WhatsApp notification sent:', invData);
      } catch (err) {
        console.error('WhatsApp alert to admin failed:', err);
      }
      
      setShowSuccess(true);
      // Reset form
      setFormData({
        fullName: '',
        phone: '',
        email: '',
        date: '',
        purpose: '',
        notes: ''
      });
    } catch (error) {
      console.error('Error saving booking:', error);
      setToast({ message: 'Error saving booking: ' + error.message, type: 'error' });
    } finally {
      setLoading(false);
    }
  };

  return (
    <section id="appointment" className="section">
      <div className="container">
        <div className="appointment-wrapper">
          <div className="appointment-info">
            <p className="appointment-desc">
              Schedule an in-person or online session with our expert astrologers. Gain profound insights into your health, wealth, and future path.
            </p>
            <div className="contact-info">
              <div className="contact-item">
                <span className="contact-icon">📞</span>
                <span>+91 9600 666 225</span>
              </div>
              <div className="contact-item">
                <span className="contact-icon">✉️</span>
                <span>aadhiguru.com@gmail.com</span>
              </div>
              <div className="contact-item">
                <span className="contact-icon">📍</span>
                <span>48/29, N Mada St, Thirumullaivoyal, Chennai</span>
              </div>
            </div>
          </div>
          
          <div className="appointment-form-box">
            <h3 className="form-title">Request a Callback</h3>
            <p className="form-subtitle">Fill in your details and our team will get back to you shortly.</p>
            <form className="form" onSubmit={handleBooking}>
              <div className="form-group">
                <input type="text" name="fullName" placeholder="Full Name *" required value={formData.fullName} onChange={handleChange} />
              </div>
              <div className="form-row">
                <div className="form-group">
                  <input type="tel" name="phone" placeholder="Phone Number *" required value={formData.phone} onChange={handleChange} />
                </div>
                <div className="form-group">
                  <input type="email" name="email" placeholder="Email Address" value={formData.email} onChange={handleChange} />
                </div>
              </div>
              <div className="form-row">
                <div className="form-group">
                  <input type="date" name="date" required value={formData.date} onChange={handleChange} />
                </div>
                <div className="form-group">
                  <select name="purpose" required value={formData.purpose} onChange={handleChange}>
                    <option value="" disabled>Select Purpose *</option>
                    <option value="vastu">Vastu Consultation</option>
                    <option value="astrology">Traditional Astrology</option>
                    <option value="marriage">Marriage Matching</option>
                    <option value="prasannam">Prasannam</option>
                    <option value="other">Other Inquiry</option>
                  </select>
                </div>
              </div>
              <div className="form-group">
                <textarea name="notes" placeholder="Description / Notes" rows="4" value={formData.notes} onChange={handleChange}></textarea>
              </div>
              <button type="submit" className="btn btn-primary w-100" disabled={loading} style={{ padding: '1.25rem', marginTop: '1rem', borderRadius: 'var(--radius-full)' }}>
                {loading ? 'Reserving...' : 'Reserve Appointment Now'}
              </button>
            </form>
          </div>
        </div>
      </div>
      
      <SuccessModal 
        isOpen={showSuccess}
        onClose={() => setShowSuccess(false)}
        title="Request Received!"
        message="Thank you for booking an appointment. Our team will contact you shortly to confirm your slot."
        actionText="Done"
      />
      {toast && <Toast message={toast.message} type={toast.type} onClose={() => setToast(null)} />}
    </section>
  );
};

export default AppointmentForm;
