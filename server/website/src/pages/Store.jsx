import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { supabase } from '../supabaseClient';
import './Store.css';

/* ── Default product catalogue ──────────────────────── */
const INITIAL_PRODUCTS = [
  {
    id: 1, category: 'Astrology',
    name: 'KP Astrology Book Set', name_ta: 'கே.பி ஜோதிட புத்தக தொகுப்பு',
    price: 850, originalPrice: 1200, rating: 4.8, reviews: 124,
    emoji: '📚', badge: 'Best Seller',
    description: 'Complete 3-volume set for KP Astrology practitioners.',
    seller: 'AadhiGuru',
  },
  {
    id: 2, category: 'Puja',
    name: 'Navgraha Yantra Set', name_ta: 'நவகிரக யந்திர தொகுப்பு',
    price: 1499, originalPrice: 1999, rating: 4.6, reviews: 89,
    emoji: '🔯', badge: 'Top Rated',
    description: 'Energized copper Navgraha Yantras with installation guide.',
    seller: 'AadhiGuru',
  },
  {
    id: 3, category: 'Yoga',
    name: 'Anti-Slip Yoga Mat', name_ta: 'யோகா மேட்',
    price: 699, originalPrice: 999, rating: 4.5, reviews: 213,
    emoji: '🧘', badge: 'New',
    description: '6mm thick eco-friendly TPE mat with alignment lines.',
    seller: 'AadhiGuru',
  },
  {
    id: 4, category: 'Acupuncture',
    name: 'Acupressure Mat & Pillow', name_ta: 'அக்குபிரஷர் மேட்',
    price: 549, originalPrice: 799, rating: 4.4, reviews: 67,
    emoji: '🌿', badge: '',
    description: 'Lotus-spike acupressure set for daily wellness routines.',
    seller: 'AadhiGuru',
  },
  {
    id: 5, category: 'Vastu',
    name: 'Vastu Pyramid Set (9 pcs)', name_ta: 'வாஸ்து பிரமிட் தொகுப்பு',
    price: 399, originalPrice: 599, rating: 4.7, reviews: 156,
    emoji: '🔺', badge: 'Popular',
    description: 'Crystal Vastu pyramids for positive energy flow.',
    seller: 'AadhiGuru',
  },
  {
    id: 6, category: 'Puja',
    name: 'Copper Puja Thali Set', name_ta: 'செம்பு பூஜை தாளி',
    price: 1199, originalPrice: 1599, rating: 4.9, reviews: 302,
    emoji: '🪔', badge: 'Best Seller',
    description: 'Premium copper set with diyas, incense holder & bell.',
    seller: 'AadhiGuru',
  },
  {
    id: 7, category: 'Astrology',
    name: 'Birth Chart Report (PDF)', name_ta: 'ஜாதக அறிக்கை',
    price: 299, originalPrice: 499, rating: 5.0, reviews: 78,
    emoji: '⭐', badge: 'Digital',
    description: 'Detailed personalised KP birth chart with predictions.',
    seller: 'AadhiGuru',
  },
  {
    id: 9, category: 'Software',
    name: 'AadhiGuru Pro Studio', name_ta: 'ஆதிகுரு ப்ரோ ஸ்டுடியோ',
    price: 0, originalPrice: 9999, rating: 4.9, reviews: 542,
    emoji: '💻', badge: 'App Exclusive',
    description: 'Professional astrology studio. Now exclusive for app users.',
    seller: 'AadhiGuru',
    isAppExclusive: true,
  },
  {
    id: 8, category: 'Yoga',
    name: 'Pranayama Instruction Cards', name_ta: 'பிரணாயாம அட்டைகள்',
    price: 149, originalPrice: 249, rating: 4.3, reviews: 44,
    emoji: '🌬️', badge: '',
    description: '30 laminated cards with step-by-step breathing exercises.',
    seller: 'AadhiGuru',
  },
];

const CATEGORIES = ['All', 'Astrology', 'Software', 'Puja', 'Yoga', 'Acupuncture', 'Vastu'];
const SORT_OPTIONS = [
  { value: 'popular', label: 'Most Popular' },
  { value: 'price_asc', label: 'Price: Low to High' },
  { value: 'price_desc', label: 'Price: High to Low' },
  { value: 'rating', label: 'Top Rated' },
];

