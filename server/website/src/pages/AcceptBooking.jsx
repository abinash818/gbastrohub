import { useEffect, useState } from 'react';
import { useSearchParams } from 'react-router-dom';
import { supabase } from '../supabaseClient';

const AcceptBooking = () => {
  const [searchParams] = useSearchParams();
  const id = searchParams.get('id');
  const [status, setStatus] = useState('processing');
  
  useEffect(() => {
    if (id) {
      supabase.from('bookings').update({ status: 'accepted' }).eq('id', id)
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
        <h2 style={{ fontSize: '2rem', marginBottom: '1rem' }}>Admin: Accept Booking</h2>
        {status === 'processing' && <p>Processing request in database...</p>}
        {status === 'invalid' && <p style={{ color: '#ef4444' }}>Invalid URL. Missing booking ID.</p>}
        {status === 'error' && <p style={{ color: '#ef4444', fontWeight: 'bold' }}>Failed to accept booking. Check Supabase RLS and DB connection.</p>}
        {status === 'success' && (
          <div>
            <span style={{ fontSize: '4rem', display: 'block', marginBottom: '1rem' }}>✅</span>
            <p style={{ color: '#16a34a', fontWeight: 'bold', fontSize: '1.2rem' }}>Success! Booking has been ACCEPTED.</p>
            <p style={{ marginTop: '0.5rem', color: 'var(--color-text-muted)' }}>The Supabase Edge Function is now triggering a WhatsApp notification to the user requesting payment.</p>
          </div>
        )}
      </div>
    </div>
  );
};

export default AcceptBooking;
