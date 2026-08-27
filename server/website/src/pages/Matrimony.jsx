import { useState, useEffect } from 'react';
import { useNavigate, useLocation, Link } from 'react-router-dom';
import { supabase } from '../supabaseClient';
import PaymentGateway from '../components/PaymentGateway';
import SuccessModal from '../components/SuccessModal';
import './Matrimony.css';
/* ══════════════════════════════════════════════════
   DATA
══════════════════════════════════════════════════ */
const allProfiles = [
  {
    id: 1, gender: 'female', name: 'Kavitha Lakshmi', age: 26,
    religion: 'Hindu', caste: 'Mudaliar', subCaste: 'Karkatta Mudaliar',
    star: 'Rohini', rasi: 'Rishabam', height: "5'4\"", education: 'B.Sc Nursing',
    profession: 'Nurse', location: 'Chennai', income: '4-6 LPA',
    complexion: 'Wheatish', diet: 'Vegetarian', motherTongue: 'Tamil',
    fatherOcc: 'Business', motherOcc: 'Homemaker', siblings: '1 Sister',
    maritalStatus: 'First Marriage',
    avatar: '👩', avatarBg: 'linear-gradient(135deg,#f8c6c6,#ffd6e0)',
    matchScore: 92, isPremium: true, isVerified: true, isOnline: true,
    joinedDaysAgo: 2,
    preview: 'A dedicated nurse from Chennai with a warm, caring nature. Deeply rooted in Tamil traditions. Hobbies include classical Bharatanatyam and cooking.',
    tags: ['Caring', 'Traditional', 'Family-Oriented'],
  },
  {
    id: 2, gender: 'female', name: 'Deepa Sundaram', age: 28,
    religion: 'Hindu', caste: 'Brahmin', subCaste: 'Iyer',
    star: 'Bharani', rasi: 'Mesham', height: "5'2\"", education: 'M.A Tamil',
    profession: 'Teacher', location: 'Coimbatore', income: '3-5 LPA',
    complexion: 'Fair', diet: 'Vegetarian', motherTongue: 'Tamil',
    fatherOcc: 'Retired Govt', motherOcc: 'Teacher', siblings: '1 Brother',
    maritalStatus: 'First Marriage',
    avatar: '👩', avatarBg: 'linear-gradient(135deg,#d4f1c8,#b8e6b0)',
    matchScore: 87, isPremium: true, isVerified: true, isOnline: false,
    joinedDaysAgo: 5,
    preview: 'An enthusiastic Tamil teacher passionate about classical arts and literature. Looking for a cultured and spiritual life partner.',
    tags: ['Educated', 'Cultural', 'Spiritual'],
  },
  {
    id: 3, gender: 'female', name: 'Priya Venkatesh', age: 24,
    religion: 'Hindu', caste: 'Gounder', subCaste: 'Kongu Vellala',
    star: 'Krithigai', rasi: 'Mesham', height: "5'5\"", education: 'B.E Computer Science',
    profession: 'Software Engineer', location: 'Bangalore', income: '8-12 LPA',
    complexion: 'Wheatish', diet: 'Non-Vegetarian', motherTongue: 'Tamil',
    fatherOcc: 'Business', motherOcc: 'Homemaker', siblings: 'None',
    maritalStatus: 'Divorced',
    avatar: '👩', avatarBg: 'linear-gradient(135deg,#c8d4f8,#b8c8f0)',
    matchScore: 78, isPremium: true, isVerified: false, isOnline: true,
    joinedDaysAgo: 1,
    preview: 'A talented software engineer who loves travel and exploring new technologies. Independent yet family-oriented.',
    tags: ['Modern', 'Independent', 'Ambitious'],
  },
  {
    id: 4, gender: 'female', name: 'Anitha Rajan', age: 30,
    religion: 'Christian', caste: 'Nadar', subCaste: '',
    star: 'Mirugaserisham', rasi: 'Midhunam', height: "5'3\"", education: 'MBA',
    profession: 'Business Analyst', location: 'Madurai', income: '6-10 LPA',
    complexion: 'Dark', diet: 'Non-Vegetarian', motherTongue: 'Tamil',
    fatherOcc: 'Business', motherOcc: 'Business', siblings: '2 Brothers',
    maritalStatus: 'Widow',
    avatar: '👩', avatarBg: 'linear-gradient(135deg,#fde8c6,#fdd5a0)',
    matchScore: 65, isPremium: true, isVerified: true, isOnline: false,
    joinedDaysAgo: 12,
    preview: 'A sharp business analyst with strong leadership qualities and a big heart. Loves travel, food, and family gatherings.',
    tags: ['Professional', 'Leader', 'Warm'],
  },
  {
    id: 5, gender: 'female', name: 'Santhiya Murugan', age: 25,
    religion: 'Hindu', caste: 'Mudaliar', subCaste: 'Saiva Mudaliar',
    star: 'Rohini', rasi: 'Rishabam', height: "5'4\"", education: 'B.Com',
    profession: 'Accountant', location: 'Chennai', income: '3-4 LPA',
    complexion: 'Fair', diet: 'Vegetarian', motherTongue: 'Tamil',
    fatherOcc: 'Retired', motherOcc: 'Homemaker', siblings: '1 Sister',
    maritalStatus: 'First Marriage',
    avatar: '👩', avatarBg: 'linear-gradient(135deg,#ffe4f0,#ffd0e8)',
    matchScore: 95, isPremium: false, isVerified: true, isOnline: true,
    joinedDaysAgo: 3,
    preview: 'A sincere and homely girl from Chennai with strong family values. Enjoys cooking, rangoli, and Carnatic music.',
    tags: ['Simple', 'Homely', 'Sincere'],
  },
  {
    id: 6, gender: 'male', name: 'Arun Kumar', age: 29,
    religion: 'Hindu', caste: 'Mudaliar', subCaste: 'Karkatta Mudaliar',
    star: 'Avittam', rasi: 'Makaram', height: "5'10\"", education: 'B.E Mechanical',
    profession: 'Engineer', location: 'Chennai', income: '6-8 LPA',
    complexion: 'Wheatish', diet: 'Non-Vegetarian', motherTongue: 'Tamil',
    fatherOcc: 'Business', motherOcc: 'Teacher', siblings: '1 Brother',
    maritalStatus: 'First Marriage',
    avatar: '👨', avatarBg: 'linear-gradient(135deg,#c8e8f8,#b0d8f0)',
    matchScore: 91, isPremium: true, isVerified: true, isOnline: false,
    joinedDaysAgo: 7,
    preview: 'A diligent mechanical engineer with traditional values and a modern outlook. Loves cricket and weekend treks.',
    tags: ['Responsible', 'Traditional', 'Hardworking'],
  },
  {
    id: 7, gender: 'male', name: 'Vijay Shankar', age: 31,
    religion: 'Hindu', caste: 'Brahmin', subCaste: 'Iyer',
    star: 'Hastham', rasi: 'Kanni', height: "5'8\"", education: 'M.Tech',
    profession: 'Data Scientist', location: 'Hyderabad', income: '15+ LPA',
    complexion: 'Fair', diet: 'Vegetarian', motherTongue: 'Tamil',
    fatherOcc: 'Professor', motherOcc: 'Homemaker', siblings: '1 Sister',
    maritalStatus: 'Second Marriage',
    avatar: '👨', avatarBg: 'linear-gradient(135deg,#d8c8f8,#c8b8f0)',
    matchScore: 72, isPremium: true, isVerified: true, isOnline: true,
    joinedDaysAgo: 20,
    preview: 'A tech-savvy data scientist who loves reading philosophy and cooking exotic cuisines. Seeks a calm and intellectual partner.',
    tags: ['Smart', 'Cultured', 'Ambitious'],
  },
  {
    id: 8, gender: 'male', name: 'Karthik Raja', age: 27,
    religion: 'Hindu', caste: 'Gounder', subCaste: 'Kongu Vellala',
    star: 'Rohini', rasi: 'Rishabam', height: "5'9\"", education: 'B.Sc Agriculture',
    profession: 'Agri-Business', location: 'Erode', income: '4-6 LPA',
    complexion: 'Wheatish', diet: 'Non-Vegetarian', motherTongue: 'Tamil',
    fatherOcc: 'Farmer', motherOcc: 'Homemaker', siblings: '2 Sisters',
    maritalStatus: 'Divorced',
    avatar: '👨', avatarBg: 'linear-gradient(135deg,#d0f0d8,#b8e8c0)',
    matchScore: 80, isPremium: false, isVerified: false, isOnline: false,
    joinedDaysAgo: 4,
    preview: 'A progressive farmer building a modern agri-business in Erode. Grounded, hardworking, and nature-loving personality.',
    tags: ['Grounded', 'Industrious', 'Nature-Lover'],
  },
];

