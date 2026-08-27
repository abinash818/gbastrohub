import { useState, useRef } from 'react';
import './PoruthamChecker.css';

/* ════════════════════════════════════════════════════
   NAKSHATRA DATA
════════════════════════════════════════════════════ */
const NAKSHATRAS = [
  { id:1,  en:'Ashwini',          ta:'அஸ்வினி',         rasi:0,  gana:'Deva',     yoni:'Horse',    rajju:'Pada',   nadi:'Vata'   },
  { id:2,  en:'Bharani',          ta:'பரணி',            rasi:0,  gana:'Manushya', yoni:'Elephant', rajju:'Kati',   nadi:'Pitta'  },
  { id:3,  en:'Krittika',         ta:'கார்த்திகை',      rasi:0,  gana:'Rakshasa', yoni:'Goat',     rajju:'Nabhi',  nadi:'Kapha'  },
  { id:4,  en:'Rohini',           ta:'ரோகிணி',          rasi:1,  gana:'Manushya', yoni:'Serpent',  rajju:'Kanta',  nadi:'Vata'   },
  { id:5,  en:'Mrigashirsha',     ta:'மிருகசீரிஷம்',   rasi:1,  gana:'Deva',     yoni:'Serpent',  rajju:'Siro',   nadi:'Pitta'  },
  { id:6,  en:'Ardra',            ta:'திருவாதிரை',      rasi:2,  gana:'Manushya', yoni:'Dog',      rajju:'Kanta',  nadi:'Kapha'  },
  { id:7,  en:'Punarvasu',        ta:'புனர்பூசம்',      rasi:2,  gana:'Deva',     yoni:'Cat',      rajju:'Nabhi',  nadi:'Vata'   },
  { id:8,  en:'Pushya',           ta:'பூசம்',           rasi:3,  gana:'Deva',     yoni:'Goat',     rajju:'Kati',   nadi:'Pitta'  },
  { id:9,  en:'Ashlesha',         ta:'ஆயில்யம்',        rasi:3,  gana:'Rakshasa', yoni:'Cat',      rajju:'Pada',   nadi:'Kapha'  },
  { id:10, en:'Magha',            ta:'மகம்',            rasi:4,  gana:'Rakshasa', yoni:'Rat',      rajju:'Pada',   nadi:'Vata'   },
  { id:11, en:'Purva Phalguni',   ta:'பூரம்',           rasi:4,  gana:'Manushya', yoni:'Rat',      rajju:'Kati',   nadi:'Pitta'  },
  { id:12, en:'Uttara Phalguni',  ta:'உத்திரம்',        rasi:4,  gana:'Manushya', yoni:'Cow',      rajju:'Nabhi',  nadi:'Kapha'  },
  { id:13, en:'Hasta',            ta:'அஸ்தம்',          rasi:5,  gana:'Deva',     yoni:'Buffalo',  rajju:'Kanta',  nadi:'Vata'   },
  { id:14, en:'Chitra',           ta:'சித்திரை',        rasi:5,  gana:'Rakshasa', yoni:'Tiger',    rajju:'Siro',   nadi:'Pitta'  },
  { id:15, en:'Swati',            ta:'சுவாதி',          rasi:6,  gana:'Deva',     yoni:'Buffalo',  rajju:'Kanta',  nadi:'Kapha'  },
  { id:16, en:'Vishakha',         ta:'விசாகம்',         rasi:6,  gana:'Rakshasa', yoni:'Tiger',    rajju:'Nabhi',  nadi:'Vata'   },
  { id:17, en:'Anuradha',         ta:'அனுஷம்',          rasi:7,  gana:'Deva',     yoni:'Deer',     rajju:'Kati',   nadi:'Pitta'  },
  { id:18, en:'Jyeshtha',         ta:'கேட்டை',          rasi:7,  gana:'Rakshasa', yoni:'Deer',     rajju:'Pada',   nadi:'Kapha'  },
  { id:19, en:'Mula',             ta:'மூலம்',           rasi:8,  gana:'Rakshasa', yoni:'Dog',      rajju:'Pada',   nadi:'Vata'   },
  { id:20, en:'Purva Ashadha',    ta:'பூராடம்',         rasi:8,  gana:'Manushya', yoni:'Monkey',   rajju:'Kati',   nadi:'Pitta'  },
  { id:21, en:'Uttara Ashadha',   ta:'உத்திராடம்',      rasi:8,  gana:'Manushya', yoni:'Mongoose', rajju:'Nabhi',  nadi:'Kapha'  },
  { id:22, en:'Shravana',         ta:'திருவோணம்',       rasi:9,  gana:'Deva',     yoni:'Monkey',   rajju:'Kanta',  nadi:'Vata'   },
  { id:23, en:'Dhanishtha',       ta:'அவிட்டம்',        rasi:9,  gana:'Rakshasa', yoni:'Lion',     rajju:'Siro',   nadi:'Pitta'  },
  { id:24, en:'Shatabhisha',      ta:'சதயம்',           rasi:10, gana:'Rakshasa', yoni:'Horse',    rajju:'Kanta',  nadi:'Kapha'  },
  { id:25, en:'Purva Bhadrapada', ta:'பூரட்டாதி',       rasi:10, gana:'Manushya', yoni:'Lion',     rajju:'Nabhi',  nadi:'Vata'   },
  { id:26, en:'Uttara Bhadrapada',ta:'உத்திரட்டாதி',    rasi:11, gana:'Deva',     yoni:'Cow',      rajju:'Kati',   nadi:'Pitta'  },
  { id:27, en:'Revati',           ta:'ரேவதி',           rasi:11, gana:'Deva',     yoni:'Elephant', rajju:'Pada',   nadi:'Kapha'  },
];

