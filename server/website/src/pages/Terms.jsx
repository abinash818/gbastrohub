import { useEffect } from 'react';
import './Legal.css';

const Terms = () => {
  useEffect(() => {
    window.scrollTo(0, 0);
  }, []);

  return (
    <div className="legal-page">
      <div className="container">
        <h1>Terms and Conditions</h1>
        <div className="legal-content">
          <p>Last updated: {new Date().toLocaleDateString()}</p>
          
          <h2>1. Introduction</h2>
          <p>Welcome to Sri AadhiGuru Education. By accessing or using our website and services, you agree to be bound by these Terms and Conditions.</p>

          <h2>2. Services</h2>
          <p>We provide traditional Vedic astrological services, Vastu consultations, and educational guidance. All consultations are provided to the best of our knowledge and tradition.</p>

          <h2>3. Bookings and Payments</h2>
          <p>All bookings must be confirmed by the owner. Payments are securely processed via standard protocols, and refunds are strictly subject to our cancellation guidelines at the time of booking.</p>

          <h2>4. User Responsibilities</h2>
          <p>Users must provide accurate information when booking services or updating profiles. Any misuse of the platform may result in termination of access and permanent suspension.</p>

          <h2>5. Changes to Terms</h2>
          <p>We reserve the right to modify these terms at any time. Continued use of the platform after notifications indicates clear acceptance of any such alterations.</p>
        </div>
      </div>
    </div>
  );
};

export default Terms;
