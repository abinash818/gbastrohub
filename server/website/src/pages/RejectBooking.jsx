import { useEffect, useState } from 'react';
import { useSearchParams } from 'react-router-dom';
import { supabase } from '../supabaseClient';

const RejectBooking = () => {
  const [searchParams] = useSearchParams();
  const id = searchParams.get('id');
  const [status, setStatus] = useState('processing');
  
  useEffect(() => {
    if (id) {
      supabase.from('bookings').update({ status: 'rejected' }).eq('id', id)
        .then(({ error }) => {
          if (error) {
            console.error(error);
            setStatus('error');
          } else {
            setStatus('success');
          }
        });
    } else {
      setStatus('invalid');
    }
  }, [id]);

  return (
    <div style={{ minHeight: '80vh', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', backgroundColor: 'var(--color-bg)' }}>
      <div style={{ backgroundColor: 'var(--color-surface)', padding: '3rem', borderRadius: '16px', boxShadow: 'var(--shadow-md)', textAlign: 'center', maxWidth: '500px' }}>
        <h2 style={{ fontSize: '2rem', marginBottom: '1rem' }}>Admin: Reject Booking</h2>
        {status === 'processing' && <p>Processing request in database...</p>}
        {status === 'invalid' && <p style={{ color: '#ef4444' }}>Invalid URL. Missing booking ID.</p>}
        {status === 'error' && <p style={{ color: '#ef4444', fontWeight: 'bold' }}>Failed to reject booking. Check Supabase RLS and DB connection.</p>}
        {status === 'success' && (
          <div>
            <span style={{ fontSize: '4rem', display: 'block', marginBottom: '1rem' }}>⛔</span>
            <p style={{ color: '#ef4444', fontWeight: 'bold', fontSize: '1.2rem' }}>Booking Rejected.</p>
            <p style={{ marginTop: '0.5rem', color: 'var(--color-text-muted)' }}>The Supabase Edge Function is now triggering a WhatsApp notification to inform the user.</p>
          </div>
        )}
      </div>
    </div>
  );
};

export default RejectBooking;
