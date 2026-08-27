import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { supabase } from '../supabaseClient';
import './Classes.css';
import SuccessModal from '../components/SuccessModal';
import Toast from '../components/Toast';

const initialClasses = [
  { id: 1, title_en: "Introduction to Vastu Shastra", title_ta: "வாஸ்து சாஸ்திரம் அறிமுகம்", date: "2026-04-10", price: 1500, attendees: 12, thumbnail: "/vastu_thumbnail.png" },
  { id: 2, title_en: "Advanced KP Astrology", title_ta: "உயர்தர கே.பி ஜோதிடம்", date: "2026-04-15", price: 3000, attendees: 8, thumbnail: "/astrology_thumbnail.png" },
  { id: 3, title_en: "Education & Extra-Curricular Consultation", title_ta: "கல்வி மற்றும் தனித்திறன் வகுப்புகள்", date: "Flexible Schedule", price: 0, attendees: 24, thumbnail: "/education_thumbnail.png" }
];

const Classes = () => {
  const [classes, setClasses] = useState(() => {
    const saved = localStorage.getItem('aadhiguru_classes');
    if (saved) {
      let parsed = JSON.parse(saved);
      // Auto-inject the education class if missing, or update it if present
      const eduIndex = parsed.findIndex(c => c.id === 3);
      if (eduIndex === -1) {
        parsed = [...parsed, initialClasses[2]];
      } else {
        // Force update existing cache to the new free consultation setting
        parsed[eduIndex] = initialClasses[2];
      }
      return parsed;
    }
    return initialClasses;
  });
  
  const [isAdmin, setIsAdmin] = useState(false);
  const [isAuthoritativeAdmin, setIsAuthoritativeAdmin] = useState(false);
  const [showModal, setShowModal] = useState(false);
  const [enrollingClass, setEnrollingClass] = useState(null);
  
  // Success Modal State
  const [showSuccess, setShowSuccess] = useState(false);
  const [successMessage, setSuccessMessage] = useState('');
  const [paymentMethod, setPaymentMethod] = useState('card');
  
  // New Class State
  const [newTitleEn, setNewTitleEn] = useState('');
  const [newTitleTa, setNewTitleTa] = useState('');
  const [newDate, setNewDate] = useState('');
  const [newPrice, setNewPrice] = useState('');
  const [newThumbnail, setNewThumbnail] = useState('');
  const [toast, setToast] = useState(null);
 
  useEffect(() => {
    // Check if current user is the authoritative admin
    const checkAdmin = async () => {
      const { data: { user } } = await supabase.auth.getUser();
      if (user?.email === 'aadhiguru.com@gmail.com') {
        setIsAuthoritativeAdmin(true);
      } else {
        setIsAuthoritativeAdmin(false);
        setIsAdmin(false); // Force exit admin mode if not admin
      }
    };
    checkAdmin();
    
    localStorage.setItem('aadhiguru_classes', JSON.stringify(classes));
  }, [classes]);

  const handleAddClass = (e) => {
    e.preventDefault();
    if (!isAuthoritativeAdmin) {
      setToast({ message: "Unauthorized: You do not have permission to manage classes.", type: 'error' });
      return;
    }
    if (!newTitleEn || !newDate || !newPrice) return;
    
    const newClass = {
      id: Date.now(),
      title_en: newTitleEn,
      title_ta: newTitleTa || newTitleEn,
      date: newDate,
      price: Number(newPrice),
      attendees: 0,
      thumbnail: newThumbnail || '/astrology_thumbnail.png'
    };
    
    setClasses([...classes, newClass]);
    setNewTitleEn(''); setNewTitleTa(''); setNewDate(''); setNewPrice(''); setNewThumbnail('');
  };

  const handleRemoveClass = (id) => {
    if (!isAuthoritativeAdmin) return;
    setClasses(classes.filter(c => c.id !== id));
  };

  const navigate = useNavigate();

  const handleEnrollClick = async (cls) => {
    const { data: { session } } = await supabase.auth.getSession();

    if (!session) {
      navigate('/login', { state: { message: `Please login or sign up to enroll in ${cls.title_en}.` } });
      return;
    }

    if (cls.price === 0) {
      // Free consultation flow
      setEnrollingClass(cls);
      setSuccessMessage(`Your consultation request for ${cls.title_en} has been received. Our mentors will contact you shortly to schedule it.`);
      setShowSuccess(true);
    } else {
      // Premium paid flow
      setEnrollingClass(cls);
      setPaymentMethod('card');
      setShowModal(true);
    }
  };

  const handlePayment = () => {
    // Show premium success modal instead of alert
    setSuccessMessage(`Payment of ₹${enrollingClass.price} successful! You are successfully enrolled in ${enrollingClass.title_en}.`);
    setShowSuccess(true);
    
    setClasses(classes.map(c => 
      c.id === enrollingClass.id ? { ...c, attendees: c.attendees + 1 } : c
    ));
    
    setShowModal(false);
    setEnrollingClass(null);
  };

  return (
    <section className="section bg-surface classes-page">
      <div className="container">
        
        <div className="classes-header">
          <div>
            <h2 className="section-title" style={{ textAlign: 'left', marginBottom: '0.5rem' }}>Astrology, Vastu & Education</h2>
            <p className="section-subtitle" style={{ textAlign: 'left', marginBottom: '2rem' }}>Learn from our Gurus & Mentors | எங்களின் நிபுணர்களிடம் கற்கவும்</p>
          </div>
          {isAuthoritativeAdmin && (
            <button 
              className={`admin-toggle ${isAdmin ? 'active' : ''}`} 
              onClick={() => setIsAdmin(!isAdmin)}
            >
              {isAdmin ? 'Exit Admin Mode' : 'Admin Mode'}
            </button>
          )}
        </div>

        {isAdmin && isAuthoritativeAdmin && (
          <div className="admin-panel mb-4">

            <h3>Add New Class | புதிய வகுப்பு</h3>
            <form className="admin-form" onSubmit={handleAddClass}>
              <div className="form-row">
                <input type="text" placeholder="Title (English)" value={newTitleEn} onChange={e => setNewTitleEn(e.target.value)} required />
                <input type="text" placeholder="Title (Tamil)" value={newTitleTa} onChange={e => setNewTitleTa(e.target.value)} />
              </div>
              <div className="form-row">
                <input type="date" value={newDate} onChange={e => setNewDate(e.target.value)} required />
                <input type="number" placeholder="Price (₹)" value={newPrice} onChange={e => setNewPrice(e.target.value)} required />
              </div>
              <div className="form-row">
                <input type="url" placeholder="Thumbnail URL (Optional)" value={newThumbnail} onChange={e => setNewThumbnail(e.target.value)} />
              </div>
              <button type="submit" className="btn btn-primary" style={{ marginTop: '1rem' }}>Add Class</button>
            </form>
          </div>
        )}

        <div className="classes-grid">
          {classes.length === 0 ? (
            <p>No classes scheduled currently.</p>
          ) : (
            classes.map(cls => (
              <div key={cls.id} className="class-card">
                <div className="class-thumbnail">
                  <div style={{ fontSize: '4rem', background: 'rgba(31, 138, 112, 0.1)', height: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center', borderRadius: '12px 12px 0 0' }}>
                    {cls.id === 3 ? '🎒' : (cls.title_en.includes('Vastu') ? '🧭' : '⭐')}
                  </div>
                </div>
                <div className="class-content">
                  <h3 className="class-title-en">{cls.title_en}</h3>
                  <h4 className="class-title-ta">{cls.title_ta}</h4>
                  
                  <div className="class-details">
                    <p><strong>Date:</strong> {cls.date}</p>
                    <p><strong>Fee:</strong> {cls.price === 0 ? <span style={{color: 'var(--color-primary)', fontWeight: 'bold'}}>Free Consultation</span> : `₹${cls.price}`}</p>
                    <p><strong>Enrolled:</strong> {cls.attendees} Students</p>
                  </div>
                </div>
                
                <div className="class-actions">
                  <button className={`btn ${cls.price === 0 ? 'btn-secondary' : 'btn-primary'} w-100`} onClick={() => handleEnrollClick(cls)}>
                    {cls.price === 0 ? 'Request Consult' : 'Apply & Pay'}
                  </button>
                  {isAdmin && (
                    <button className="btn btn-danger w-100 mt-2" onClick={() => handleRemoveClass(cls.id)}>
                      Remove Class
                    </button>
                  )}
                </div>
              </div>
            ))
          )}
        </div>

        {/* Mock Payment Modal */}
        {showModal && enrollingClass && (
          <div className="modal-overlay fade-in" onClick={() => setShowModal(false)}>
            <div className="modal-content scale-up" onClick={(e) => e.stopPropagation()}>
              <div className="modal-header">
                <h3>Checkout | கட்டணம்</h3>
                <button className="close-btn" onClick={() => setShowModal(false)}>&times;</button>
              </div>
              
              <div className="order-summary">
                <span className="summary-label">Applying for:</span>
                <span className="summary-title">{enrollingClass.title_en}</span>
                <div className="summary-total">
                  <span>Total Amount</span>
                  <span className="price-value">₹{enrollingClass.price}</span>
                </div>
              </div>
              
              <div className="payment-method-toggle">
                <button 
                  className={`method-btn ${paymentMethod === 'card' ? 'active' : ''}`}
                  onClick={() => setPaymentMethod('card')}
                >
                  💳 Card
                </button>
                <button 
                  className={`method-btn ${paymentMethod === 'upi' ? 'active' : ''}`}
                  onClick={() => setPaymentMethod('upi')}
                >
                  📱 UPI
                </button>
              </div>
              
              <div className="payment-form">
                {paymentMethod === 'card' ? (
                  <>
                    <div className="input-group">
                      <label>Cardholder Name</label>
                      <input type="text" placeholder="e.g. John Doe" defaultValue="Demo User" />
                    </div>
                    
                    <div className="input-group">
                      <label>Card Number</label>
                      <input type="text" placeholder="XXXX XXXX XXXX XXXX" defaultValue="XXXX XXXX XXXX XXXX" />
                    </div>
                    
                    <div className="form-row">
                      <div className="input-group">
                        <label>Expiry (MM/YY)</label>
                        <input type="text" placeholder="MM/YY" defaultValue="12/26" />
                      </div>
                      <div className="input-group">
                        <label>Security Code</label>
                        <input type="text" placeholder="CVC" defaultValue="123" />
                      </div>
                    </div>
                  </>
                ) : (
                  <div className="upi-payment-section">
                    <div className="input-group">
                      <label>Enter your UPI ID</label>
                      <input type="text" placeholder="username@ybl" />
                    </div>
                    <div className="upi-divider">
                      <span>OR</span>
                    </div>
                    <div className="upi-qr-placeholder">
                      <div className="mock-qr-code">
                        <span style={{ fontSize: '3.5rem', lineHeight: 1 }}>🔲</span>
                        <p>Scan with any UPI app</p>
                      </div>
                      <p className="upi-apps">GPay · PhonePe · Paytm · BHIM</p>
                    </div>
                  </div>
                )}
              </div>

              <div className="modal-actions">
                <button className="btn cancel-btn" onClick={() => setShowModal(false)}>Cancel</button>
                <button className="btn pay-btn" onClick={handlePayment}>Pay & Enroll</button>
              </div>
            </div>
          </div>
        )}
        
        <SuccessModal 
          isOpen={showSuccess}
          onClose={() => {
            setShowSuccess(false);
            setEnrollingClass(null);
          }}
          title="Enrollment Successful!"
          message={successMessage}
          actionText="View Classes"
        />
        
        {toast && <Toast message={toast.message} type={toast.type} onClose={() => setToast(null)} />}
      </div>
    </section>
  );
};

export default Classes;
