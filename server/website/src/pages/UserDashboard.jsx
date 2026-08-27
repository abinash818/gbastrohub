import { useState, useEffect } from 'react';
import { Link, useNavigate, useLocation } from 'react-router-dom';
import { supabase } from '../supabaseClient';
import Toast from '../components/Toast';
import './UserDashboard.css';

const UserDashboard = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const [bookings, setBookings] = useState([]);
  const [loading, setLoading] = useState(true);
  const [user, setUser] = useState(null);
  const [showWelcome, setShowWelcome] = useState(false);
  const [toast, setToast] = useState(null);

  useEffect(() => {
    if (location.state?.justLoggedIn) {
      setShowWelcome(true);
      setTimeout(() => setShowWelcome(false), 5000);
      // Clean up state so it doesn't show again on refresh
      window.history.replaceState({}, document.title);
    }
  }, [location]);

  useEffect(() => {
    const initFetch = async () => {
      const { data: { session } } = await supabase.auth.getSession();
      if (!session) {
        navigate('/login');
        return;
      }
      
      setUser(session.user);
      
      // Fetch bookings where user_id matches (RLS will enforce this too)
      const { data, error } = await supabase
        .from('bookings')
        .select('*')
        .eq('user_id', session.user.id)
        .order('created_at', { ascending: false });

      if (error) {
        console.error('Error fetching bookings:', error);
      } else {
        setBookings(data);
      }
      setLoading(false);
    };

    initFetch();

    // Set up realtime subscription for updates
    // In production, we filter by user_id in the channel too
    const channel = supabase.channel('user-bookings')
    .on(
      'postgres_changes',
      { event: '*', schema: 'public', table: 'bookings' },
      (payload) => {
        // Double check on client side although RLS should handle it
        const { data: { session } } = supabase.auth.getSession().then(({data}) => {
           if (data.session && (payload.new?.user_id === data.session.user.id || payload.old?.user_id === data.session.user.id)) {
              if (payload.eventType === 'INSERT') {
                setBookings(prev => [payload.new, ...prev]);
              } else if (payload.eventType === 'UPDATE') {
                setBookings(prev => prev.map(b => b.id === payload.new.id ? payload.new : b));
              } else if (payload.eventType === 'DELETE') {
                setBookings(prev => prev.filter(b => b.id !== payload.old.id));
              }
           }
        });
      }
    )
    .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, [navigate]);

  const handleCancelBooking = async (bookingId) => {
    if (!window.confirm("Are you sure you want to cancel and delete this booking request?")) return;
    
    // RLS will ensure user can only delete their own 'pending' bookings
    const { error } = await supabase
      .from('bookings')
      .delete()
      .eq('id', bookingId)
      .eq('user_id', user.id);

    if (error) {
      setToast({ message: "Failed to cancel booking. " + error.message, type: 'error' });
    }
  };

  if (loading) return <div className="loading-state">Loading your dashboard...</div>;

  return (
    <div className="dashboard-container">
      {showWelcome && (
        <div className="welcome-notification-success">
          <div className="welcome-notif-content">
            <span className="notif-check">✅</span>
            <div className="notif-text-group">
              <strong>Login Successful!</strong>
              <p>Account created & verified. Welcome to Sri AadhiGuru Education.</p>
            </div>
          </div>
        </div>
      )}
      <div className="container">
        <header className="dashboard-header">
          <div className="header-top-row">
            <h1>My Bookings Dashboard</h1>
            <div className="verified-status-badge">
              <span className="badge-icon">🛡️</span>
              Verified Profile
            </div>
          </div>
          <p className="welcome-text">Track your service requests and manage your path to wisdom.</p>
        </header>

        {!user || bookings.length === 0 ? (
          <div className="empty-dashboard">
            <div className="empty-icon">📅</div>
            <h3>No Active Bookings</h3>
            <p>You haven't made any booking requests yet.</p>
            <Link to="/" className="btn btn-primary">Book a Service Now</Link>
          </div>
        ) : (
          <div className="dashboard-grid">
            <section className="bookings-section">
              <h2 className="section-title">Current Status</h2>
              <div className="bookings-list">
                {bookings.map(booking => (
                  <div key={booking.id} className={`booking-card status-${booking.status}`}>
                    <div className="card-header">
                      <span className="service-type">{booking.purpose_of_booking}</span>
                      <span className={`status-badge badge-${booking.status}`}>
                        {booking.status.toUpperCase()}
                      </span>
                    </div>
                    <div className="card-body">
                      <div className="info-row">
                        <span className="label">Date:</span>
                        <span className="value">{booking.date}</span>
                      </div>
                      <div className="info-row">
                        <span className="label">Time:</span>
                        <span className="value">{booking.time_slot}</span>
                      </div>
                      <div className="info-row">
                        <span className="label">Payment:</span>
                        <span className={`value payment-${booking.payment_status}`}>
                          {booking.payment_status}
                        </span>
                      </div>
                    </div>
                    <div className="card-footer">
                      {booking.status === 'pending' && (
                        <div className="pending-actions" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', width: '100%', flexWrap: 'wrap', gap: '1rem' }}>
                          <div className="pending-notice" style={{ margin: 0 }}>
                            <span className="spinner"></span>
                            Waiting for Master's approval...
                          </div>
                          <button 
                            className="btn btn-outline" 
                            style={{ padding: '0.4rem 0.8rem', fontSize: '0.85rem', color: '#ef4444', borderColor: '#ef4444' }}
                            onClick={() => handleCancelBooking(booking.id)}
                          >
                            Cancel Request
                          </button>
                        </div>
                      )}
                      {booking.status === 'accepted' && booking.payment_status === 'unpaid' && (
                        <Link to={`/pay?id=${booking.id}`} className="btn btn-pay">
                          Proceed to Payment
                        </Link>
                      )}
                      {booking.status === 'accepted' && booking.payment_status === 'paid' && (
                        <div className="confirmed-notice">
                          ✅ Confirmed & Paid
                        </div>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            </section>

            <aside className="explore-section">
              <div className="explore-card store-promo">
                <div className="promo-icon">🛒</div>
                <h3>Explore Our Store</h3>
                <p>Browse our collection of sacred items, books, and energized yantras while you wait.</p>
                <Link to="/store" className="btn btn-outline">Visit Store</Link>
              </div>

              <div className="explore-card software-promo">
                <div className="promo-icon">💻</div>
                <h3>AadhiGuru Software</h3>
                <p>Check out our professional tools for detailed astrological calculations.</p>
                <Link to="/software" className="btn btn-outline">View Software</Link>
              </div>
            </aside>
          </div>
        )}
      </div>
      {toast && <Toast message={toast.message} type={toast.type} onClose={() => setToast(null)} />}
    </div>
  );
};

export default UserDashboard;