/* ── Star component ─────────────────────────────────── */
const Stars = ({ rating }) => {
  const full = Math.floor(rating);
  const half = rating % 1 >= 0.5;
  return (
    <span className="stars">
      {Array.from({ length: 5 }, (_, i) => (
        <span key={i} className={i < full ? 'star-full' : i === full && half ? 'star-half' : 'star-empty'}>★</span>
      ))}
    </span>
  );
};

/* ── Main Store component ───────────────────────────── */
const Store = () => {
  const navigate = useNavigate();

  /* Products stored in localStorage */
  const [products, setProducts] = useState(() => {
    const saved = localStorage.getItem('aadhiguru_store_products');
    return saved ? JSON.parse(saved) : INITIAL_PRODUCTS;
  });

  useEffect(() => {
    const fetchProducts = async () => {
      try {
        const { data, error } = await supabase.from('store_products').select('*');
        if (!error && data && data.length > 0) {
          // Normalize snake_case from DB
          const normalized = data.map(p => ({
            ...p,
            originalPrice: p.original_price || p.price
          }));
          setProducts(normalized);
        }
      } catch (err) {
        console.error("Supabase fetch failed", err);
      }
    };
    fetchProducts();
  }, []);

  /* Cart stored in localStorage */
  const [cart, setCart] = useState(() => {
    const saved = localStorage.getItem('aadhiguru_cart');
    return saved ? JSON.parse(saved) : [];
  });

  const [activeCategory, setActiveCategory] = useState('All');
  const [sortBy, setSortBy] = useState('popular');
  const [search, setSearch] = useState('');
  const [cartOpen, setCartOpen] = useState(false);
  const [sellOpen, setSellOpen] = useState(false);
  const [quickView, setQuickView] = useState(null);
  const [addedId, setAddedId] = useState(null);

  /* Sell form state */
  const [sellForm, setSellForm] = useState({
    name: '', name_ta: '', category: 'Astrology',
    price: '', originalPrice: '', description: '', emoji: '📦',
    sellerName: '',
  });
  const [sellSuccess, setSellSuccess] = useState(false);

  /* Persist */
  useEffect(() => { localStorage.setItem('aadhiguru_store_products', JSON.stringify(products)); }, [products]);
  useEffect(() => { localStorage.setItem('aadhiguru_cart', JSON.stringify(cart)); }, [cart]);

  /* Filter & sort */
  const filtered = products
    .filter(p => activeCategory === 'All' || p.category === activeCategory)
    .filter(p => p.name.toLowerCase().includes(search.toLowerCase()) || p.name_ta.includes(search))
    .sort((a, b) => {
      if (sortBy === 'price_asc') return a.price - b.price;
      if (sortBy === 'price_desc') return b.price - a.price;
      if (sortBy === 'rating') return b.rating - a.rating;
      return b.reviews - a.reviews; // popular
    });

  /* Cart helpers */
  const addToCart = (product) => {
    setCart(prev => {
      const existing = prev.find(i => i.id === product.id);
      if (existing) return prev.map(i => i.id === product.id ? { ...i, qty: i.qty + 1 } : i);
      return [...prev, { ...product, qty: 1 }];
    });
    setAddedId(product.id);
    setTimeout(() => setAddedId(null), 1500);
  };

  const removeFromCart = (id) => setCart(prev => prev.filter(i => i.id !== id));
  const updateQty = (id, delta) => setCart(prev =>
    prev.map(i => i.id === id ? { ...i, qty: Math.max(1, i.qty + delta) } : i)
  );

  const cartTotal = cart.reduce((sum, i) => sum + i.price * i.qty, 0);
  const cartCount = cart.reduce((sum, i) => sum + i.qty, 0);

  /* Sell submit */
  const handleSellSubmit = async (e) => {
    e.preventDefault();
    const newProduct = {
      name: sellForm.name,
      name_ta: sellForm.name_ta || sellForm.name,
      category: sellForm.category,
      price: Number(sellForm.price),
      original_price: Number(sellForm.originalPrice) || Number(sellForm.price),
      rating: 0,
      reviews: 0,
      emoji: sellForm.emoji,
      badge: 'New',
      description: sellForm.description,
      seller: sellForm.sellerName || 'Community Seller',
    };
    
    try {
      const { data, error } = await supabase.from('store_products').insert([newProduct]).select('*');
      if (!error && data && data.length > 0) {
        const inserted = { ...data[0], originalPrice: data[0].original_price || data[0].price };
        setProducts(prev => [inserted, ...prev]);
      } else {
        throw new Error("Supabase insert failed or unavailable");
      }
    } catch (err) {
      // Fallback for local testing without Supabase credentials
      const fallbackProduct = { ...newProduct, id: Date.now(), originalPrice: newProduct.original_price };
      setProducts(prev => [fallbackProduct, ...prev]);
    }

    setSellSuccess(true);
    setSellForm({ name: '', name_ta: '', category: 'Astrology', price: '', originalPrice: '', description: '', emoji: '📦', sellerName: '' });
    setTimeout(() => { setSellSuccess(false); setSellOpen(false); }, 2500);
  };

  const discount = (orig, price) => Math.round((1 - price / orig) * 100);

  return (
    <div className="store-page">

      {/* ── Hero Banner ───────────────────────────────── */}
      <div className="store-hero">
        <div className="container store-hero-content">
          <p className="section-subtitle">Spiritual Marketplace</p>
          <h1 className="store-hero-title">🛕 AadhiGuru Store</h1>
          <p className="store-hero-sub">Authentic spiritual products · Astrology tools · Wellness essentials</p>
          <div className="store-hero-actions">
            <button className="btn btn-outline-white" onClick={() => setCartOpen(true)}>
              🛒 Cart {cartCount > 0 && <span className="cart-badge-hero">{cartCount}</span>}
            </button>
          </div>
        </div>
      </div>

      <div className="container store-body">

        {/* ── Controls Bar ─────────────────────────────── */}
        <div className="store-controls">
          <div className="store-search-wrap">
            <span className="search-icon">🔍</span>
            <input
              className="store-search"
              type="text"
              placeholder="Search products…"
              value={search}
              onChange={e => setSearch(e.target.value)}
            />
            {search && <button className="search-clear" onClick={() => setSearch('')}>✕</button>}
          </div>
          <select className="store-sort" value={sortBy} onChange={e => setSortBy(e.target.value)}>
            {SORT_OPTIONS.map(o => <option key={o.value} value={o.value}>{o.label}</option>)}
          </select>
          <button className="cart-fab" onClick={() => setCartOpen(true)}>
            🛒{cartCount > 0 && <span className="cart-badge">{cartCount}</span>}
          </button>
        </div>

        {/* ── Category Chips ────────────────────────────── */}
        <div className="category-chips">
          {CATEGORIES.map(cat => (
            <button
              key={cat}
              className={`chip ${activeCategory === cat ? 'chip-active' : ''}`}
              onClick={() => setActiveCategory(cat)}
            >
              {cat}
            </button>
          ))}
        </div>

        {/* ── Results count ─────────────────────────────── */}
        <p className="results-count">{filtered.length} product{filtered.length !== 1 ? 's' : ''} found</p>

        {/* ── Product Grid ──────────────────────────────── */}
        {filtered.length === 0 ? (
          <div className="empty-state">
            <span>🔍</span>
            <p>No products found. Try a different search!</p>
          </div>
        ) : (
          <div className="products-grid">
            {filtered.map(product => (
              <div key={product.id} className="product-card">
                {product.badge && <span className="product-badge">{product.badge}</span>}
                <div className="product-emoji-wrap" onClick={() => setQuickView(product)}>
                  <span className="product-emoji">{product.emoji}</span>
                </div>
                <div className="product-info">
                  <span className="product-category-tag">{product.category}</span>
                  <h3 className="product-name" onClick={() => setQuickView(product)}>{product.name}</h3>
                  <p className="product-name-ta">{product.name_ta}</p>
                  <div className="product-rating">
                    <Stars rating={product.rating} />
                    <span className="review-count">({product.reviews})</span>
                  </div>
                <div className="product-price-row">
                  {product.isAppExclusive ? (
                    <span className="product-price free-text">FREE for App Users</span>
                  ) : (
                    <>
                      <span className="product-price">₹{product.price.toLocaleString()}</span>
                      {product.originalPrice > product.price && (
                        <>
                          <span className="product-original">₹{product.originalPrice.toLocaleString()}</span>
                          <span className="product-discount">{discount(product.originalPrice, product.price)}% off</span>
                        </>
                      )}
                    </>
                  )}
                </div>
                <p className="product-seller">Sold by: {product.seller}</p>
              </div>
              {product.isAppExclusive ? (
                <button
                  className="add-to-cart-btn app-btn"
                  onClick={() => navigate('/software')}
                >
                  📱 View Software
                </button>
              ) : (
                <button
                  className={`add-to-cart-btn ${addedId === product.id ? 'added' : ''}`}
                  onClick={() => addToCart(product)}
                >
                  {addedId === product.id ? '✓ Added!' : '🛒 Add to Cart'}
                </button>
              )}
            </div>
            ))}
          </div>
        )}
      </div>

      {/* ══ CART DRAWER ══════════════════════════════════ */}
      {cartOpen && (
        <div className="drawer-overlay cart-overlay" onClick={() => setCartOpen(false)}>
          <div className="cart-drawer" onClick={e => e.stopPropagation()}>
            <div className="drawer-header">
              <h2>🛒 Your Cart</h2>
              <button className="drawer-close" onClick={() => setCartOpen(false)}>✕</button>
            </div>

            {cart.length === 0 ? (
              <div className="cart-empty">
                <span>🛒</span>
                <p>Your cart is empty.</p>
                <button className="btn btn-primary" onClick={() => setCartOpen(false)}>Browse Products</button>
              </div>
            ) : (
              <>
                <div className="cart-items">
                  {cart.map(item => (
                    <div key={item.id} className="cart-item">
                      <span className="cart-item-emoji">{item.emoji}</span>
                      <div className="cart-item-info">
                        <p className="cart-item-name">{item.name}</p>
                        <p className="cart-item-price">₹{item.price.toLocaleString()}</p>
                      </div>
                      <div className="qty-controls">
                        <button onClick={() => updateQty(item.id, -1)}>−</button>
                        <span>{item.qty}</span>
                        <button onClick={() => updateQty(item.id, +1)}>+</button>
                      </div>
                      <button className="remove-btn" onClick={() => removeFromCart(item.id)}>🗑</button>
                    </div>
                  ))}
                </div>
                <div className="cart-summary">
                  <div className="cart-total-row">
                    <span>Subtotal ({cartCount} items)</span>
                    <strong>₹{cartTotal.toLocaleString()}</strong>
                  </div>
                  <div className="cart-total-row">
                    <span>Delivery</span>
                    <strong className="free-delivery">FREE</strong>
                  </div>
                  <div className="cart-total-row grand">
                    <span>Total</span>
                    <strong>₹{cartTotal.toLocaleString()}</strong>
                  </div>
                  <button className="btn checkout-btn w-full" onClick={() => { setCartOpen(false); navigate('/checkout'); }}>
                    Proceed to Checkout →
                  </button>
                </div>
              </>
            )}
          </div>
        </div>
      )}


      {/* ══ SELL PRODUCT MODAL ════════════════════════════ */}
      {sellOpen && (
        <div className="drawer-overlay modal-overlay" onClick={() => setSellOpen(false)}>
          <div className="checkout-modal" onClick={e => e.stopPropagation()}>
            <div className="drawer-header">
              <h2>🏪 List Your Product</h2>
              <button className="drawer-close" onClick={() => setSellOpen(false)}>✕</button>
            </div>

            {sellSuccess ? (
              <div className="success-state">
                <span className="success-check">✓</span>
                <h3>Product Listed!</h3>
                <p>Your product is now live in the store.</p>
              </div>
            ) : (
              <form className="checkout-form" onSubmit={handleSellSubmit}>
                <div className="form-row-2">
                  <div className="form-field">
                    <label>Product Name (English) *</label>
                    <input required placeholder="e.g. Rudraksha Mala"
                      value={sellForm.name}
                      onChange={e => setSellForm({ ...sellForm, name: e.target.value })}
                    />
                  </div>
                  <div className="form-field">
                    <label>Product Name (Tamil)</label>
                    <input placeholder="e.g. ருத்ராக்ஷ மாலை"
                      value={sellForm.name_ta}
                      onChange={e => setSellForm({ ...sellForm, name_ta: e.target.value })}
                    />
                  </div>
                </div>
                <div className="form-row-2">
                  <div className="form-field">
                    <label>Category *</label>
                    <select required value={sellForm.category}
                      onChange={e => setSellForm({ ...sellForm, category: e.target.value })}
                    >
                      {CATEGORIES.filter(c => c !== 'All').map(c => (
                        <option key={c} value={c}>{c}</option>
                      ))}
                    </select>
                  </div>
                  <div className="form-field">
                    <label>Icon / Emoji</label>
                    <input placeholder="e.g. 📿" maxLength={2}
                      value={sellForm.emoji}
                      onChange={e => setSellForm({ ...sellForm, emoji: e.target.value })}
                    />
                  </div>
                </div>
                <div className="form-row-2">
                  <div className="form-field">
                    <label>Selling Price (₹) *</label>
                    <input required type="number" min="1" placeholder="e.g. 499"
                      value={sellForm.price}
                      onChange={e => setSellForm({ ...sellForm, price: e.target.value })}
                    />
                  </div>
                  <div className="form-field">
                    <label>Original / MRP (₹)</label>
                    <input type="number" placeholder="e.g. 799"
                      value={sellForm.originalPrice}
                      onChange={e => setSellForm({ ...sellForm, originalPrice: e.target.value })}
                    />
                  </div>
                </div>
                <div className="form-field">
                  <label>Description *</label>
                  <textarea required rows={3} placeholder="Describe your product…"
                    value={sellForm.description}
                    onChange={e => setSellForm({ ...sellForm, description: e.target.value })}
                  />
                </div>
                <div className="form-field">
                  <label>Your Name / Shop Name *</label>
                  <input required placeholder="e.g. Murugan Astrology Store"
                    value={sellForm.sellerName}
                    onChange={e => setSellForm({ ...sellForm, sellerName: e.target.value })}
                  />
                </div>
                <button type="submit" className="btn btn-secondary w-full">🚀 List Product Now</button>
              </form>
            )}
          </div>
        </div>
      )}

      {/* ══ QUICK VIEW MODAL ══════════════════════════════ */}
      {quickView && (
        <div className="drawer-overlay modal-overlay" onClick={() => setQuickView(null)}>
          <div className="quick-view-modal" onClick={e => e.stopPropagation()}>
            <button className="drawer-close qv-close" onClick={() => setQuickView(null)}>✕</button>
            <div className="qv-emoji">{quickView.emoji}</div>
            <span className="product-category-tag">{quickView.category}</span>
            <h2 className="qv-name">{quickView.name}</h2>
            <p className="product-name-ta">{quickView.name_ta}</p>
            <div className="product-rating" style={{ justifyContent: 'center', margin: '0.75rem 0' }}>
              <Stars rating={quickView.rating} />
              <span className="review-count">({quickView.reviews} reviews)</span>
            </div>
            <p className="qv-description">{quickView.description}</p>
            <div className="product-price-row" style={{ justifyContent: 'center', fontSize: '1.4rem', margin: '1rem 0' }}>
              <span className="product-price">₹{quickView.price.toLocaleString()}</span>
              {quickView.originalPrice > quickView.price && (
                <>
                  <span className="product-original">₹{quickView.originalPrice.toLocaleString()}</span>
                  <span className="product-discount">{discount(quickView.originalPrice, quickView.price)}% off</span>
                </>
              )}
            </div>
            <p className="product-seller">Sold by: {quickView.seller}</p>
            <button
              className={`add-to-cart-btn ${addedId === quickView.id ? 'added' : ''}`}
              style={{ width: '100%', marginTop: '1rem' }}
              onClick={() => { addToCart(quickView); }}
            >
              {addedId === quickView.id ? '✓ Added to Cart!' : '🛒 Add to Cart'}
            </button>
          </div>
        </div>
      )}


    </div>
  );
};

export default Store;
