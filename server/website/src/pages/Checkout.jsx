import React, { useState, useEffect } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import './Checkout.css';

const Checkout = () => {
  const navigate = useNavigate();
  const [cart, setCart] = useState([]);
  const [orderSuccess, setOrderSuccess] = useState(false);

  // Form states
  const [form, setForm] = useState({
    fullName: '',
    phone: '',
    address: '',
    city: '',
    pincode: '',
    paymentMethod: 'card',
    cardNumber: '',
    expiry: '',
    cvv: ''
  });

  useEffect(() => {
    // Check auth
    const userPhone = localStorage.getItem('userPhone');
    if (!userPhone) {
      navigate('/login');
      return;
    }

    // Load cart from localStorage
    const saved = localStorage.getItem('aadhiguru_cart');
    if (saved) {
      setCart(JSON.parse(saved));
    } else {
      // Empty cart redirect
      navigate('/store');
    }
  }, [navigate]);

  const cartTotal = cart.reduce((sum, item) => sum + item.price * item.qty, 0);
  const cartCount = cart.reduce((sum, item) => sum + item.qty, 0);

  const handleSubmit = (e) => {
    e.preventDefault();
    setOrderSuccess(true);
    localStorage.removeItem('aadhiguru_cart'); // clear cart

    setTimeout(() => {
      navigate('/dashboard'); // or standard order confirmation page
    }, 4000);
  };

  if (orderSuccess) {
    return (
      <div className="checkout-page success-view">
        <div className="success-card">
          <div className="success-icon-large">✅</div>
          <h2>Order Placed Successfully!</h2>
          <p>Thank you for shopping at AadhiGuru. Your spiritual items are being prepared.</p>
          <p className="redirect-text">Redirecting to your dashboard in a few seconds...</p>
        </div>
      </div>
    );
  }

  if (cart.length === 0) {
    return null; // Don't render until redirect
  }

  return (
    <div className="checkout-page">
      <div className="checkout-header">
        <Link to="/store" className="back-link">← Back to Store</Link>
        <h1>Checkout</h1>
        <div className="secure-badge">🔒 Secure Checkout</div>
      </div>

      <div className="checkout-container">
        
        {/* Left Column: Forms */}
        <div className="checkout-left">
          <form id="checkout-form" onSubmit={handleSubmit}>
            
            {/* Delivery Section */}
            <section className="checkout-section">
              <div className="section-header">
                <span className="step-num">1</span>
                <h2>Delivery Address</h2>
              </div>
              <div className="section-content">
                <div className="input-row">
                  <div className="input-group">
                    <label>Full Name</label>
                    <input required type="text" placeholder="First and Last name" value={form.fullName} onChange={e => setForm({...form, fullName: e.target.value})} />
                  </div>
                  <div className="input-group">
                    <label>Phone Number</label>
                    <input required type="tel" placeholder="10-digit mobile number" pattern="[0-9]{10}" value={form.phone} onChange={e => setForm({...form, phone: e.target.value})} />
                  </div>
                </div>
                <div className="input-group">
                  <label>Full Address</label>
                  <input required type="text" placeholder="Flat, House no., Building, Company, Apartment" value={form.address} onChange={e => setForm({...form, address: e.target.value})} />
                </div>
                <div className="input-row">
                  <div className="input-group">
                    <label>City</label>
                    <input required type="text" placeholder="City or Town" value={form.city} onChange={e => setForm({...form, city: e.target.value})} />
                  </div>
                  <div className="input-group">
                    <label>Pincode</label>
                    <input required type="text" placeholder="6-digit PIN" pattern="[0-9]{6}" value={form.pincode} onChange={e => setForm({...form, pincode: e.target.value})} />
                  </div>
                </div>
              </div>
            </section>

            {/* Payment Section */}
            <section className="checkout-section">
              <div className="section-header">
                <span className="step-num">2</span>
                <h2>Payment Method</h2>
              </div>
              <div className="section-content">
                
                <div className={`payment-method-box ${form.paymentMethod === 'card' ? 'active' : ''}`}>
                  <label className="radio-label">
                    <input type="radio" name="payment" value="card" checked={form.paymentMethod === 'card'} onChange={() => setForm({...form, paymentMethod: 'card'})} />
                    <span>Credit / Debit Card</span>
                    <div className="card-icons">💳</div>
                  </label>
                  
                  {form.paymentMethod === 'card' && (
                    <div className="card-details-panel">
                      <div className="input-group">
                        <input type="text" placeholder="Card Number" maxLength="19" required />
                      </div>
                      <div className="input-row" style={{ marginTop: '1rem' }}>
                        <div className="input-group">
                          <input type="text" placeholder="MM/YY" maxLength="5" required />
                        </div>
                        <div className="input-group">
                          <input type="text" placeholder="CVV" maxLength="4" required />
                        </div>
                      </div>
                    </div>
                  )}
                </div>

                <div className={`payment-method-box ${form.paymentMethod === 'upi' ? 'active' : ''}`}>
                  <label className="radio-label">
                    <input type="radio" name="payment" value="upi" checked={form.paymentMethod === 'upi'} onChange={() => setForm({...form, paymentMethod: 'upi'})} />
                    <span>UPI (GPay, PhonePe, Paytm)</span>
                    <div className="card-icons">📲</div>
                  </label>
                  {form.paymentMethod === 'upi' && (
                    <div className="card-details-panel">
                      <div className="input-group">
                        <input type="text" placeholder="your_upi_id@bank" required />
                      </div>
                    </div>
                  )}
                </div>

                <div className={`payment-method-box ${form.paymentMethod === 'cod' ? 'active' : ''}`}>
                  <label className="radio-label">
                    <input type="radio" name="payment" value="cod" checked={form.paymentMethod === 'cod'} onChange={() => setForm({...form, paymentMethod: 'cod'})} />
                    <span>Cash on Delivery (COD)</span>
                    <div className="card-icons">💵</div>
                  </label>
                </div>

              </div>
            </section>

            {/* Hidden submit so button outside form can trigger it via form attribute */}
          </form>
        </div>

        {/* Right Column: Order Summary */}
        <div className="checkout-right">
          <div className="summary-widget">
            <button form="checkout-form" type="submit" className="place-order-btn">
              Place your order
            </button>
            <p className="terms-text">
              By placing your order, you agree to AadhiGuru's privacy notice and conditions of use.
            </p>

            <h3 className="summary-title">Order Summary</h3>
            
            <div className="summary-calc">
              <div className="calc-row">
                <span>Items ({cartCount}):</span>
                <span>₹{cartTotal.toLocaleString()}</span>
              </div>
              <div className="calc-row">
                <span>Delivery:</span>
                <span className="free-text">Free</span>
              </div>
            </div>
            
            <div className="summary-total">
              <span>Order Total:</span>
              <span className="total-price">₹{cartTotal.toLocaleString()}</span>
            </div>

            <div className="summary-items-preview">
              <h4 className="preview-title">Items in your cart</h4>
              {cart.map(item => (
                <div key={item.id} className="preview-item">
                  <div className="preview-emoji">{item.emoji}</div>
                  <div className="preview-info">
                    <p className="preview-name">{item.name}</p>
                    <p className="preview-qty">Qty: {item.qty}</p>
                  </div>
                  <div className="preview-price">₹{(item.price * item.qty).toLocaleString()}</div>
                </div>
              ))}
            </div>

          </div>
        </div>

      </div>
    </div>
  );
};

export default Checkout;