const RASIS = [
  { id:0,  en:'Mesha',    ta:'மேஷம்',     lord:'Mars'    },
  { id:1,  en:'Rishabha', ta:'ரிஷபம்',    lord:'Venus'   },
  { id:2,  en:'Mithuna',  ta:'மிதுனம்',   lord:'Mercury' },
  { id:3,  en:'Kataka',   ta:'கடகம்',     lord:'Moon'    },
  { id:4,  en:'Simha',    ta:'சிம்மம்',   lord:'Sun'     },
  { id:5,  en:'Kanya',    ta:'கன்னி',     lord:'Mercury' },
  { id:6,  en:'Tula',     ta:'துலாம்',    lord:'Venus'   },
  { id:7,  en:'Vrischika',ta:'விருச்சிகம்',lord:'Mars'   },
  { id:8,  en:'Dhanus',   ta:'தனுசு',     lord:'Jupiter' },
  { id:9,  en:'Makara',   ta:'மகரம்',     lord:'Saturn'  },
  { id:10, en:'Kumbha',   ta:'கும்பம்',   lord:'Saturn'  },
  { id:11, en:'Meena',    ta:'மீனம்',     lord:'Jupiter' },
];

const PLANET_FRIENDS = {
  Mars:    ['Sun','Moon','Jupiter'],
  Venus:   ['Mercury','Saturn'],
  Mercury: ['Sun','Venus'],
  Moon:    ['Sun','Mercury'],
  Sun:     ['Moon','Mars','Jupiter'],
  Jupiter: ['Sun','Moon','Mars'],
  Saturn:  ['Mercury','Venus'],
};
const PLANET_ENEMIES = {
  Mars:    ['Mercury'],
  Venus:   ['Sun','Moon'],
  Mercury: ['Moon'],
  Moon:    [],
  Sun:     ['Venus','Saturn'],
  Jupiter: ['Mercury','Venus'],
  Saturn:  ['Sun','Moon','Mars'],
};

// Enemy yoni pairs (Natural enemies in nature)
const YONI_ENEMIES = [
  ['Cat','Rat'],['Dog','Deer'],['Serpent','Mongoose'],
  ['Elephant','Lion'],['Horse','Buffalo'],['Goat','Monkey'],
  ['Cow','Tiger']
];

// Vedha pairs (Mutual obstacles - 1-indexed nakshatra ids)
const VEDHA_PAIRS = [
  [1,18],[2,17],[3,16],[4,15],[5,23],[6,22],[7,21],
  [8,20],[9,19],[10,27],[11,26],[12,25],[13,24]
];

/* ── Star name → Nakshatra index mapping (from Matrimony data) ── */
const STAR_NAME_MAP = {
  'Ashwini':1,'Bharani':2,'Krithigai':3,'Rohini':4,'Mirugaserisham':5,
  'Ardra':6,'Punarvasu':7,'Pushya':8,'Ashlesha':9,'Magha':10,
  'Pooram':11,'Uthiram':12,'Hastham':13,'Chithirai':14,'Swati':15,
  'Visakam':16,'Anusha':17,'Kettai':18,'Moolam':19,'Pooradam':20,
  'Uthiradam':21,'Thiruvonam':22,'Avittam':23,'Sathayam':24,
  'Poorattathi':25,'Uthirattathi':26,'Revathi':27,
};

/* ── Deterministic nakshatra from DOB/TOB (Thirukanitham / Drik Siddhanta) ── */
const getNakIdx = (dob, tob = '12:00') => {
  if (!dob) return null;
  // Use J2000 Epoch for precise mean moon calculation
  // Apply +05:30 (IST) offset because the input is in Indian Standard Time
  const date = new Date(`${dob}T${tob || '12:00'}:00+05:30`);
  const j2000 = Date.UTC(2000, 0, 1, 12, 0, 0); // J2000.0 Epoch
  const diffDays = (date.getTime() - j2000) / (1000 * 60 * 60 * 24);
  
  // Mean Moon Longitude (L) and Mean Anomaly (M)
  let L = 218.316 + 13.17639648 * diffDays;
  let M = 134.963 + 13.06499295 * diffDays;
  
  // Thirukanitham / Drik Siddhanta specific corrections (multiple harmonics for accuracy)
  let moonLong = L + 6.289 * Math.sin(M * Math.PI / 180) 
                   + 1.274 * Math.sin((2 * L - M) * Math.PI / 180) 
                   + 0.658 * Math.sin(2 * M * Math.PI / 180);
                   
  // Normalize to 0-360
  moonLong = ((moonLong % 360) + 360) % 360;
  
  // Apply Lahiri (Chitra Paksha) Ayanamsa for strict Thirukanitham standard
  // Base 23.853 degrees in 2000 + 50.29 arc seconds per year precession
  const ayanamsa = 23.853 + (date.getFullYear() - 2000) * (50.290966 / 3600);
  let siderealMoon = ((moonLong - ayanamsa % 360) + 360) % 360;
  
  // Each nakshatra is 13.333333 degrees (13°20')
  return Math.floor(siderealMoon / 13.333333); 
};

