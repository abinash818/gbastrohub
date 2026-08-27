import React, { useState, useEffect } from 'react';
import { supabase } from '../supabaseClient';
import { useNavigate } from 'react-router-dom';
import PaymentGateway from '../components/PaymentGateway';
import Toast from '../components/Toast';
import './ProfileSettings.css';

const ProfileSettings = () => {
  const navigate = useNavigate();
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  
  // Basic Info State
  const [basicInfo, setBasicInfo] = useState({
    full_name: '',
    phone: '',
    email: ''
  });
  const [savingBasicInfo, setSavingBasicInfo] = useState(false);
  const [toast, setToast] = useState(null);

  // Biodata State
  const [hasBiodata, setHasBiodata] = useState(false);
  const [biodataDetails, setBiodataDetails] = useState(null);

  // Payment Setup
  const [showPayment, setShowPayment] = useState(false);

  useEffect(() => {
    fetchUserData();
  }, []);

  const fetchUserData = async () => {
    setLoading(true);
    try {
      const { data: { session } } = await supabase.auth.getSession();
      if (!session) {
        navigate('/login');
        return;
      }
      setUser(session.user);

      // Fetch basic profile info
      const { data: profileData, error: profileError } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', session.user.id)
        .single();

      if (!profileError && profileData) {
        setBasicInfo({
          full_name: profileData.full_name || session.user.user_metadata?.full_name || '',
          phone: profileData.phone || '',
          email: profileData.email || session.user.email || ''
        });
      }

      // Fetch matrimony biodata
      const { data: matrimonyData, error: matrimonyError } = await supabase
        .from('matrimony_profiles')
        .select('*')
        .eq('user_id', session.user.id)
        .maybeSingle();

      if (matrimonyData) {
        setHasBiodata(true);
        setBiodataDetails(matrimonyData);
      } else {
        setHasBiodata(false);
      }
    } catch (err) {
      console.error('Error fetching profile settings:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleBasicInfoChange = (e) => {
    setBasicInfo({ ...basicInfo, [e.target.name]: e.target.value });
  };

  const saveBasicInfo = async (e) => {
    e.preventDefault();
    setSavingBasicInfo(true);
    try {
      const { error } = await supabase
        .from('profiles')
        .update({
          full_name: basicInfo.full_name,
          phone: basicInfo.phone
        })
        .eq('id', user.id);

      if (error) {
        // If row doesn't exist, try insert (though our trigger should have created it)
        await supabase.from('profiles').insert([{
           id: user.id,
           full_name: basicInfo.full_name,
           phone: basicInfo.phone,
           email: basicInfo.email
        }]);
      }
      setToast({ message: 'Basic information updated successfully!', type: 'success' });
    } catch (err) {
      console.error('Error saving basic info', err);
      setToast({ message: 'Failed to update basic information.', type: 'error' });
    } finally {
      setSavingBasicInfo(false);
    }
  };

  const handlePaymentSuccess = () => {
    setShowPayment(false);
    // Redirect to Biodata Maker (Create Profile Flow)
    navigate('/matrimony/create-profile');
  };

  if (loading) {
    return (
      <div className="ps-container loading">
        <div className="ps-spinner"></div>
        <p>Loading Profile Data...</p>
      </div>
    );
  }

  return (
    <div className="ps-page">
      <div className="ps-header">
        <div className="container">
          <h1>Profile Settings</h1>
          <p>Manage your account details and matrimony biodata</p>
        </div>
      </div>

      <div className="container ps-content">
        
        {/* Section 1: Basic Details */}
        <div className="ps-card">
          <div className="ps-card-header">
            <span className="ps-icon">👤</span>
            <h2>Basic Details</h2>
          </div>
          <p className="ps-help-text">Update your primary contact information here.</p>
          
          <form className="ps-form" onSubmit={saveBasicInfo}>
            <div className="ps-form-group">
              <label>Full Name</label>
              <input 
                type="text" 
                name="full_name" 
                value={basicInfo.full_name} 
                onChange={handleBasicInfoChange} 
                required 
                placeholder="Enter your full name" 
              />
            </div>
            
            <div className="ps-form-group">
              <label>Phone Number</label>
              <input 
                type="tel" 
                name="phone" 
                value={basicInfo.phone} 
                onChange={handleBasicInfoChange} 
                required 
                placeholder="Enter your mobile number" 
              />
            </div>

            <div className="ps-form-group">
              <label>Email Address</label>
              <input 
                type="email" 
                name="email" 
                value={basicInfo.email} 
                disabled 
                className="disabled-input" 
              />
              <small>Email address is linked to your Google Account and cannot be changed here.</small>
            </div>

            <button type="submit" className="ps-save-btn" disabled={savingBasicInfo}>
              {savingBasicInfo ? 'Saving...' : 'Save Basic Details'}
            </button>
          </form>
        </div>

        {/* Section 2: Matrimony Biodata */}
        <div className="ps-card ps-biodata-card">
          <div className="ps-card-header">
            <span className="ps-icon">💍</span>
            <h2>Matrimony Biodata</h2>
          </div>

          {hasBiodata ? (
            <div className="ps-biodata-active">
              <div className="ps-status-badge success">Active Profile</div>
              <div className="ps-biodata-summary">
                <p><strong>Name:</strong> {biodataDetails?.name}</p>
                <p><strong>Age:</strong> {biodataDetails?.age}</p>
                <p><strong>Location:</strong> {biodataDetails?.location}</p>
                <p><strong>Marital Status:</strong> {biodataDetails?.marital_status}</p>
              </div>
              <p className="ps-help-text mt">Your biodata is actively listed on AadhiGuru Matrimony.</p>
              <button className="ps-outline-btn" onClick={() => navigate('/matrimony?created=true')}>
                View Matrimony Matches
              </button>
            </div>
          ) : (
            <div className="ps-biodata-missing">
              <div className="ps-status-badge warning">No Biodata Found</div>
              <p className="ps-help-text mt">You have not created a matrimony biodata yet. To use our matrimony services and connect with matches, you need an accepted format biodata.</p>
              
              <div className="ps-maker-promo">
                <h3>AadhiGuru Biodata Maker</h3>
                <p>Create a beautiful, astrologically-aligned biodata format instantly. Acceptable across all traditional networks.</p>
                <div className="ps-price-tag">
                  <span className="ps-original-price">₹99</span>
                  <span className="ps-offer-price">FREE</span>
                </div>
                <button className="ps-primary-btn" onClick={() => navigate('/matrimony/create-profile')}>
                  Create Your Biodata 
                </button>
              </div>
            </div>
          )}
        </div>

      </div>

      {showPayment && (
        <PaymentGateway 
          amount={9} 
          customerName={basicInfo.full_name}
          customerPhone={basicInfo.phone}
          onClose={() => setShowPayment(false)} 
          onPaymentSuccess={handlePaymentSuccess} 
        />
      )}
      {toast && <Toast message={toast.message} type={toast.type} onClose={() => setToast(null)} />}
    </div>
  );
};

export default ProfileSettings;
