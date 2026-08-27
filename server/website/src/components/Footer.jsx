import { Link } from 'react-router-dom';
import './Footer.css';

const Footer = () => {
  return (
    <footer className="footer">
      <div className="container">
        <div className="footer-grid">
          <div className="footer-col">
            <div className="footer-logo-container">
              <img src="/images/logo-final.png" alt="GB ASTRO" className="footer-site-logo" />
              <h4 className="footer-logo">GB ASTRO</h4>
            </div>
            <p className="footer-desc">
              Providing traditional Vedic astrological services, Vastu consultations, and numeric guidance.
            </p>
          </div>
          <div className="footer-col">
            <h4 className="footer-heading">Quick Links</h4>
            <ul className="footer-links">
              <li><Link to="/">Home</Link></li>
              <li><a href="/#services">Services</a></li>
              <li><Link to="/contact">Contact Us</Link></li>
            </ul>
          </div>
          <div className="footer-col">
            <h4 className="footer-heading">Contact Info</h4>
            <address className="footer-address">
              48/29, N Mada St, near masilamanieswarar temple,<br />
              Thirumullaivoyal, Chennai 600062<br /><br />
              <strong>Phone:</strong> +91 9600 666 225<br />
              <strong>Alt:</strong> +91 9551 532 751<br />
              <strong>Email:</strong> aadhiguru.com@gmail.com
            </address>
          </div>
        </div>
        <div className="footer-bottom" style={{display: 'flex', justifyContent: 'space-between', flexWrap: 'wrap', alignItems: 'center', borderTop: '1px solid var(--color-border)', paddingTop: '1.5rem', marginTop: '2rem'}}>
          <p style={{margin: 0}}>&copy; {new Date().getFullYear()} GB ASTRO. All rights reserved.</p>
          <div className="footer-legal-links" style={{display: 'flex', gap: '1.5rem', marginTop: '1rem'}}>
            <Link to="/terms" style={{color: 'var(--color-text-muted)', fontSize: '0.9rem', textDecoration: 'none'}}>Terms & Conditions</Link>
            <Link to="/privacy" style={{color: 'var(--color-text-muted)', fontSize: '0.9rem', textDecoration: 'none'}}>Privacy Policy</Link>
          </div>
        </div>
      </div>
    </footer>
  );
};

export default Footer;