/* ── Calculate all 10 Poruthams ── */
const calcPoruthams = (boyIdx, girlIdx) => {
  const b = NAKSHATRAS[boyIdx];
  const g = NAKSHATRAS[girlIdx];
  const bN = boyIdx + 1;  // 1-indexed
  const gN = girlIdx + 1;
  const res = [];

  // 1. Dina Porutham
  const dinaCount = ((bN - gN + 27) % 27) || 27;
  const dinaMod = dinaCount % 9 || 9;
  const dinaOk = [2,4,6,8,9].includes(dinaMod);
  res.push({
    name:'Dina Porutham', ta:'திண பொருத்தம்', pts:dinaOk?3:0, max:3, ok:dinaOk, critical:false,
    desc: dinaOk ? 'Harmonious daily life and health compatibility.' : 'Some day-to-day adjustment may be needed.',
  });

  // 2. Gana Porutham
  const gMap = { Deva: 1, Manushya: 2, Rakshasa: 3 };
  const bg = gMap[b.gana], gg = gMap[g.gana];
  let ganaPts = 0;
  if (bg === 1) ganaPts = (gg === 1) ? 6 : (gg === 2 ? 6 : 0);
  else if (bg === 2) ganaPts = (gg === 1) ? 5 : (gg === 2 ? 6 : 0);
  else if (bg === 3) ganaPts = (gg === 1) ? 1 : (gg === 2 ? 0 : 6); // Rakshasa-Rakshasa is OK in many systems
  
  res.push({
    name:'Gana Porutham', ta:'கண பொருத்தம்', pts:ganaPts, max:6, ok:ganaPts > 0, critical:false,
    desc: `Boy's Gana: ${b.gana} | Girl's Gana: ${g.gana}. ${ganaPts >= 5 ? 'Compatible temperaments.' : 'Temperament mismatch — proceed with caution.'}`,
  });

  // 3. Mahendra Porutham
  const mahCount = ((bN - gN + 27) % 27) + 1;
  const mahOk = [4,7,10,13,16,19,22,25].includes(mahCount);
  res.push({
    name:'Mahendra Porutham', ta:'மகேந்திர பொருத்தம்', pts:mahOk?2:0, max:2, ok:mahOk, critical:false,
    desc: mahOk ? 'Blessings for progeny (children) and prosperity.' : 'Progeny factors may need extra medical or spiritual attention.',
  });

  // 4. Stree Deergha Porutham
  const streeCount = ((bN - gN + 27) % 27) + 1;
  let streePts = 0;
  if (streeCount > 13) streePts = 1.5;
  else if (streeCount > 7) streePts = 0.5;

  res.push({
    name:'Stree Deergha Porutham', ta:'ஸ்திரீ தீர்க்க பொருத்தம்', pts:streePts, max:1.5, ok:streePts > 0, critical:false,
    desc: streePts === 1.5 ? 'Significant distance between stars is very auspicious.' : (streePts > 0 ? 'Acceptable star distance.' : 'Short star distance — traditional indicators suggest caution.'),
  });

  // 5. Yoni Porutham
  const bY = b.yoni, gY = g.yoni;
  const isEnemy = YONI_ENEMIES.some(p=>(p[0]===bY&&p[1]===gY)||(p[0]===gY&&p[1]===bY));
  let yoniPts = 0;
  if (bY === gY) yoniPts = 4;
  else if (isEnemy) yoniPts = 0;
  else yoniPts = 2; // Neutral/Friendly mix for simplification

  res.push({
    name:'Yoni Porutham', ta:'யோனி பொருத்தம்', pts:yoniPts, max:4, ok:yoniPts > 0, critical:false,
    desc: `Boy: ${bY} | Girl: ${gY}. ${yoniPts >= 2 ? 'Good physical compatibility.' : 'Physical incompatibility — might require adjustments.'}`,
  });

  // 6. Rasi Porutham
  const bR = b.rasi, gR = g.rasi;
  const rasiDiff = ((bR - gR + 12) % 12) + 1; // Count from Girl to Boy
  const goodRasi = [1, 7, 3, 4, 10, 11].includes(rasiDiff);
  const badRasi = [2, 5, 6, 8, 9, 12].includes(rasiDiff);
  
  res.push({
    name:'Rasi Porutham', ta:'ராசி பொருத்தம்', pts:goodRasi ? 7 : 0, max:7, ok:goodRasi, critical:false,
    desc: `${RASIS[bR].ta} & ${RASIS[gR].ta}. ${goodRasi ? 'Auspicious Moon sign placement.' : 'Challenging Moon sign placement (Shad-Ashtakam/Dwirdwasha).'}`,
  });

  // 7. Rasiyathipathi Porutham
  const bL = RASIS[bR].lord, gL = RASIS[gR].lord;
  const lordsOk = bL===gL
    || (PLANET_FRIENDS[bL]||[]).includes(gL)
    || (PLANET_FRIENDS[gL]||[]).includes(bL)
    || (!(PLANET_ENEMIES[bL]||[]).includes(gL) && !(PLANET_ENEMIES[gL]||[]).includes(bL));
  res.push({
    name:'Rasiyathipathi Porutham', ta:'ராசியாதிபதி பொருத்தம்', pts:lordsOk?5:0, max:5, ok:lordsOk, critical:false,
    desc: `Boy's lord: ${bL} | Girl's lord: ${gL}. ${lordsOk ? 'Planetary lords are friendly.' : 'Planetary lords are hostile.'}`,
  });

  // 8. Vasiya Porutham
  const VASIYA_MAP = {
    0:[4,7], 1:[3,6], 2:[5], 3:[7,8], 4:[3], 5:[2,11], 
    6:[3,5], 7:[3], 8:[11], 9:[0,10], 10:[8], 11:[9]
  };
  const vasiyaOk = bR===gR || (VASIYA_MAP[gR]||[]).includes(bR);
  res.push({
    name:'Vasiya Porutham', ta:'வசிய பொருத்தம்', pts:vasiyaOk?2:0, max:2, ok:vasiyaOk, critical:false,
    desc: vasiyaOk ? 'Natural mutual attraction exists.' : 'General compatibility — magnetic attraction is average.',
  });

  // 9. Rajju Porutham (Critical)
  const rajjuOk = b.rajju !== g.rajju;
  res.push({
    name:'Rajju Porutham', ta:'ராஜ்ஜு பொருத்தம்', pts:rajjuOk?5:0, max:5, ok:rajjuOk, critical:true,
    desc: rajjuOk
      ? `No Rajju dosha. Partner longevity is protected.`
      : `⚠️ Rajju dosha! Same Rajju (${b.rajju}) is traditionally considered a critical mismatch for husband's longevity.`,
  });

  // 10. Vedha Porutham (Critical)
  const isVedha = VEDHA_PAIRS.some(p=>(p[0]===bN&&p[1]===gN)||(p[0]===gN&&p[1]===bN));
  res.push({
    name:'Vedha Porutham', ta:'வேத பொருத்தம்', pts:isVedha?0:1, max:1, ok:!isVedha, critical:true,
    desc: !isVedha ? 'No Vedha dosha. Smooth married life.' : '⚠️ Vedha dosha present. Known to cause recurring obstacles.',
  });

  return res;
};

