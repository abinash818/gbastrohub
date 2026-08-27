import { useNavigate } from 'react-router-dom';
import './Software.css';

const Software = () => {
  const navigate = useNavigate();

  return (
    <div className="software-page">
      {/* Hero Section */}
      <section className="software-hero">
        <div className="container software-hero-container">
          <div className="software-hero-content">
            <div className="badge-exclusive">App Exclusive ✦</div>
            <h1 className="software-title">AadhiGuru Pro Astrology Studio</h1>
            <p className="software-subtitle">
              The ultimate high-precision astrology desktop & mobile powerhouse. Now integrated exclusively within the AadhiGuru Ecosystem.
            </p>

            <div className="hero-actions">
              <button className="btn btn-primary btn-glow" onClick={() => window.open('https://play.google.com/store/apps/details?id=co.jones.ctqok&pcampaignid=web_share', '_blank')}>
                📱 Get the App
              </button>
              <a href="#features" className="btn btn-outline-white">Explore Features</a>
            </div>
            <p className="license-info">✓ Included with App Membership • Sync across devices • Cloud Backup</p>
          </div>
          <div className="software-hero-visual">
            <div className="poster-frame">
              <img src="/images/software-poster.png" alt="AadhiGuru Software Poster" className="software-poster-img" />
              <div className="poster-glow"></div>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section id="features" className="software-features section bg-surface">
        <div className="container">
          <h2 className="section-title">Professional Tools, Now in Your Pocket</h2>
          <p className="section-subtitle">The same precision you trust, enhanced with mobile mobility</p>
          
          <div className="features-grid">
            <div className="feature-card">
              <div className="f-icon">⭐</div>
              <h3>Advanced KP System</h3>
              <p>Pin-point accurate stellar astrology tools with sub-lord interpretations and transit charting.</p>
            </div>
            <div className="feature-card">
              <div className="f-icon">💍</div>
              <h3>Marriage Matching Pro</h3>
              <p>Generate deep Porutham reports comparing multiple charts instantly with visual scoring.</p>
            </div>
            <div className="feature-card">
              <div className="f-icon">🖨️</div>
              <h3>White-label Reports</h3>
              <p>Print beautiful multi-page PDF horoscopes with your own branding, logo, and contact details.</p>
            </div>
            <div className="feature-card">
              <div className="f-icon">⏱️</div>
              <h3>Prasannam Modules</h3>
              <p>Includes Jamakkol, Thamboola, and Ashta Mangala Prasannam specific dynamic calculators.</p>
            </div>
            <div className="feature-card">
              <div className="f-icon">🏠</div>
              <h3>Vastu Grid Overlay</h3>
              <p>Upload floor plans and automatically overlay Vastu energy grids and planetary directions.</p>
            </div>
            <div className="feature-card">
              <div className="f-icon">🔒</div>
              <h3>Secure Offline Mode</h3>
              <p>Works 100% offline. Client data stays local on your machine ensuring maximum privacy.</p>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
};

export default Software;

