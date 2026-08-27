import { useEffect, useState } from 'react';
import { useSearchParams } from 'react-router-dom';
import { supabase } from '../supabaseClient';
import PaymentGateway from '../components/PaymentGateway';
import Toast from '../components/Toast';

const PaymentPage = () => {
  const [searchParams] = useSearchParams();
  const id = searchParams.get('id');
  const [booking, setBooking] = useState(null);
  const [loading, setLoading] = useState(true);
  const [paymentMode, setPaymentMode] = useState('full');
  const [showGateway, setShowGateway] = useState(false);
  const [toast, setToast] = useState(null);

  useEffect(() => {
    if (id) {
      supabase.from('bookings').select('*').eq('id', id).single()
        .then(({ data, error }) => {
          if (data) setBooking(data);
          setLoading(false);
        });
    } else {
      setLoading(false);
    }
  }, [id]);

  const handlePayment = () => {
    setShowGateway(true);
  };

  const handlePaymentSuccess = () => {
    supabase.from('bookings')
      .update({ payment_status: paymentMode === 'full' ? 'paid' : 'partial' })
      .eq('id', id)
      .then(() => {
        setToast({ message: 'Payment processed successfully!', type: 'success' });
        setTimeout(() => {
          setShowGateway(false);
          window.location.reload();
        }, 1500);
      });
  };

  if (loading) return <div style={{padding: '5rem', textAlign: 'center'}}>Loading Booking Data...</div>;
  if (!booking) return <div style={{padding: '5rem', textAlign: 'center', color: 'red'}}>Invalid Booking ID</div>;

  return (
    <div style={{ padding: '4rem 2rem', backgroundColor: 'var(--color-bg)', minHeight: '80vh', display: 'flex', justifyContent: 'center' }}>
      <div style={{ backgroundColor: 'var(--color-surface)', padding: '2.5rem', borderRadius: '20px', boxShadow: 'var(--shadow-xl)', maxWidth: '500px', width: '100%', alignSelf: 'flex-start', border: '1px solid var(--color-border)' }}>
        <h2 style={{ fontSize: '1.8rem', marginBottom: '1.5rem', textAlign: 'center', fontWeight: '800' }}>Confirm Payment</h2>
        
        <div style={{ marginBottom: '1.5rem', padding: '1.5rem', backgroundColor: 'rgba(31,138,112,0.05)', borderRadius: '16px', border: '1px solid rgba(31,138,112,0.1)' }}>
            <h3 style={{ fontSize: '1.2rem', marginBottom: '0.75rem', color: 'var(--color-primary)', fontWeight: '700' }}>{booking.purpose_of_booking}</h3>
            <div style={{ display: 'grid', gap: '0.5rem', fontSize: '0.95rem' }}>
              <p><strong>Name:</strong> {booking.full_name}</p>
              <p><strong>Phone:</strong> {booking.phone_number}</p>
              <p><strong>Date:</strong> {booking.date} at {booking.time_slot}</p>
              <p><strong>Location:</strong> {booking.meeting_location}</p>
            </div>
            
            <div style={{marginTop: '1.25rem', paddingTop: '1rem', borderTop: '1px dashed var(--color-border)', fontWeight: 'bold', display: 'flex', justifyContent: 'space-between' }}>
               <span>Status: <span style={{ color: booking.status === 'accepted' ? '#16a34a' : 'orange'}}>{booking.status.toUpperCase()}</span></span>
               <span>Payment: <span style={{ color: booking.payment_status === 'paid' ? '#16a34a' : '#ef4444'}}>{booking.payment_status.toUpperCase()}</span></span>
            </div>
        </div>

        {booking.status === 'accepted' && booking.payment_status !== 'paid' && (
            <>
                <h4 style={{ marginBottom: '1rem', fontSize: '1rem', color: 'var(--color-text)' }}>Payment Options:</h4>
                <div style={{ display: 'flex', gap: '1rem', marginBottom: '2rem' }}>
                <label style={{ flex: 1, padding: '1rem', border: `2px solid ${paymentMode === 'partial' ? 'var(--color-primary)' : 'var(--color-border)'}`, borderRadius: '12px', cursor: 'pointer', textAlign: 'center', backgroundColor: paymentMode === 'partial' ? 'rgba(31,138,112,0.05)' : 'transparent', transition: 'all 0.2s' }}>
                    <input type="radio" value="partial" checked={paymentMode === 'partial'} onChange={() => setPaymentMode('partial')} style={{display:'none'}}/>
                    <strong style={{display:'block', fontSize: '1.1rem', color: paymentMode === 'partial' ? 'var(--color-primary)' : 'var(--color-text)'}}>Pay 50%</strong>
                    <span style={{fontSize:'0.85rem', color: 'var(--color-text-muted)'}}>Advance Booking</span>
                </label>
                <label style={{ flex: 1, padding: '1rem', border: `2px solid ${paymentMode === 'full' ? 'var(--color-primary)' : 'var(--color-border)'}`, borderRadius: '12px', cursor: 'pointer', textAlign: 'center', backgroundColor: paymentMode === 'full' ? 'rgba(31,138,112,0.05)' : 'transparent', transition: 'all 0.2s' }}>
                    <input type="radio" value="full" checked={paymentMode === 'full'} onChange={() => setPaymentMode('full')} style={{display:'none'}} />
                    <strong style={{display:'block', fontSize: '1.1rem', color: paymentMode === 'full' ? 'var(--color-primary)' : 'var(--color-text)'}}>Pay 100%</strong>
                    <span style={{fontSize:'0.85rem', color: 'var(--color-text-muted)'}}>Full Amount</span>
                </label>
                </div>

                <button onClick={handlePayment} className="btn" style={{ width: '100%', padding: '1.1rem', background: 'linear-gradient(135deg, var(--color-primary), #ff6b6b)', color: 'white', border: 'none', borderRadius: '12px', fontSize: '1.05rem', fontWeight: 'bold', cursor: 'pointer', boxShadow: '0 8px 16px rgba(243, 141, 62, 0.25)' }}>
                  Secure Checkout via Razorpay
                </button>
            </>
        )}

        {booking.payment_status === 'paid' && (
            <div style={{textAlign: 'center', padding: '2rem 0'}}>
                <span style={{ fontSize: '3rem', display: 'block', marginBottom: '0.5rem' }}>💳✅</span>
                <p style={{ color: '#16a34a', fontWeight: 'bold', fontSize: '1.2rem' }}>Payment Completely Settled.</p>
                <p style={{color: 'var(--color-text-muted)', fontSize: '0.9rem', marginTop: '0.5rem'}}>Thank you for confirming your booking!</p>
            </div>
        )}
      </div>

      {showGateway && (
        <PaymentGateway 
          amount={paymentMode === 'full' ? 500 : 250} 
          customerName={booking?.full_name}
          customerPhone={booking?.phone_number}
          onPaymentSuccess={handlePaymentSuccess}
          onClose={() => setShowGateway(false)}
        />
      )}
      {toast && <Toast message={toast.message} type={toast.type} onClose={() => setToast(null)} />}
    </div>
  );
};

export default PaymentPage;