/* ── Match existing profiles ── */
const ALL_PROFILES = [
  { id:1,  gender:'female', name:'Kavitha Lakshmi',     age:26, star:'Rohini',           rasi:'Rishabam',  avatar:'👩', avatarBg:'linear-gradient(135deg,#f8c6c6,#ffd6e0)', caste:'Mudaliar',  profession:'Nurse',             location:'Chennai'   },
  { id:2,  gender:'female', name:'Deepa Sundaram',      age:28, star:'Bharani',           rasi:'Mesham',    avatar:'👩', avatarBg:'linear-gradient(135deg,#d4f1c8,#b8e6b0)', caste:'Brahmin',   profession:'Teacher',           location:'Coimbatore'},
  { id:3,  gender:'female', name:'Priya Venkatesh',     age:24, star:'Krithigai',         rasi:'Mesham',    avatar:'👩', avatarBg:'linear-gradient(135deg,#c8d4f8,#b8c8f0)', caste:'Gounder',   profession:'Software Engineer', location:'Bangalore' },
  { id:4,  gender:'female', name:'Anitha Rajan',        age:30, star:'Mirugaserisham',    rasi:'Midhunam',  avatar:'👩', avatarBg:'linear-gradient(135deg,#fde8c6,#fdd5a0)', caste:'Nadar',     profession:'Business Analyst',  location:'Madurai'   },
  { id:5,  gender:'female', name:'Santhiya Murugan',    age:25, star:'Rohini',            rasi:'Rishabam',  avatar:'👩', avatarBg:'linear-gradient(135deg,#ffe4f0,#ffd0e8)', caste:'Mudaliar',  profession:'Accountant',        location:'Chennai'   },
  { id:6,  gender:'male',   name:'Arun Kumar',          age:29, star:'Avittam',           rasi:'Makaram',   avatar:'👨', avatarBg:'linear-gradient(135deg,#c8e8f8,#b0d8f0)', caste:'Mudaliar',  profession:'Engineer',          location:'Chennai'   },
  { id:7,  gender:'male',   name:'Vijay Shankar',       age:31, star:'Hastham',           rasi:'Kanni',     avatar:'👨', avatarBg:'linear-gradient(135deg,#d8c8f8,#c8b8f0)', caste:'Brahmin',   profession:'Data Scientist',    location:'Hyderabad' },
  { id:8,  gender:'male',   name:'Karthik Raja',        age:27, star:'Rohini',            rasi:'Rishabam',  avatar:'👨', avatarBg:'linear-gradient(135deg,#d0f0d8,#b8e8c0)', caste:'Gounder',   profession:'Agri-Business',     location:'Erode'     },
];

