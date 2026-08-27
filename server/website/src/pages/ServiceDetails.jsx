import React, { useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import { allServices } from '../data/servicesData';
import './ServiceDetails.css';

const ServiceDetails = () => {
  const { id } = useParams();
  const service = allServices.find((s) => s.id === parseInt(id));

  useEffect(() => {
    window.scrollTo(0, 0);
  }, []);

  if (!service) {
    return (
      <div className="container min-h-screen text-center py-20">
        <h2>Service Not Found</h2>
        <Link to="/" className="btn btn-primary mt-4">Back to Home</Link>
      </div>
    );
  }

  return (
    <div className="service-details-page">
      <div className="container">
        <Link to="/" className="back-link">
          &larr; Back to Services | சேவைகளுக்குத் திரும்பு
        </Link>
        
        <div className="details-header">
          <div className="icon-badge">{service.icon}</div>
          <h1 className="details-title">{service.title}</h1>
          <p className="details-desc">{service.description}</p>
        </div>

        <div className="details-content">
          <div className="benefits-section">
            <h2>Detailed Benefits <span>| விரிவான நன்மைகள்</span></h2>
            <div className="benefits-grid">
              {service.benefits.map((benefit, idx) => (
                <div key={idx} className="benefit-card">
                  <div className="benefit-icon">✨</div>
                  <div className="benefit-text">
                    <h3>{benefit}</h3>
                    <p>Experience the profound transformation through this ancient practice. | இந்த பழமையான பயிற்சியின் மூலம் ஆழமான மாற்றத்தை அனுபவிக்கவும்.</p>
                  </div>
                </div>
              ))}
            </div>
          </div>

          <div className="video-section">
            <h2>Author Insights <span>| ஆசிரியரின் விளக்கங்கள்</span></h2>
            <div className="video-container">
              {/* Placeholder for exactly 40 seconds author video */}
              <iframe 
                width="100%" 
                height="100%" 
                src="https://www.youtube.com/embed/dQw4w9WgXcQ?start=0&end=40" 
                title="Author Video" 
                frameBorder="0" 
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
                allowFullScreen
              ></iframe>
            </div>
            <p className="video-desc">
              Watch a 40-second overview mapping the intricate secrets and values directly from our expert author. | எங்கள் நிபுணரான ஆசிரியரிடமிருந்து இத்துறையின் ரகசியங்கள் மற்றும் மதிப்புகளை விளக்கும் 40-வினாடி காணொளியைக் கண்டுகளியுங்கள்.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ServiceDetails;
