import { useState, useEffect } from 'react';
import './SuccessModal.css';

const SuccessModal = ({ isOpen, onClose, title, message, actionText }) => {
  if (!isOpen) return null;

  return (
    <div className="success-overlay fade-in" onClick={onClose}>
      <div className="success-modal glass-effect scale-up" onClick={(e) => e.stopPropagation()}>
        <div className="success-icon-container">
          <div className="success-icon-bg"></div>
          <div className="success-icon">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round">
              <path className="check-path" d="M20 6L9 17l-5-5"></path>
            </svg>
          </div>
        </div>
        <h3 className="success-title">{title || 'Booking Confirmed!'}</h3>
        <p className="success-message">{message}</p>
        <button className="btn success-action-btn" onClick={onClose}>
          {actionText || 'Done'}
        </button>
      </div>
    </div>
  );
};

export default SuccessModal;