const religions = ['All', 'Hindu', 'Christian', 'Muslim'];
const castes = ['All', 'Brahmin', 'Mudaliar', 'Gounder', 'Nadar', 'Others'];
const stars = ['All', 'Rohini', 'Bharani', 'Krithigai', 'Mirugaserisham', 'Hastham', 'Avittam'];
const rasis = ['All', 'Mesham', 'Rishabam', 'Midhunam', 'Kadagam', 'Simmam', 'Kanni', 'Makaram'];
const incomes = ['All', '0-3 LPA', '3-5 LPA', '4-6 LPA', '6-10 LPA', '8-12 LPA', '10-15 LPA', '15+ LPA'];
const heights = ['All', "Below 5'", "5'0\"–5'2\"", "5'3\"–5'5\"", "5'6\"–5'8\"", "5'9\"–5'11\"", "6'+"];
const complexions = ['All', 'Fair', 'Wheatish', 'Dark'];
const diets = ['All', 'Vegetarian', 'Non-Vegetarian'];
const maritalStatuses = ['All', 'First Marriage', 'Second Marriage', 'Divorced', 'Widow', 'Widower', 'Awaiting Divorce', 'Others'];

/* Marital status badge config */
const maritalBadge = {
  'First Marriage':      { bg: 'rgba(16,185,129,0.12)',  color: '#065f46', icon: '💍' },
  'Second Marriage':     { bg: 'rgba(245,158,11,0.12)',  color: '#92400e', icon: '🔄' },
  'Divorced':            { bg: 'rgba(239,68,68,0.10)',   color: '#991b1b', icon: '📋' },
  'Widow':               { bg: 'rgba(100,116,139,0.12)', color: '#334155', icon: '🕊️' },
  'Widower':             { bg: 'rgba(100,116,139,0.12)', color: '#334155', icon: '🕊️' },
  'Awaiting Divorce':    { bg: 'rgba(168,85,247,0.10)',  color: '#6b21a8', icon: '⏳' },
  'Others':              { bg: 'rgba(156,163,175,0.12)', color: '#374151', icon: '📝' },
};

