import { useState, useEffect, useRef } from 'react';
import './Testimonials.css';

const testimonials = [
  {
    id: 1,
    name: "Arun Kumar",
    location: "Chennai",
    text: "The Vastu consultation for my new home was eye-opening. We've felt a significant positive shift in the energy of our house since implementing the suggestions.",
    rating: 5,
    tag: "Vastu"
  },
  {
    id: 2,
    name: "Priya Rajan",
    location: "Kanchipuram",
    text: "I was struggling with chronic back pain for years. After just a few Acupuncture & Varma sessions at Sri AadhiGuru, I've seen remarkable improvement. Truly professional service.",
    rating: 5,
    tag: "Acupuncture & Varma"
  },
  {
    id: 3,
    name: "Suresh Mehra",
    location: "Online Consultation",
    text: "The KP Astrology reading was incredibly accurate. It helped me make a crucial career decision with confidence. Highly recommended for anyone seeking clarity.",
    rating: 5,
    tag: "Astrology"
  },
  {
    id: 4,
    name: "Meenakshi S.",
    location: "Chennai",
    text: "My conversational skills improved significantly through their spoken language classes. The tutors are patient and highly knowledgeable.",
    rating: 5,
    tag: "Spoken Languages"
  }
];

const Testimonials = () => {
  const [isPaused, setIsPaused] = useState(false);
  const scrollRef = useRef(null);

  useEffect(() => {
    const scrollContainer = scrollRef.current;
    if (!scrollContainer || isPaused) return;

    const scrollWidth = scrollContainer.scrollWidth;
    
    const scrollInterval = setInterval(() => {
      if (scrollContainer.scrollLeft >= (scrollWidth / 2)) {
        // Reset to half-way point without user noticing
        scrollContainer.scrollLeft = 0;
      } else {
        scrollContainer.scrollLeft += 1; // Control the smoothness by changing this increment
      }
    }, 25); // Speed Control

    return () => clearInterval(scrollInterval);
  }, [isPaused]);

  return (
    <section className="section bg-surface testimonials-section">
      <div className="container">
        <h2 className="section-title">What Our Clients Say | வாடிக்கையாளர் மதிப்புரைகள்</h2>
        <p className="section-subtitle">Real Stories of Transformation</p>

        <div className="slider-container">
          <div 
            className="testimonials-slider"
            ref={scrollRef}
            onMouseEnter={() => setIsPaused(true)}
            onMouseLeave={() => setIsPaused(false)}
            onMouseDown={() => setIsPaused(true)}
            onMouseUp={() => setIsPaused(false)}
          >
            {/* Repeat testimonials for seamless loop experience */}
            {[...testimonials, ...testimonials].map((item, index) => (
              <div key={`${item.id}-${index}`} className="testimonial-card">
                <div className="quote-icon">"</div>
                <div className="rating">
                  {[...Array(item.rating)].map((_, i) => (
                    <span key={i} className="star">★</span>
                  ))}
                </div>
                <p className="testimonial-text">{item.text}</p>
                <div className="testimonial-footer">
                  <div className="client-info">
                    <span className="client-name">{item.name}</span>
                    <span className="client-location">{item.location}</span>
                  </div>
                  <span className="testimonial-tag">{item.tag}</span>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
};

export default Testimonials;
