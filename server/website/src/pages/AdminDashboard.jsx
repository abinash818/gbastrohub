import { useState, useEffect } from 'react';
import { supabase } from '../supabaseClient';
import './AdminDashboard.css';

const AdminDashboard = () => {
  const [bookings, setBookings] = useState([]);
  const [loading, setLoading] = useState(true);

  // Active Bookings

  const fetchBookings = async () => {
    const { data: { session } } = await supabase.auth.getSession();
    
    // Strict Admin Email Check
    if (!session || session.user?.email !== 'aadhiguru.com@gmail.com') {
      window.location.href = '/login';
      return;
    }
    
    setLoading(true);
    try {
      const { data, error } = await supabase.from('bookings').select('*').order('created_at', { ascending: false });
      if (error) throw error;
      setBookings(data || []);
    } catch (err) {
      console.error(err);
    }
    setLoading(false);
  };


  useEffect(() => {
    fetchBookings();
    
    // Listen for new bookings dynamically
    const channel = supabase.channel('admin-bookings')
      .on('postgres_changes', { event: '*', schema: 'public', table: 'bookings' }, () => {
        fetchBookings();
      })
      .subscribe();
      
    return () => { supabase.removeChannel(channel); };
  }, []);

  const updateStatus = async (id, newStatus) => {
    const { error } = await supabase.from('bookings').update({ status: newStatus }).eq('id', id);
    if (!error) {
      fetchBookings();
      // If accepted, send WhatsApp to the User
      if (newStatus === 'accepted') {
        const booking = bookings.find(b => b.id === id);
        if (booking) {
          try {
            await supabase.functions.invoke('send-whatsapp', {
              body: {
                action: 'notify-user',
                userPhone: booking.phone_number,
                bookingDetails: {
                  serviceName: booking.purpose_of_booking,
                  userName: booking.full_name,
                  date: booking.date,
                  time: booking.time_slot || 'To be confirmed'
                }
              }
            });
          } catch (err) {
            console.error('Failed to notify user via WhatsApp:', err);
          }
        }
      }
    }
  };

  // Analytics Computation
  const totalBookings = bookings.length;
  const pendingCount = bookings.filter(b => b.status === 'pending').length;
  
  const categoryCounts = bookings.reduce((acc, b) => {
    const cat = b.purpose_of_booking ? b.purpose_of_booking.split(' - ')[0] : 'other';
    acc[cat] = (acc[cat] || 0) + 1;
    return acc;
  }, {});

  const popularCategory = Object.keys(categoryCounts).length > 0 ? Object.keys(categoryCounts).sort((a, b) => categoryCounts[b] - categoryCounts[a])[0] : 'N/A';

  const recentBookings = bookings.filter(b => {
    const hours = (new Date() - new Date(b.created_at)) / 36e5;
    return hours <= 72;
  }).length;

  return (
    <div className="admin-page bg-surface">
      <div className="container" style={{ padding: '4rem 1rem', minHeight: '80vh' }}>
        <div className="admin-header">
          <h1 className="section-title" style={{ textAlign: 'left', marginBottom: '0.5rem' }}>📈 Analytics Dashboard</h1>
          <p className="section-subtitle">Track your site traffic and service booking metrics.</p>
        </div>

        {loading ? (
          <div className="admin-loading">Loading Analytics...</div>
        ) : (
          <div className="analytics-board">
            
            <div className="analytics-kpi-grid">
              <div className="kpi-card">
                <div className="kpi-icon" style={{background: '#ffc107', color: '#856404'}}>⚠️</div>
                <div className="kpi-data">
                  <h3>{pendingCount}</h3>
                  <p>Pending Requests</p>
                </div>
              </div>
              <div className="kpi-card">
                <div className="kpi-icon">📊</div>
                <div className="kpi-data">
                  <h3>{totalBookings}</h3>
                  <p>Total Bookings</p>
                </div>
              </div>
              <div className="kpi-card">
                <div className="kpi-icon">🔥</div>
                <div className="kpi-data">
                  <h3 style={{ textTransform: 'capitalize' }}>{popularCategory}</h3>
                  <p>Most Popular Service</p>
                </div>
              </div>
              <div className="kpi-card">
                <div className="kpi-icon">⏱️</div>
                <div className="kpi-data">
                  <h3>{recentBookings}</h3>
                  <p>Bookings (Last 3 Days)</p>
                </div>
              </div>
            </div>

            <div className="analytics-details">
              <div className="analytics-card">
                <h3 className="card-title">Bookings per Category</h3>
                <div className="category-stats">
                  {Object.entries(categoryCounts).map(([cat, count]) => (
                    <div key={cat} className="cat-stat-bar">
                      <span className="cat-name">{cat}</span>
                      <div className="cat-bar-wrap">
                        <div className="cat-bar" style={{ width: `${(count / totalBookings) * 100}%` }}></div>
                      </div>
                      <span className="cat-count">{count}</span>
                    </div>
                  ))}
                </div>
              </div>

              <div className="analytics-card" style={{ gridColumn: 'span 2' }}>
                <h3 className="card-title">Live Booking Requests</h3>
                <div style={{overflowX: 'auto', marginTop: '1rem'}}>
                  <table style={{width: '100%', borderCollapse: 'collapse', textAlign: 'left', minWidth: '600px'}}>
                    <thead>
                      <tr style={{borderBottom: '2px solid var(--color-border)'}}>
                        <th style={{padding: '0.75rem'}}>Date & Time</th>
                        <th style={{padding: '0.75rem'}}>Client Info</th>
                        <th style={{padding: '0.75rem'}}>Service Request</th>
                        <th style={{padding: '0.75rem'}}>Status</th>
                        <th style={{padding: '0.75rem', textAlign: 'center'}}>Actions</th>
                      </tr>
                    </thead>
                    <tbody>
                      {bookings.length === 0 ? (
                        <tr><td colSpan="5" style={{padding: '1rem', textAlign: 'center'}}>No bookings yet.</td></tr>
                      ) : bookings.map(b => (
                        <tr key={b.id} style={{borderBottom: '1px solid var(--color-border)', backgroundColor: b.status === 'pending' ? 'rgba(255, 193, 7, 0.05)' : 'transparent'}}>
                          <td style={{padding: '1rem'}}>{b.date} <br/><span style={{fontSize: '0.85em', color: 'gray'}}>{b.time_slot}</span></td>
                          <td style={{padding: '1rem'}}><strong>{b.full_name}</strong><br/>{b.phone_number}</td>
                          <td style={{padding: '1rem'}}>{b.purpose_of_booking}</td>
                          <td style={{padding: '1rem'}}>
                            <span style={{
                              padding: '4px 10px', borderRadius: '20px', fontSize: '0.85rem', fontWeight: 600,
                              backgroundColor: b.status === 'pending' ? '#fff3cd' : b.status === 'accepted' ? '#d1e7dd' : '#f8d7da',
                              color: b.status === 'pending' ? '#856404' : b.status === 'accepted' ? '#0f5132' : '#842029'
                            }}>
                              {(b.status || 'pending').toUpperCase()}
                            </span>
                          </td>
                          <td style={{padding: '1rem', textAlign: 'center'}}>
                            {b.status === 'pending' ? (
                              <div style={{display: 'flex', gap: '0.5rem', justifyContent: 'center'}}>
                                <button onClick={() => updateStatus(b.id, 'accepted')} style={{padding: '6px 12px', background: '#198754', color: 'white', border: 'none', borderRadius: '6px', cursor: 'pointer', fontWeight: 'bold'}}>Accept</button>
                                <button onClick={() => updateStatus(b.id, 'rejected')} style={{padding: '6px 12px', background: '#dc3545', color: 'white', border: 'none', borderRadius: '6px', cursor: 'pointer', fontWeight: 'bold'}}>Reject</button>
                              </div>
                            ) : (
                              <span style={{color: 'gray', fontSize: '0.9rem'}}>{b.payment_status?.toUpperCase() || '-'}</span>
                            )}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            </div>

          </div>
        )}
      </div>
    </div>
  );
};

export default AdminDashboard;