function computeMatch(userProfile, profile) {
  let score = 0;
  if (userProfile.religion && profile.religion === userProfile.religion) score += 25;
  if (userProfile.caste && profile.caste === userProfile.caste) score += 20;
  if (userProfile.star && profile.star === userProfile.star) score += 20;
  if (userProfile.rasi && profile.rasi === userProfile.rasi) score += 15;
  const ageDiff = Math.abs(profile.age - (userProfile.age || 27));
  score += Math.max(0, 20 - ageDiff * 2);
  return Math.min(score, 100);
}

/* ══════════════════════════════════════════════════
   SVG Match Ring
══════════════════════════════════════════════════ */
const MatchRing = ({ score }) => {
  const radius = 28;
  const stroke = 4;
  const norm = 2 * Math.PI * radius;
  const dash = (score / 100) * norm;
  const color = score >= 85 ? '#10b981' : score >= 70 ? '#f59e0b' : '#ef4444';
  return (
    <div className="match-ring-wrap">
      <svg width="70" height="70" viewBox="0 0 70 70">
        <circle cx="35" cy="35" r={radius} fill="none" stroke="#e2e8f0" strokeWidth={stroke} />
        <circle
          cx="35" cy="35" r={radius} fill="none" stroke={color} strokeWidth={stroke}
          strokeDasharray={`${dash} ${norm}`} strokeDashoffset={norm * 0.25}
          strokeLinecap="round" style={{ transition: 'stroke-dasharray 0.8s ease' }}
        />
      </svg>
      <div className="match-ring-text" style={{ color }}>
        <span className="ring-score">{score}</span>
        <span className="ring-pct">%</span>
      </div>
    </div>
  );
};

/* ══════════════════════════════════════════════════
   Pay Modal
══════════════════════════════════════════════════ */
const PayModal = ({ profile, onClose, onPay }) => {
  const [step, setStep] = useState('plan'); // plan | paying | done
  const [plan, setPlan] = useState('single');

  const plans = [
    { id: 'single', label: '1 Profile', price: 99, desc: 'Unlock this profile only' },
    { id: 'bundle5', label: '5 Profiles', price: 399, desc: 'Save ₹96 vs individual' },
    { id: 'premium', label: 'Premium Plan', price: 999, desc: 'Unlimited unlocks for 30 days' },
  ];

  const chosen = plans.find(p => p.id === plan);

  const handlePay = () => {
    setStep('paying');
  };

  const handlePaymentSuccess = () => {
    setStep('done');
    // Save to local state and close modal
    setTimeout(() => { 
      onPay(profile.id); 
      onClose(); 
    }, 2000);
  };

  if (step === 'paying') {
    return (
      <PaymentGateway
        amount={chosen.price}
        customerName="Matrimony User"
        onClose={() => setStep('plan')}
        onPaymentSuccess={handlePaymentSuccess}
      />
    );
  }

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="pay-modal" onClick={e => e.stopPropagation()}>
        <button className="modal-close-btn" onClick={onClose}>✕</button>

        {step === 'done' ? (
          <div className="pay-done">
            <div className="pay-done-anim">✅</div>
            <h3>Payment Received! Profile Unlocked.</h3>
            <p>Opening full profile of <strong>{profile.name}</strong>…</p>
          </div>
        ) : (
          <>
            <div className="pay-modal-header">
              <div className="pay-profile-thumb" style={{ background: profile.avatarBg }}>{profile.avatar}</div>
              <div>
                <p className="pay-label">Unlock profile of</p>
                <h3 className="pay-profile-name">{profile.name}</h3>
                <p className="pay-profile-meta">{profile.age} yrs • {profile.location} • {profile.profession}</p>
              </div>
            </div>

            <p className="pay-section-title">Choose your plan</p>
            <div className="pay-plans">
              {plans.map(p => (
                <label key={p.id} className={`pay-plan-card ${plan === p.id ? 'selected' : ''}`}>
                  <input type="radio" name="plan" value={p.id} checked={plan === p.id} onChange={() => setPlan(p.id)} />
                  <div className="plan-top">
                    <span className="plan-label">{p.label}</span>
                    {p.id === 'bundle5' && <span className="plan-popular">Popular</span>}
                    {p.id === 'premium' && <span className="plan-best">Best Value</span>}
                  </div>
                  <div className="plan-price">₹{p.price}</div>
                  <div className="plan-desc">{p.desc}</div>
                </label>
              ))}
            </div>

            <div className="pay-features">
              {['Full horoscope & jathagam details', 'Contact number & email address', 'Family background & photos', 'Direct chat & WhatsApp access', '100% verified profile data'].map(f => (
                <div key={f} className="pay-feature-row"><span className="feat-check">✔</span> {f}</div>
              ))}
            </div>

            <button className="pay-cta-btn" onClick={handlePay}>
              <span>🔓 Pay ₹{chosen.price} & Unlock Now</span>
            </button>
            <p className="pay-security">🔒 256-bit SSL secured • Razorpay / UPI / Cards</p>
          </>
        )}
      </div>
    </div>
  );
};

