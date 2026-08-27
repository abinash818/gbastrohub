import { useState, useEffect } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { supabase } from '../supabaseClient';
import './Header.css';
import './Header.css';

const NAV_LINKS = [
  { to: '/',          label: 'Home',      exact: true  },
  { to: '/classes',   label: 'Classes'               },
  { to: '/matrimony', label: 'Matrimony', icon: '💍'  },
  { to: '/store',     label: 'Store',     icon: '🛕'  },
  { to: '/software',  label: 'Our Software', icon: '💻' },
  { to: '/dashboard', label: 'My Bookings', icon: '📋' },
];

const Header = () => {
  const location = useLocation();
  const [menuOpen, setMenuOpen]   = useState(false);
  const [scrolled, setScrolled]   = useState(false);
  const [user, setUser] = useState(null);

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      setUser(session?.user || null);
    });

    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      setUser(session?.user || null);
    });

    return () => subscription.unsubscribe();
  }, []);

  /* Close mobile menu on route change */
  useEffect(() => { setMenuOpen(false); }, [location.pathname]);

  /* Scroll shadow */
  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 10);
    window.addEventListener('scroll', onScroll, { passive: true });
    return () => window.removeEventListener('scroll', onScroll);
  }, []);

  /* Lock body scroll when menu open */
  useEffect(() => {
    document.body.style.overflow = menuOpen ? 'hidden' : '';
    return () => { document.body.style.overflow = ''; };
  }, [menuOpen]);

  const isActive = (link) => {
    if (link.hash) return false;
    if (link.exact) return location.pathname === '/';
    return location.pathname.startsWith(link.to);
  };

  return (
    <>
      <header className={`header ${scrolled ? 'header-scrolled' : ''}`}>
        <div className="container header-container">

          {/* ── Logo ── */}
          <Link to="/" className="logo-link" onClick={() => {
            setMenuOpen(false);
            window.scrollTo({ top: 0, behavior: 'instant' });
          }}>
            <img src="/images/logo-final.png" alt="GB ASTRO" className="site-logo" fetchPriority="high" />
            <div className="logo-text-block">
              <span className="logo-name">GB ASTRO</span>
              <span className="logo-sub">ஜிபி அஸ்ட்ரோ</span>
            </div>
          </Link>

          {/* ── Desktop Nav ── */}
          <nav className="nav-desktop" aria-label="Main navigation">
            {NAV_LINKS.map(link => (
              link.hash
                ? <a key={link.to} href={link.to} className="nav-link">
                    {link.label}
                  </a>
                : <Link
                    key={link.to}
                    to={link.to}
                    className={`nav-link ${isActive(link) ? 'nav-link-active' : ''}`}
                    onClick={() => {
                      setMenuOpen(false);
                      window.scrollTo({ top: 0, behavior: 'instant' });
                    }}
                  >
                    {link.icon && <span className="nav-icon">{link.icon}</span>}
                    {link.label}
                    {isActive(link) && <span className="nav-active-dot" />}
                  </Link>
            ))}

            {user ? (
              <div className="nav-user-account profile-dropdown-container">
                <div className="nav-login-btn logged-in profile-trigger">
                  {user.user_metadata?.avatar_url ? (
                    <img src={user.user_metadata.avatar_url} alt="Profile avatar" className="nav-profile-pic" />
                  ) : (
                    <span className="nav-btn-icon">👤</span>
                  )}
                  <span className="profile-name">
                    {user.user_metadata?.full_name || user.user_metadata?.username || user.email?.split('@')[0] || 'My Account'}
                  </span>
                  <span className="dropdown-arrow">▼</span>
                </div>
                
                <div className="profile-dropdown">
                  <div className="dropdown-header">
                    <p className="dropdown-email">{user.email}</p>
                  </div>
                  <Link to="/dashboard" className="dropdown-item" onClick={() => window.scrollTo(0, 0)}>
                    <span className="dropdown-icon">📋</span> My Bookings
                  </Link>
                  {user.email === 'aadhiguru.com@gmail.com' && (
                    <Link to="/admin" className="dropdown-item">
                      <span className="dropdown-icon">📈</span> Admin Dashboard
                    </Link>
                  )}
                  <Link to="/profile" className="dropdown-item" onClick={() => window.scrollTo(0, 0)}>
                    <span className="dropdown-icon">⚙️</span> Profile Settings
                  </Link>

                  <div className="dropdown-divider"></div>
                  <button 
                    onClick={() => {
                      supabase.auth.signOut();
                      localStorage.removeItem('userPhone');
                    }} 
                    className="dropdown-item logout-item"
                  >
                    <span className="dropdown-icon">🚪</span> Sign Out
                  </button>
                </div>
              </div>
            ) : (
              <Link to="/login" className="nav-login-btn">
                <span className="nav-btn-icon">👤</span>
                Login / Sign Up
              </Link>
            )}
            <Link to="/contact" className="btn btn-primary" style={{marginLeft: '15px', padding: '0.5rem 1.25rem', fontSize: '0.9rem', width: 'auto', borderRadius: '4px'}}>
              Contact Us
            </Link>
          </nav>

          {/* ── Hamburger ── */}
          <button
            className={`hamburger ${menuOpen ? 'ham-open' : ''}`}
            onClick={() => setMenuOpen(o => !o)}
            aria-label="Toggle menu"
            aria-expanded={menuOpen}
          >
            <span className="ham-line" />
            <span className="ham-line" />
            <span className="ham-line" />
          </button>
        </div>
      </header>

      {/* ── Mobile Drawer ── */}
      {menuOpen && <div className="drawer-backdrop" onClick={() => setMenuOpen(false)} />}
      <div className={`mobile-drawer ${menuOpen ? 'drawer-open' : ''}`} aria-hidden={!menuOpen}>
        <div className="drawer-header">
          <Link to="/" className="logo-link drawer-logo" onClick={() => setMenuOpen(false)}>
            <img src="/images/logo-final.png" alt="Logo" className="site-logo" />
            <div className="logo-text-block">
              <span className="logo-name">GB ASTRO</span>
              <span className="logo-sub">ஜிபி அஸ்ட்ரோ</span>
            </div>
          </Link>
          <button className="drawer-close-btn" onClick={() => setMenuOpen(false)} aria-label="Close menu">✕</button>
        </div>

        <nav className="drawer-nav" aria-label="Mobile navigation">
          {NAV_LINKS.map(link => (
            link.hash
              ? <a key={link.to} href={link.to} className="drawer-link" onClick={() => setMenuOpen(false)}>
                  <span className="drawer-link-icon">🏠</span>
                  {link.label}
                </a>
              : <Link
                  key={link.to}
                  to={link.to}
                  className={`drawer-link ${isActive(link) ? 'drawer-link-active' : ''}`}
                  onClick={() => {
                    setMenuOpen(false);
                    window.scrollTo({ top: 0, behavior: 'instant' });
                  }}
                >
                  <span className="drawer-link-icon">{link.icon || '›'}</span>
                  {link.label}
                </Link>
          ))}
        </nav>

        <div className="drawer-footer">
          {user ? (
            <div style={{display: 'flex', gap: '10px', flexDirection: 'column'}}>
              <div className="drawer-user-info">
                {user.user_metadata?.avatar_url ? (
                  <img src={user.user_metadata.avatar_url} alt="Profile" className="drawer-profile-pic" />
                ) : (
                  <span className="drawer-profile-icon">👤</span>
                )}
                <div className="drawer-user-details">
                  <span className="drawer-user-name">{user.user_metadata?.full_name || user.user_metadata?.username || user.email?.split('@')[0]}</span>
                  <span className="drawer-user-email">{user.email}</span>
                </div>
              </div>
              <Link to="/dashboard" className="drawer-link" onClick={() => {
                setMenuOpen(false);
                window.scrollTo(0, 0);
              }}>
                 <span className="drawer-link-icon">📋</span> My Bookings
              </Link>
              {user.email === 'aadhiguru.com@gmail.com' && (
                <Link to="/admin" className="drawer-link" onClick={() => setMenuOpen(false)}>
                  <span className="drawer-link-icon">📈</span> Admin Dashboard
                </Link>
              )}

              <button 
                onClick={() => { 
                  supabase.auth.signOut(); 
                  localStorage.removeItem('userPhone');
                  setMenuOpen(false); 
                }} 
                className="drawer-link" 
                style={{color: '#ef4444', border: 'none', background: 'transparent', textAlign: 'left', padding: '0.85rem 1.1rem', cursor: 'pointer', fontFamily: 'inherit'}}
              >
                <span className="drawer-link-icon">🚪</span> Sign Out
              </button>
            </div>
          ) : (
            <Link to="/login" className="drawer-login-btn" onClick={() => setMenuOpen(false)}>
              👤 Login / Sign Up
            </Link>
          )}
          <Link to="/contact" className="btn btn-primary w-100" onClick={() => setMenuOpen(false)} style={{ textAlign: 'center', marginTop: '1rem', borderRadius: '4px' }}>
             Contact Us
          </Link>
          <p className="drawer-tagline">🕉️ Vedic · Authentic · Trusted</p>
        </div>
      </div>
    </>
  );
};

export default Header;
