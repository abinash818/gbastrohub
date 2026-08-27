import { useEffect } from 'react';
import './Legal.css';

const PrivacyPolicy = () => {
  useEffect(() => {
    window.scrollTo(0, 0);
  }, []);

  return (
    <div className="legal-page">
      <div className="container">
        <h1>Privacy Policy</h1>
        <div className="legal-content">
          <p>Last updated: {new Date().toLocaleDateString()}</p>

          <h2>1. Information We Collect</h2>
          <p>We collect information you provide directly to us, such as your name, email address, phone number, and any details you share during consultations or matrimony profile creation securely.</p>

          <h2>2. How We Use Your Information</h2>
          <p>Your information is used strictly to provide and improve our services, process bookings, operate the matchmaking process appropriately, and communicate with you effectively.</p>

          <h2>3. Data Protection</h2>
          <p>We implement robust security measures securely via standard encryption guidelines to protect your personal identity against unauthorized access, alteration, or disclosure.</p>

          <h2>4. Sharing of Information</h2>
          <p>We do not sell, trade, or rent your personal information to third parties. Data points may be shared only with trusted partners assisting us in operating our website under heavy confidentiality agreements.</p>

          <h2>5. Contact Us</h2>
          <p>If you have any questions about this Privacy Policy, please use the Contact page on our platform.</p>
        </div>
      </div>
    </div>
  );
};

export default PrivacyPolicy;