/* ══════════════════════════════════════════════════
   Full Profile Modal
══════════════════════════════════════════════════ */
const FullProfileModal = ({ profile, onClose }) => {
  const [tab, setTab] = useState('basic');
  const tabs = [
    { id: 'basic', label: 'Basic Info' },
    { id: 'horoscope', label: 'Horoscope' },
    { id: 'family', label: 'Family' },
    { id: 'contact', label: 'Contact' },
  ];

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="fp-modal" onClick={e => e.stopPropagation()}>
        <button className="modal-close-btn" onClick={onClose}>✕</button>

        {/* Header */}
        <div className="fp-modal-hero" style={{ background: profile.avatarBg }}>
          <div className="fp-avatar-lg">{profile.avatar}</div>
          {profile.isVerified && <span className="fp-verified-badge">✔ Verified</span>}
          {profile.isOnline && <span className="fp-online-dot"></span>}
        </div>
        <div className="fp-modal-titlebar">
          <div>
            <h2 className="fp-modal-name">{profile.name}</h2>
            <p className="fp-modal-sub">{profile.age} yrs • {profile.height} • {profile.location}</p>
          </div>
          <MatchRing score={profile.matchScore} />
        </div>

        {/* Tabs */}
        <div className="fp-tabs">
          {tabs.map(t => (
            <button key={t.id} className={`fp-tab ${tab === t.id ? 'active' : ''}`} onClick={() => setTab(t.id)}>{t.label}</button>
          ))}
        </div>

        {/* Tab Panels */}
        <div className="fp-tab-content">
          {tab === 'basic' && (
            <div className="fp-grid-2">
              {[
                ['Education', profile.education], ['Profession', profile.profession],
                ['Income', profile.income], ['Religion', profile.religion],
                ['Caste', profile.caste], ['Sub-Caste', profile.subCaste || '—'],
                ['Complexion', profile.complexion], ['Diet', profile.diet],
                ['Mother Tongue', profile.motherTongue],
              ].map(([k, v]) => (
                <div key={k} className="fp-detail-row">
                  <span className="fp-detail-key">{k}</span>
                  <span className="fp-detail-val">{v}</span>
                </div>
              ))}
              <div className="fp-bio-box">
                <p className="fp-bio-label">About</p>
                <p className="fp-bio-text">{profile.preview} Looking for a loving partner who shares similar values for a blessed life together.</p>
              </div>
            </div>
          )}
          {tab === 'horoscope' && (
            <div className="fp-horoscope-section">
              <div className="horoscope-banner">🕉️ Vedic Horoscope Details</div>
              <div className="fp-grid-2">
                {[
                  ['Star | நட்சத்திரம்', profile.star],
                  ['Rasi | ராசி', profile.rasi],
                  ['Lagnam', '—'],
                  ['Dosham', 'No Dosham'],
                  ['Birth Time', '06:30 AM'],
                  ['Birth Place', profile.location],
                ].map(([k, v]) => (
                  <div key={k} className="fp-detail-row">
                    <span className="fp-detail-key">{k}</span>
                    <span className="fp-detail-val">{v}</span>
                  </div>
                ))}
              </div>
              <div className="horoscope-note">
                <span>📜</span> Full jathagam chart available after mutual interest confirmation.
              </div>
            </div>
          )}
          {tab === 'family' && (
            <div className="fp-grid-2">
              {[
                ["Father's Occupation", profile.fatherOcc],
                ["Mother's Occupation", profile.motherOcc],
                ['Siblings', profile.siblings],
                ['Family Type', 'Nuclear Family'],
                ['Family Status', 'Middle Class'],
                ['Native Place', profile.location],
              ].map(([k, v]) => (
                <div key={k} className="fp-detail-row">
                  <span className="fp-detail-key">{k}</span>
                  <span className="fp-detail-val">{v}</span>
                </div>
              ))}
            </div>
          )}
          {tab === 'contact' && (
            <div className="fp-contact-panel">
              <div className="contact-item">
                <span className="contact-icon">📞</span>
                <div>
                  <p className="contact-label">Phone Number</p>
                  <p className="contact-val">+91 98765 43210</p>
                </div>
              </div>
              <div className="contact-item">
                <span className="contact-icon">✉️</span>
                <div>
                  <p className="contact-label">Email Address</p>
                  <p className="contact-val">{profile.name.toLowerCase().replace(' ', '.')}@gmail.com</p>
                </div>
              </div>
              <a className="whatsapp-btn" href="#!">
                <span>💬</span> Chat on WhatsApp
              </a>
              <a className="send-interest-big" href="#!">
                ❤️ Send Marriage Proposal
              </a>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

/* ══════════════════════════════════════════════════
   Profile Card (horizontal, matrimony-style)
══════════════════════════════════════════════════ */
const ProfileCard = ({ profile, onViewFull, unlockedIds, shortlisted, onShortlist }) => {
  const isUnlocked = unlockedIds.includes(profile.id);
  const isShortlisted = shortlisted.includes(profile.id);

  return (
    <div className="pcard">
      {/* Photo Panel */}
      <div className="pcard-photo" style={{ background: profile.avatarBg }}>
        <div className="pcard-avatar">{profile.avatar}</div>
        {profile.isOnline && <span className="pcard-online">● Online</span>}
        {profile.joinedDaysAgo <= 3 && <span className="pcard-new">New</span>}
        <button
          className={`pcard-heart ${isShortlisted ? 'active' : ''}`}
          onClick={() => onShortlist(profile.id)}
          title={isShortlisted ? 'Remove from shortlist' : 'Shortlist'}
        >♥</button>
      </div>

      {/* Info Panel */}
      <div className="pcard-info">
        <div className="pcard-title-row">
          <div>
            <h3 className="pcard-name">
              {profile.name}
              {profile.isVerified && <span className="pcard-verified" title="ID Verified">✔</span>}
            </h3>
            <p className="pcard-meta">{profile.age} yrs • {profile.height} • {profile.location}</p>
          </div>
          <MatchRing score={profile.matchScore} />
        </div>

        <div className="pcard-chips">
          <span className="chip chip-green">🕉 {profile.religion}</span>
          <span className="chip chip-blue">⭐ {profile.star}</span>
          <span className="chip chip-orange">🎓 {profile.education.split(' ').slice(-1)[0]}</span>
          <span className="chip chip-purple">💼 {profile.profession}</span>
          {profile.maritalStatus && (() => {
            const mb = maritalBadge[profile.maritalStatus] || { bg: 'rgba(156,163,175,0.12)', color: '#374151', icon: '📝' };
            return (
              <span className="chip chip-marital" style={{ background: mb.bg, color: mb.color }}>
                {mb.icon} {profile.maritalStatus}
              </span>
            );
          })()}
        </div>

        <div className="pcard-details-grid">
          <div className="pcd-item"><span>Caste</span><strong>{profile.caste}</strong></div>
          <div className="pcd-item"><span>Rasi</span><strong>{profile.rasi}</strong></div>
          <div className="pcd-item"><span>Income</span><strong>{profile.income}</strong></div>
          <div className="pcd-item"><span>Diet</span><strong>{profile.diet}</strong></div>
        </div>

        <p className="pcard-bio">{profile.preview}</p>

        <div className="pcard-actions">
          <button className="pcard-interest-btn" onClick={() => onViewFull(profile, 'interest')}>
            ❤️ Express Interest
          </button>
          {isUnlocked ? (
            <button className="pcard-view-btn unlocked" onClick={() => onViewFull(profile, 'full')}>
              👁 View Full Profile
            </button>
          ) : (
            <button className="pcard-view-btn locked" onClick={() => onViewFull(profile, 'pay')}>
              🔒 Unlock — ₹99
            </button>
          )}
        </div>
      </div>
    </div>
  );
};

/* ══════════════════════════════════════════════════
   Filter Accordion Item
══════════════════════════════════════════════════ */
const FilterAccordion = ({ label, children }) => {
  const [open, setOpen] = useState(true);
  return (
    <div className="faccordion">
      <button className="faccordion-header" onClick={() => setOpen(o => !o)}>
        <span>{label}</span>
        <span className={`faccordion-icon ${open ? 'open' : ''}`}>›</span>
      </button>
      {open && <div className="faccordion-body">{children}</div>}
    </div>
  );
};

/* ══════════════════════════════════════════════════
   MAIN PAGE
══════════════════════════════════════════════════ */
const Matrimony = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const isCreated = new URLSearchParams(location.search).get('created') === 'true';

  const [userProfile, setUserProfile] = useState({
    gender: 'male', age: 27, religion: 'Hindu', caste: 'Mudaliar', star: 'Rohini', rasi: 'Rishabam',
  });
  const [filters, setFilters] = useState({
    religion: 'All', caste: 'All', star: 'All', rasi: 'All',
    income: 'All', height: 'All', complexion: 'All', diet: 'All',
    maritalStatus: 'All',
    minAge: 20, maxAge: 40, gender: 'female',
  });
  const [activeTab, setActiveTab] = useState('all');
  const [modalState, setModalState] = useState(null);
  const [unlockedIds, setUnlockedIds] = useState([5, 8]);
  const [shortlisted, setShortlisted] = useState([]);
  const [showUserForm, setShowUserForm] = useState(!isCreated);
  const [profilesList, setProfilesList] = useState(allProfiles);
  const [interestName, setInterestName] = useState('');
  const [showInterestSuccess, setShowInterestSuccess] = useState(false);
  const [showMobileFilters, setShowMobileFilters] = useState(false);

  useEffect(() => {
    const fetchProfiles = async () => {
      try {
        const { data, error } = await supabase.from('matrimony_profiles').select('*');
        if (!error && data && data.length > 0) {
          const mapped = data.map(p => ({
            ...p,
            subCaste: p.sub_caste || p.subCaste,
            motherTongue: p.mother_tongue || p.motherTongue,
            fatherOcc: p.father_occ || p.fatherOcc,
            motherOcc: p.mother_occ || p.motherOcc,
            maritalStatus: p.marital_status || p.maritalStatus,
            isPremium: p.is_premium || p.isPremium,
            isVerified: p.is_verified || p.isVerified,
            avatarBg: p.avatar_bg || p.avatarBg,
            joinedDaysAgo: p.created_at ? Math.floor((new Date() - new Date(p.created_at)) / (86400 * 1000)) : 1
          }));
          // Set profiles prioritizing supabase results first, then defaults if any
          setProfilesList([...mapped, ...allProfiles]);
        }
      } catch (err) {
        console.error('Failed to fetch matrimony profiles', err);
      }
    };
    fetchProfiles();
  }, []);

  const oppositeGender = userProfile.gender === 'male' ? 'female' : 'male';

  const baseProfiles = profilesList
    .filter(p => p.gender === (filters.gender || oppositeGender))
    .filter(p => filters.religion === 'All' || p.religion === filters.religion)
    .filter(p => filters.caste === 'All' || p.caste === filters.caste)
    .filter(p => filters.star === 'All' || p.star === filters.star)
    .filter(p => filters.rasi === 'All' || p.rasi === filters.rasi)
    .filter(p => filters.income === 'All' || p.income === filters.income)
    .filter(p => filters.complexion === 'All' || p.complexion === filters.complexion)
    .filter(p => filters.diet === 'All' || p.diet === filters.diet)
    .filter(p => filters.maritalStatus === 'All' || p.maritalStatus === filters.maritalStatus)
    .filter(p => p.age >= filters.minAge && p.age <= filters.maxAge)
    .map(p => ({ ...p, matchScore: computeMatch(userProfile, p) }))
    .sort((a, b) => b.matchScore - a.matchScore);

  const displayProfiles = activeTab === 'top'
    ? baseProfiles.filter(p => p.matchScore >= 80)
    : activeTab === 'new'
    ? baseProfiles.filter(p => p.joinedDaysAgo <= 5).sort((a, b) => a.joinedDaysAgo - b.joinedDaysAgo)
    : activeTab === 'shortlist'
    ? baseProfiles.filter(p => shortlisted.includes(p.id))
    : baseProfiles;

  const sf = (k, v) => setFilters(prev => ({ ...prev, [k]: v }));

  const resetFilters = () => setFilters({
    religion: 'All', caste: 'All', star: 'All', rasi: 'All',
    income: 'All', height: 'All', complexion: 'All', diet: 'All',
    maritalStatus: 'All',
    minAge: 20, maxAge: 40, gender: oppositeGender,
  });

  const toggleShortlist = id => setShortlisted(prev =>
    prev.includes(id) ? prev.filter(x => x !== id) : [...prev, id]
  );

  const handleAction = (profile, type) => {
    if (type === 'interest') {
      setInterestName(profile.name);
      setShowInterestSuccess(true);
    } else {
      setModalState({ profile, type });
    }
  };

  return (
    <main className="mp">
      {/* ════════ HERO ════════ */}
      <section className="mp-hero">
        <div className="mp-hero-bg"></div>
        <div className="mp-hero-pattern"></div>
        <div className="container mp-hero-inner">
          <div className="mp-hero-text">
            <p className="mp-hero-eyebrow">
              <span className="eyebrow-line"></span>
              திருமண பொருத்தம் · Sacred Matchmaking
              <span className="eyebrow-line"></span>
            </p>
            <h1 className="mp-hero-h1">Find Your Perfect<br /><span className="mp-hero-accent">Life Partner</span></h1>
            <p className="mp-hero-sub">Vedic Jathagam Matching · Verified Profiles · Trusted by 100+ Families</p>
            <Link to="/matrimony/porutham" className="mp-porutham-cta">
              🔮 Free Thirumana Porutham Checker | திருமண பொருத்தம் →
            </Link>
          </div>

          {showUserForm ? (
            <div className="mp-search-card" style={{ textAlign: 'center' }}>
              <div style={{ fontSize: '4.5rem', marginBottom: '1rem', filter: 'drop-shadow(0 10px 20px rgba(0,0,0,0.3))' }}>💍</div>
              <h2 className="search-card-title" style={{ fontSize: '2rem', marginBottom: '0.8rem', color: '#fff' }}>Find Your Perfect Match</h2>
              <p className="search-card-sub" style={{ marginBottom: '2.5rem', maxWidth: '420px', margin: '0 auto', lineHeight: '1.6', fontSize: '1.05rem', color: 'rgba(255,255,255,0.6)' }}>
                Create your complete profile to unlock and view thousands of verified matches tailored just for you.
              </p>
              
              <button 
                onClick={() => navigate('/matrimony/create-profile')}
                className="btn-premium-hero"
              >
                <span>📝 Create Full Profile</span>
              </button>
            </div>
          ) : (
            <div className="mp-search-card compact">
              <div className="compact-profile-row">
                <div className="compact-avatar">
                   {userProfile.gender === 'male' ? '🤵' : '👰'}
                </div>
                <div>
                  <p className="compact-label">Matching as</p>
                  <p className="compact-val">{userProfile.gender === 'male' ? 'Groom' : 'Bride'} · {userProfile.age} yrs</p>
                  <p className="compact-val" style={{fontSize: '0.85rem', color:'rgba(255,255,255,0.6)', fontWeight: 500}}>
                    {userProfile.caste} · {userProfile.star}
                  </p>
                </div>
              </div>
              <button className="compact-edit-btn" onClick={() => setShowUserForm(true)}>✏️ Edit Profile</button>
            </div>
          )}
        </div>

        {/* Stats Strip */}
        <div className="mp-stats-strip">
          {[
            { n: '100+', l: 'Verified Profiles' },
            { n: '100+', l: 'Success Stories' },
            { n: '27 Stars', l: 'Vedic Matching' },
            { n: '100%', l: 'Privacy Protected' },
          ].map(s => (
            <div key={s.l} className="mp-stat">
              <span className="stat-num">{s.n}</span>
              <span className="stat-lbl">{s.l}</span>
            </div>
          ))}
        </div>
      </section>

      {/* ════════ MAIN CONTENT ════════ */}
      {!showUserForm && (
        <div className="container mp-content">
          {/* Mobile Filter Toggle */}
          <div className="mp-mobile-filter-bar">
             <button className="mp-filter-toggle-btn" onClick={() => setShowMobileFilters(true)}>
                <span>🔍 Filter Matches</span>
                <span className="filter-count-badge">
                  {Object.values(filters).filter(v => v !== 'All' && v !== 20 && v !== 40).length}
                </span>
             </button>
             <div className="mp-active-tab-indicator">
                {activeTab === 'all' ? 'All Matches' : activeTab === 'top' ? 'Top Matches' : activeTab === 'new' ? 'New Profiles' : 'Shortlisted'}
             </div>
          </div>

          <div className="mp-layout">
            {/* ── FILTER SIDEBAR (Desktop) / DRAWER (Mobile) ── */}
            <aside className={`mp-sidebar ${showMobileFilters ? 'mobile-open' : ''}`}>
              <div className="sidebar-mobile-header">
                 <h3>Filter Profiles</h3>
                 <button className="sidebar-close-btn" onClick={() => setShowMobileFilters(false)}>✕</button>
              </div>
              <div className="sidebar-scroll-area">
                <div className="sidebar-header-row">
                  <h3 className="sidebar-title">🔍 Filter Matches</h3>
                  <button className="sidebar-clear" onClick={resetFilters}>Reset</button>
                </div>

              <FilterAccordion label="Looking For">
                <div className="filter-radio-row">
                  {['male', 'female'].map(g => (
                    <label key={g} className={`filter-radio-lbl ${filters.gender === g ? 'active' : ''}`}>
                      <input type="radio" name="fg" value={g} checked={filters.gender === g} onChange={() => sf('gender', g)} />
                      {g === 'male' ? '🤵 Groom' : '👰 Bride'}
                    </label>
                  ))}
                </div>
              </FilterAccordion>

              <FilterAccordion label="Age Range">
                <div className="age-row">
                  <input type="number" min="18" max="60" value={filters.minAge} onChange={e => sf('minAge', +e.target.value)} />
                  <span className="age-sep">—</span>
                  <input type="number" min="18" max="60" value={filters.maxAge} onChange={e => sf('maxAge', +e.target.value)} />
                  <span className="age-unit">yrs</span>
                </div>
              </FilterAccordion>

              {/* Marital Status — Tamil matrimony style pill chips */}
              <FilterAccordion label="Marital Status | திருமண நிலை">
                <div className="ms-chip-group">
                  {maritalStatuses.map(ms => {
                    const badge = ms !== 'All' ? maritalBadge[ms] : null;
                    return (
                      <button
                        key={ms}
                        className={`ms-chip ${filters.maritalStatus === ms ? 'ms-chip-active' : ''}`}
                        style={filters.maritalStatus === ms && badge ? { background: badge.bg, color: badge.color, borderColor: badge.color } : {}}
                        onClick={() => sf('maritalStatus', ms)}
                      >
                        {badge ? `${badge.icon} ` : ''}{ms}
                      </button>
                    );
                  })}
                </div>
              </FilterAccordion>

              {[
                { key: 'religion', label: 'Religion | மதம்', opts: religions },
                { key: 'caste', label: 'Caste | ஜாதி', opts: castes },
                { key: 'star', label: 'Star | நட்சத்திரம்', opts: stars },
                { key: 'rasi', label: 'Rasi | ராசி', opts: rasis },
                { key: 'income', label: 'Income | வருமானம்', opts: incomes },
                { key: 'complexion', label: 'Complexion | நிறம்', opts: complexions },
                { key: 'diet', label: 'Diet | உணவு', opts: diets },
              ].map(({ key, label, opts }) => (
                <FilterAccordion key={key} label={label}>
                  <select className="fselect" value={filters[key]} onChange={e => sf(key, e.target.value)}>
                    {opts.map(o => <option key={o} value={o}>{o}</option>)}
                  </select>
                </FilterAccordion>
              ))}

              {/* Premium Upsell */}
              <div className="sidebar-premium-box">
                <div className="spb-crown">👑</div>
                <h4>Go Premium</h4>
                <p>Unlock all profiles, contact details & more for just <strong>₹999/mo</strong></p>
                <button className="spb-btn">Upgrade Now</button>
              </div>
              </div>
            </aside>

            {showMobileFilters && <div className="mp-sidebar-overlay" onClick={() => setShowMobileFilters(false)}></div>}

            {/* ── PROFILE AREA ── */}
            <div className="mp-profiles-col">
              {/* Tabs */}
              <div className="mp-tabs-bar">
                {[
                  { id: 'all', label: `All Matches (${baseProfiles.length})` },
                  { id: 'top', label: `Top Matches (${baseProfiles.filter(p => p.matchScore >= 80).length})` },
                  { id: 'new', label: `New Profiles` },
                  { id: 'shortlist', label: `❤ Shortlisted (${shortlisted.length})` },
                ].map(t => (
                  <button key={t.id} className={`mp-tab ${activeTab === t.id ? 'active' : ''}`}
                    onClick={() => setActiveTab(t.id)}>{t.label}</button>
                ))}
              </div>

              {displayProfiles.length === 0 ? (
                <div className="mp-empty">
                  <div className="mp-empty-icon">💔</div>
                  <h3>No profiles found</h3>
                  <p>Try adjusting filters or switching tabs.</p>
                  <button className="mp-empty-reset" onClick={resetFilters}>Reset Filters</button>
                </div>
              ) : (
                <div className="mp-cards-list">
                  {displayProfiles.map(profile => (
                    <ProfileCard key={profile.id} profile={profile}
                      onViewFull={handleAction}
                      unlockedIds={unlockedIds}
                      shortlisted={shortlisted}
                      onShortlist={toggleShortlist} />
                  ))}
                </div>
              )}
            </div>
          </div>
        </div>
      )}

      {/* ════════ MODALS ════════ */}
      {modalState?.type === 'pay' && (
        <PayModal profile={modalState.profile}
          onClose={() => setModalState(null)}
          onPay={id => setUnlockedIds(prev => [...prev, id])} />
      )}
      {modalState?.type === 'full' && (
        <FullProfileModal profile={modalState.profile}
          onClose={() => setModalState(null)} />
      )}

      <SuccessModal 
        isOpen={showInterestSuccess} 
        onClose={() => setShowInterestSuccess(false)}
        title="Interest Sent! ❤️"
        message={`Your interest has been successfully sent to ${interestName}. They will view your profile shortly.`}
        actionText="Awesome!"
      />
    </main>
  );
};

export default Matrimony;