/* ── Score label ── */
const getVerdict = (pct) => {
  if (pct >= 80) return { label:'Excellent Match', ta:'மிகவும் பொருத்தம்', color:'#16a34a', emoji:'💚', bg:'rgba(22,163,74,0.08)' };
  if (pct >= 60) return { label:'Good Match',      ta:'நல்ல பொருத்தம்',    color:'#2563eb', emoji:'💙', bg:'rgba(37,99,235,0.07)'  };
  if (pct >= 40) return { label:'Average Match',   ta:'சாதாரண பொருத்தம்', color:'#d97706', emoji:'🟡', bg:'rgba(217,119,6,0.08)'  };
  return              { label:'Poor Match',        ta:'பொருத்தமில்லை',     color:'#dc2626', emoji:'❤️', bg:'rgba(220,38,38,0.07)'  };
};

/* ════════════════════════════════════════════════════
   MAIN COMPONENT
════════════════════════════════════════════════════ */
const PoruthamChecker = () => {
  const printRef = useRef();
  const resultsRef = useRef(null);

  const [boyName, setBoyName] = useState('');
  const [boyDob,  setBoyDob]  = useState('');
  const [boyTob,  setBoyTob]  = useState('');
  const [boyMode, setBoyMode] = useState('auto'); // auto | manual
  const [boyStar, setBoyStar] = useState(0);
  
  const [girlName,setGirlName]= useState('');
  const [girlDob, setGirlDob] = useState('');
  const [girlTob, setGirlTob] = useState('');
  const [girlMode, setGirlMode] = useState('auto'); // auto | manual
  const [girlStar, setGirlStar] = useState(0);

  const [matches, setMatches] = useState([]);
  const [result, setResult] = useState(null);
  const [loading, setLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState('');

  const handleCheck = (e) => {
    e.preventDefault();
    setLoading(true);
    setTimeout(() => {
      let boyIdx, girlIdx;
      
      if (boyMode === 'auto') {
        boyIdx = getNakIdx(boyDob, boyTob); 
      } else {
        boyIdx = parseInt(boyStar);
      }

      if (girlMode === 'auto') {
        girlIdx = getNakIdx(girlDob, girlTob);
      } else {
        girlIdx = parseInt(girlStar);
      }

      if (boyIdx === null || girlIdx === null || isNaN(boyIdx) || isNaN(girlIdx)) { 
        setLoading(false); 
        setErrorMessage("Please ensure all details are selected.");
        return; 
      }

      const poruthams = calcPoruthams(boyIdx, girlIdx);
      const totalPts  = poruthams.reduce((s,p) => s + p.pts, 0);
      const maxPts    = poruthams.reduce((s,p) => s + p.max, 0);
      const pct       = Math.round((totalPts / maxPts) * 100);
      const okCount   = poruthams.filter(p => p.ok).length;
      const hasCriticalDosha = poruthams.filter(p => p.critical && !p.ok).length > 0;
      const verdict   = getVerdict(pct);

      setResult({
        boyName, boyDob,   boyNak: NAKSHATRAS[boyIdx],   boyRasi: RASIS[NAKSHATRAS[boyIdx].rasi],
        girlName, girlDob, girlNak: NAKSHATRAS[girlIdx], girlRasi: RASIS[NAKSHATRAS[girlIdx].rasi],
        poruthams, totalPts, maxPts, pct, okCount, hasCriticalDosha, verdict,
      });

      // Match profiles
      const boyStarId  = boyIdx + 1;
      const girlStarId = girlIdx + 1;
      const matched = ALL_PROFILES.filter(p => {
        const pStarId = STAR_NAME_MAP[p.star] || 0;
        if (!pStarId) return false;
        const pidx = pStarId - 1;
        const ports = calcPoruthams(boyIdx, pidx);
        const tpts  = ports.reduce((s,x)=>s+x.pts,0);
        const mpts  = ports.reduce((s,x)=>s+x.max,0);
        const score = Math.round((tpts/mpts)*100);
        p._score = score;
        return score >= 40;
      }).sort((a,b) => b._score - a._score).slice(0,4);
      setMatches(matched);
      setLoading(false);
      
      // Auto-scroll to results on mobile
      setTimeout(() => {
        resultsRef.current?.scrollIntoView({ behavior: 'smooth', block: 'start' });
      }, 100);
    }, 1200);
  };

  const handlePrint = () => {
    const content = printRef.current.innerHTML;
    const win = window.open('', '_blank');
    win.document.write(`
      <html><head><title>Thirumana Porutham Report — ${result.boyName} & ${result.girlName}</title>
      <style>
        body{font-family:Arial,sans-serif;padding:2rem;max-width:800px;margin:0 auto;color:#2d3748}
        h1{color:#1F8A70;text-align:center;margin-bottom:0.25rem}
        .sub{text-align:center;color:#718096;margin-bottom:2rem}
        table{width:100%;border-collapse:collapse;margin-bottom:2rem}
        th,td{border:1px solid #e2e8f0;padding:0.6rem 0.8rem;text-align:left}
        th{background:#f7fafc;font-weight:600}
        .ok{color:#16a34a;font-weight:700} .no{color:#dc2626;font-weight:700}
        .score-box{text-align:center;padding:1.5rem;border:2px solid #1F8A70;border-radius:12px;margin-bottom:2rem}
        .score-num{font-size:3rem;font-weight:800;color:#1F8A70}
        .verdict{font-size:1.2rem;font-weight:700;margin-top:0.5rem}
        .profiles-pair{display:flex;justify-content:center;gap:3rem;margin-bottom:2rem}
        .profile{text-align:center}
        .profile h3{margin:0}
        .profile p{margin:0;color:#718096;font-size:0.85rem}
        .dosha-warn{background:#fef2f2;border:1px solid #fecaca;border-radius:8px;padding:1rem;margin-bottom:1rem;color:#dc2626}
        @media print{button{display:none}}
      </style></head><body>${content}</body></html>
    `);
    win.document.close();
    win.print();
  };

  return (
    <div className="pc-page">
      {/* ── Hero ── */}
      <div className="pc-hero">
        <div className="container">
          <p className="section-subtitle" style={{color:'rgba(255,255,255,0.7)'}}>Free · Vedic · Authentic</p>
          <h1 className="pc-hero-title">🔮 Thirumana Porutham</h1>
          <p className="pc-hero-sub">திருமண பொருத்தம் — Tamil Marriage Compatibility Checker</p>
          <div className="pc-benefits">
            {['10 Poruthams Checked','Nakshatra & Rasi Analysis','Dosha Detection','Printable Report'].map(b=>(
              <span key={b} className="pc-benefit">✓ {b}</span>
            ))}
          </div>
        </div>
      </div>

      <div className="container pc-body">

        {/* ── Input Form ── */}
        <form className="pc-form" onSubmit={handleCheck}>
          <div className="pc-form-header">
            <h2>Enter Details</h2>
            <p>Fill in both names and dates of birth to get the compatibility report.</p>
          </div>

          <div className="pc-persons">
            {/* Boy */}
            <div className="pc-person boy-side">
              <div className="person-avatar">🤵</div>
              <h3>Boy (He) | மணமகன்</h3>
              <div className="form-field-pc">
                <label>Full Name</label>
                <input required placeholder="Enter boy's name" value={boyName} onChange={e=>setBoyName(e.target.value)} />
              </div>
              
              <div className="mode-toggle">
                <button type="button" className={boyMode === 'auto' ? 'active' : ''} onClick={() => setBoyMode('auto')}>Auto Calc</button>
                <button type="button" className={boyMode === 'manual' ? 'active' : ''} onClick={() => setBoyMode('manual')}>Know my Star</button>
              </div>

              <div className="form-row-pc">
                <div className="form-field-pc">
                  <label>Date of Birth</label>
                  <input required type="date" value={boyDob} onChange={e=>setBoyDob(e.target.value)} max={new Date().toISOString().split('T')[0]} />
                </div>
                <div className="form-field-pc">
                  <label>Time of Birth</label>
                  <input type="time" value={boyTob} onChange={e=>setBoyTob(e.target.value)} />
                </div>
              </div>

              {boyMode === 'auto' ? (
                boyDob && (
                  <div className="auto-nak">
                    <span>🌟</span>
                    <div>
                      <p className="nak-label">Approx. Star (Can be inaccurate)</p>
                      <p className="nak-val">{NAKSHATRAS[getNakIdx(boyDob)].en} · {NAKSHATRAS[getNakIdx(boyDob)].ta}</p>
                      <p className="nak-rasi">Approx. Rasi: {RASIS[NAKSHATRAS[getNakIdx(boyDob)].rasi].ta}</p>
                    </div>
                  </div>
                )
              ) : (
                <div className="form-field-pc" style={{marginTop: '1rem'}}>
                  <label>Select Your Nakshatra (Star)</label>
                  <select value={boyStar} onChange={e=>setBoyStar(e.target.value)}>
                    {NAKSHATRAS.map((n, i) => (
                      <option key={n.id} value={i}>{n.ta} ({n.en}) — {RASIS[n.rasi].ta}</option>
                    ))}
                  </select>
                </div>
              )}
            </div>

            <div className="pc-divider-center">
              <div className="pc-vs-ring">❤️</div>
              <div className="pc-connector-line"></div>
            </div>

            {/* Girl */}
            <div className="pc-person girl-side">
              <div className="person-avatar">👰</div>
              <h3>Girl (She) | மணமகள்</h3>
              <div className="form-field-pc">
                <label>Full Name</label>
                <input required placeholder="Enter girl's name" value={girlName} onChange={e=>setGirlName(e.target.value)} />
              </div>

              <div className="mode-toggle">
                <button type="button" className={girlMode === 'auto' ? 'active' : ''} onClick={() => setGirlMode('auto')}>Auto Calc</button>
                <button type="button" className={girlMode === 'manual' ? 'active' : ''} onClick={() => setGirlMode('manual')}>Know my Star</button>
              </div>

              <div className="form-row-pc">
                <div className="form-field-pc">
                  <label>Date of Birth</label>
                  <input required type="date" value={girlDob} onChange={e=>setGirlDob(e.target.value)} max={new Date().toISOString().split('T')[0]} />
                </div>
                <div className="form-field-pc">
                  <label>Time of Birth</label>
                  <input type="time" value={girlTob} onChange={e=>setGirlTob(e.target.value)} />
                </div>
              </div>

              {girlMode === 'auto' ? (
                girlDob && (
                  <div className="auto-nak">
                    <span>🌟</span>
                    <div>
                      <p className="nak-label">Approx. Star (Can be inaccurate)</p>
                      <p className="nak-val">{NAKSHATRAS[getNakIdx(girlDob)].en} · {NAKSHATRAS[getNakIdx(girlDob)].ta}</p>
                      <p className="nak-rasi">Approx. Rasi: {RASIS[NAKSHATRAS[getNakIdx(girlDob)].rasi].ta}</p>
                    </div>
                  </div>
                )
              ) : (
                <div className="form-field-pc" style={{marginTop: '1rem'}}>
                  <label>Select Your Nakshatra (Star)</label>
                  <select value={girlStar} onChange={e=>setGirlStar(e.target.value)}>
                    {NAKSHATRAS.map((n, i) => (
                      <option key={n.id} value={i}>{n.ta} ({n.en}) — {RASIS[n.rasi].ta}</option>
                    ))}
                  </select>
                </div>
              )}
            </div>
          </div>

          <button type="submit" className="pc-check-btn" disabled={loading}>
            {loading ? <span className="pc-spinner"></span> : '🔮'}
            {loading ? 'Calculating…' : 'Check Porutham | பொருத்தம் பார்'}
          </button>
        </form>

        {result && (
          <div className="pc-results" ref={resultsRef}>
            <div ref={printRef}>

            {/* Print Header (hidden on screen) */}
            <div className="print-only">
              <h1>🔮 Thirumana Porutham Report</h1>
              <p className="sub">Generated by Sri AadhiGuru Education · aadhiguru.in</p>
            </div>

            {/* Names Row */}
            <div className="pc-names-row profiles-pair">
              <div className="pc-name-card boy-card profile">
                <div className="nc-avatar">🤵</div>
                <h3>{result.boyName}</h3>
                <p>DOB: {new Date(result.boyDob).toLocaleDateString('ta-IN',{day:'numeric',month:'long',year:'numeric'})}</p>
                <p className="nc-star">⭐ {result.boyNak.ta} ({result.boyNak.en})</p>
                <p className="nc-rasi">🔮 {result.boyRasi.ta}</p>
                <p className="nc-gana">Gana: {result.boyNak.gana}</p>
              </div>

              {/* Score Orb */}
              <div className="pc-score-orb score-box">
                <ScoreRing score={result.pct} verdict={result.verdict} />
                <div className="score-meta">
                  <p className="score-out">{result.okCount}/10 Poruthams</p>
                  <div className="verdict-badge" style={{ background: result.verdict.bg, color: result.verdict.color }}>
                    {result.verdict.emoji} {result.verdict.label}
                  </div>
                  <p className="verdict-ta" style={{ color: result.verdict.color }}>{result.verdict.ta}</p>
                </div>
              </div>

              <div className="pc-name-card girl-card profile">
                <div className="nc-avatar">👰</div>
                <h3>{result.girlName}</h3>
                <p>DOB: {new Date(result.girlDob).toLocaleDateString('ta-IN',{day:'numeric',month:'long',year:'numeric'})}</p>
                <p className="nc-star">⭐ {result.girlNak.ta} ({result.girlNak.en})</p>
                <p className="nc-rasi">🔮 {result.girlRasi.ta}</p>
                <p className="nc-gana">Gana: {result.girlNak.gana}</p>
              </div>
            </div>

            {/* Critical Dosha Warning */}
            {result.hasCriticalDosha && (
              <div className="dosha-warn dosha-warning-banner">
                <span>⚠️</span>
                <div>
                  <strong>Critical Dosha Detected</strong>
                  <p>One or more critical doshas (Rajju / Vedha) were found. Please consult a qualified Jyotish astrologer before proceeding.</p>
                </div>
              </div>
            )}

            {/* 10 Poruthams Table */}
            <div className="pc-section">
              <h2 className="pc-section-title">📋 10 Poruthams Detailed Analysis</h2>
              <div className="pc-table-wrap">
                <table className="pc-table">
                  <thead>
                    <tr>
                      <th className="th-num">#</th>
                      <th className="th-name">Porutham Name</th>
                      <th className="th-ta">தமிழ் பெயர்</th>
                      <th className="th-pts">Points</th>
                      <th className="th-status">Status</th>
                      <th className="th-desc">Details</th>
                    </tr>
                  </thead>
                  <tbody>
                    {result.poruthams.map((p, i) => (
                      <tr key={i} className={`${p.ok ? 'row-ok' : 'row-no'} ${p.critical ? 'row-critical' : ''}`}>
                        <td className="td-num">{i+1}</td>
                        <td className="td-name">
                          {p.name}
                          {p.critical && <span className="crit-tag">Critical</span>}
                        </td>
                        <td className="td-ta">{p.ta}</td>
                        <td className="td-pts">{p.pts}/{p.max}</td>
                        <td className="td-status">
                          <span className={`status-badge ${p.ok ? 'status-ok' : 'status-no'}`}>
                            {p.ok ? '✓ OK' : '✗ No'}
                          </span>
                        </td>
                        <td className="td-desc">{p.desc}</td>
                      </tr>
                    ))}
                  </tbody>
                  <tfoot>
                    <tr className="table-total">
                      <td colSpan={2}><strong>Total Score</strong></td>
                      <td className="td-ta"></td>
                      <td className="td-pts"><strong>{result.totalPts}/{result.maxPts}</strong></td>
                      <td className="td-status"><strong>{result.pct}%</strong></td>
                      <td className="td-desc"><strong style={{color:result.verdict.color}}>{result.verdict.label}</strong></td>
                    </tr>
                  </tfoot>
                </table>
              </div>
            </div>

            {/* Overall Verdict card */}
            <div className="pc-verdict-card" style={{ borderColor: result.verdict.color, background: result.verdict.bg }}>
              <div className="verdict-icon">{result.verdict.emoji}</div>
              <div>
                <h3 style={{color:result.verdict.color}}>{result.verdict.label} — {result.pct}%</h3>
                <p className="verdict-ta" style={{color:result.verdict.color}}>{result.verdict.ta}</p>
                <p className="verdict-explain">
                  {result.okCount} out of 10 poruthams are matching.{' '}
                  {result.pct >= 60
                    ? 'This is a promising match. May proceed with parental and astrological blessings.'
                    : 'This match needs careful consideration. Please consult a Jyotish astrologer.'}
                  {result.hasCriticalDosha && ' Critical doshas require remedies.'}
                </p>
              </div>
            </div>

            {/* Print & Share actions */}
            <div className="pc-actions no-print">
              <button className="pc-print-btn" onClick={handlePrint}>🖨️ Print / Save as PDF</button>
              <button className="pc-new-btn" onClick={()=>{setResult(null);setMatches([]);}}>🔄 New Check</button>
            </div>

            {/* Profile Matches from database */}
            {matches.length > 0 && (
              <div className="pc-section no-print">
                <h2 className="pc-section-title">💍 Compatible Profiles in Our Database</h2>
                <p className="pc-section-sub">Based on compatibility with {result.boyName}'s star, here are matching profiles:</p>
                <div className="pc-matches-grid">
                  {matches.map(m => (
                    <div key={m.id} className="pc-match-card">
                      <div className="pmc-avatar" style={{background:m.avatarBg}}>{m.avatar}</div>
                      <div className="pmc-info">
                        <h4>{m.name}</h4>
                        <p>{m.age} yrs · {m.profession}</p>
                        <p className="pmc-location">📍 {m.location}</p>
                        <p className="pmc-star">⭐ {m.star} · {m.rasi}</p>
                      </div>
                      <div className="pmc-score" style={{color: m._score>=70?'#16a34a':m._score>=50?'#2563eb':'#d97706'}}>
                        <span className="pmc-pct">{m._score}%</span>
                        <span className="pmc-lbl">match</span>
                      </div>
                    </div>
                  ))}
                </div>
                <div style={{textAlign:'center',marginTop:'1.5rem'}}>
                  <a href="/matrimony" className="btn btn-primary" style={{display:'inline-flex',alignItems:'center',gap:'0.5rem',textDecoration:'none'}}>
                    💍 View All Profiles in Matrimony
                  </a>
                </div>
              </div>
            )}
            </div>
          </div>
        )}
      </div>

      {errorMessage && (
        <div className="error-toast fade-in" style={{zIndex: 10000, position:'fixed', bottom:'2rem', left:'50%', transform:'translateX(-50%)', background:'#dc2626', color:'white', padding:'1rem 1.5rem', borderRadius:'12px', boxShadow:'0 10px 25px rgba(220,38,38,0.3)', display:'flex', alignItems:'center', gap:'1rem', minWidth:'300px', justifyContent:'space-between'}}>
          <span>⚠️ {errorMessage}</span>
          <button onClick={() => setErrorMessage('')} style={{background:'none', border:'none', color:'white', fontSize:'1.2rem', cursor:'pointer', marginLeft:'1rem'}}>✕</button>
        </div>
      )}
    </div>
  );
};

/* ── Score Ring SVG ── */
const ScoreRing = ({ score, verdict }) => {
  const r = 52, circ = 2*Math.PI*r;
  const dash = (score/100)*circ;
  return (
    <div className="score-ring-wrap">
      <svg width="130" height="130" viewBox="0 0 130 130">
        <circle cx="65" cy="65" r={r} fill="none" stroke="#e2e8f0" strokeWidth={8} />
        <circle cx="65" cy="65" r={r} fill="none" stroke={verdict.color} strokeWidth={8}
          strokeDasharray={`${dash} ${circ}`} strokeDashoffset={circ*0.25} strokeLinecap="round"
          style={{transition:'stroke-dasharray 1s ease'}} />
      </svg>
      <div className="score-ring-inner">
        <span className="score-ring-num" style={{color:verdict.color}}>{score}</span>
        <span className="score-ring-pct" style={{color:verdict.color}}>%</span>
      </div>
    </div>
  );
};

export default PoruthamChecker;
