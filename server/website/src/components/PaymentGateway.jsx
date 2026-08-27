import { useState, useEffect } from 'react';
import './PaymentGateway.css';

const PaymentGateway = ({ amount, onPaymentSuccess, onClose, customerName, customerPhone }) => {
  const [isProcessing, setIsProcessing] = useState(true);
  const [errorStatus, setErrorStatus] = useState(null);

  useEffect(() => {
    const loadScript = (src) => {
      return new Promise((resolve) => {
        const script = document.createElement('script');
        script.src = src;
        script.onload = () => resolve(true);
        script.onerror = () => resolve(false);
        document.body.appendChild(script);
      });
    };

    const displayRazorpay = async () => {
      try {
        setErrorStatus(null);
        setIsProcessing(true);
        
        const res = await loadScript('https://checkout.razorpay.com/v1/checkout.js');
        if (!res) {
          setErrorStatus('Failed to load Razorpay SDK. Please check your internet connection.');
          setIsProcessing(false);
          return;
        }

        const razorpayKey = import.meta.env.VITE_RAZORPAY_KEY_ID;
        
        if (!razorpayKey || razorpayKey === 'YOUR_RAZORPAY_KEY_ID') {
          setErrorStatus('Please add your VITE_RAZORPAY_KEY_ID to your .env file.');
          setIsProcessing(false);
          return;
        }

        // Configuration for "Direct Checkout" (Easier for testing)
        const options = {
          key: razorpayKey,
          amount: amount * 100, // Amount in paise
          currency: 'INR',
          name: 'Sri AadhiGuru Education',
          description: 'Secure Service Payment',
          image: '/images/logo-final.png',
          handler: function (response) {
            // This runs after successful payment
            console.log('Payment Success:', response);
            document.body.style.overflow = ''; 
            onPaymentSuccess();
          },
          prefill: {
            name: customerName || '',
            contact: customerPhone || ''
          },
          theme: {
            color: '#1f8a70'
          },
          modal: {
            ondismiss: function() {
              setIsProcessing(false);
              onClose();
            }
          }
        };

        const paymentObject = new window.Razorpay(options);
        paymentObject.open();
        setIsProcessing(false);

      } catch (err) {
        console.error("Razorpay Error:", err);
        setErrorStatus('Initialization Error: ' + err.message);
        setIsProcessing(false);
      }
    };

    displayRazorpay();
    
    return () => {
      document.body.style.overflow = '';
    };
  }, [amount, customerName, customerPhone, onPaymentSuccess, onClose]);

  return (
    <div className="payment-gateway-modal" style={{ zIndex: 9999 }}>
      <div className="payment-container" style={{ textAlign: 'center', padding: '3rem', position: 'relative' }}>
        {errorStatus && (
          <button className="close-btn" onClick={onClose} style={{ position: 'absolute', top: '15px', right: '20px', background: 'transparent', border: 'none', fontSize: '2rem', cursor: 'pointer', color: '#666' }}>&times;</button>
        )}
        
        {isProcessing ? (
           <>
             <div className="ps-spinner" style={{ margin: '0 auto 1.5rem auto', width: '50px', height: '50px', borderTopColor: '#1f8a70' }}></div>
             <h2 style={{ fontSize: '1.4rem', color: '#1f8a70', fontWeight: 'bold' }}>Opening Secure Payment...</h2>
           </>
        ) : errorStatus ? (
           <>
             <div style={{ fontSize: '3rem', margin: '0 auto 1.5rem auto' }}>⚠️</div>
             <h2 style={{ fontSize: '1.5rem', color: '#ef4444', fontWeight: 'bold' }}>Payment Error</h2>
             <p style={{ color: 'var(--color-text-muted)', margin: '1rem 0' }}>{errorStatus}</p>
             <button onClick={onClose} style={{ marginTop: '1rem', padding: '0.8rem 1.5rem', background: '#ef4444', color: 'white', border: 'none', borderRadius: '8px', cursor: 'pointer', fontWeight: 'bold' }}>Try Again</button>
           </>
        ) : (
           <p style={{ color: '#666' }}>Payment window is open. Complete the transaction to proceed.</p>
        )}
      </div>
    </div>
  );
};

export default PaymentGateway;
