import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { supabase } from '../supabaseClient';
import { sanitize } from '../utils/security';
import SuccessModal from '../components/SuccessModal';
import './CreateProfile.css';

const CreateProfile = () => {
  const navigate = useNavigate();
  const [step, setStep] = useState(1);
  const [loading, setLoading] = useState(false);
  const [showSuccess, setShowSuccess] = useState(false);
  const [errorMessage, setErrorMessage] = useState('');
  const [formData, setFormData] = useState({
    profileFor: 'Myself',
    name: '',
    gender: 'male',
    dob: '',
    maritalStatus: 'First Marriage',
    noOfChildren: '',
    childrenLivingStatus: '',
    religion: 'Hindu',
    caste: '',
    subCaste: '',
    motherTongue: 'Tamil',
    star: '',
    rasi: '',
    gothram: '',
    education: '',
    profession: '',
    income: '',
    country: 'India',
    state: 'Tamil Nadu',
    city: '',
    familyType: 'Nuclear',
    familyStatus: 'Middle Class',
    fatherOcc: '',
    motherOcc: '',
    about: ''
  });

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const nextStep = () => {
    setStep(prev => Math.min(prev + 1, 4));
    window.scrollTo(0, 0);
  };

  const prevStep = () => {
    setStep(prev => Math.max(prev - 1, 1));
    window.scrollTo(0, 0);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);

    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) throw new Error("You must be logged in to create a profile.");
      
      // Sanitize all inputs
      const cleanData = {
        name: sanitize(formData.name),
        caste: sanitize(formData.caste),
        sub_caste: sanitize(formData.subCaste),
        star: sanitize(formData.star),
        rasi: sanitize(formData.rasi),
        education: sanitize(formData.education),
        profession: sanitize(formData.profession),
        location: sanitize(formData.city),
        father_occ: sanitize(formData.fatherOcc),
        mother_occ: sanitize(formData.motherOcc),
        preview: sanitize(formData.about)
      };

      const { error } = await supabase
        .from('matrimony_profiles')
        .insert([{
          user_id: user.id,
          gender: formData.gender,
          name: cleanData.name,
          age: parseInt(formData.dob ? (new Date().getFullYear() - new Date(formData.dob).getFullYear()) : 25),
          religion: formData.religion,
          caste: cleanData.caste,
          sub_caste: cleanData.sub_caste,
          star: cleanData.star,
          rasi: cleanData.rasi,
          height: formData.height || "5'5\"",
          education: cleanData.education,
          profession: cleanData.profession,
          location: cleanData.location,
          income: formData.income,
          complexion: formData.complexion || 'Wheatish',
          diet: formData.diet || 'Vegetarian',
          mother_tongue: formData.motherTongue,
          father_occ: cleanData.father_occ,
          mother_occ: cleanData.mother_occ,
          marital_status: formData.maritalStatus,
          preview: cleanData.preview
        }]);

      if (error) throw error;

      setShowSuccess(true);
    } catch (error) {
      console.error('Error creating profile:', error);
      setErrorMessage(error.message);
    } finally {
      setLoading(false);
    }
  };


  return (
    <div className="cp-page">
      <div className="cp-header">
        <div className="container">
          <h1>Create Your Matrimony Profile</h1>
          <p>Join millions of Tamils globally finding their perfect life partner</p>
        </div>
      </div>

      <div className="container cp-container">
        <div className="cp-stepper">
          {['Basic Details', 'Religious Info', 'Professional Info', 'Family Info'].map((label, idx) => (
            <div key={label} className={`cp-step ${step >= idx + 1 ? 'active' : ''} ${step > idx + 1 ? 'completed' : ''}`}>
              <div className="step-circle">{step > idx + 1 ? '✓' : idx + 1}</div>
              <span className="step-label">{label}</span>
              {idx < 3 && <div className="step-line"></div>}
            </div>
          ))}
        </div>

        <div className="cp-form-card">
          <form onSubmit={step === 4 ? handleSubmit : (e) => { e.preventDefault(); nextStep(); }}>
            
            {step === 1 && (
              <div className="cp-section">
                <h2>Basic Details</h2>
                <div className="form-grid">
                  <div className="form-group">
                    <label>Profile Created For</label>
                    <select name="profileFor" value={formData.profileFor} onChange={handleChange}>
                      <option>Myself</option>
                      <option>Son</option>
                      <option>Daughter</option>
                      <option>Brother</option>
                      <option>Sister</option>
                      <option>Relative/Friend</option>
                    </select>
                  </div>
                  <div className="form-group">
                    <label>Full Name</label>
                    <input type="text" name="name" required placeholder="Enter full name" value={formData.name} onChange={handleChange} />
                  </div>
                  <div className="form-group">
                    <label>Gender</label>
                    <div className="gender-toggle">
                      <label className={`g-btn ${formData.gender === 'male' ? 'active' : ''}`}>
                        <input type="radio" name="gender" value="male" checked={formData.gender === 'male'} onChange={handleChange} /> 🤵 Male
                      </label>
                      <label className={`g-btn ${formData.gender === 'female' ? 'active' : ''}`}>
                        <input type="radio" name="gender" value="female" checked={formData.gender === 'female'} onChange={handleChange} /> 👰 Female
                      </label>
                    </div>
                  </div>
                  <div className="form-group">
                    <label>Date of Birth</label>
                    <input type="date" name="dob" required value={formData.dob} onChange={handleChange} />
                  </div>
                  <div className="form-group">
                    <label>Marital Status | திருமண நிலை</label>
                    <div className="marital-pills">
                      {[
                        { val: 'First Marriage',   icon: '💍', label: 'First Marriage' },
                        { val: 'Second Marriage',  icon: '🔄', label: 'Second Marriage' },
                        { val: 'Divorced',         icon: '📋', label: 'Divorced' },
                        { val: 'Widow',            icon: '🕊️', label: 'Widow' },
                        { val: 'Widower',          icon: '🕊️', label: 'Widower' },
                        { val: 'Awaiting Divorce', icon: '⏳', label: 'Awaiting Divorce' },
                        { val: 'Others',           icon: '📝', label: 'Others' },
                      ].map(({ val, icon, label }) => (
                        <label
                          key={val}
                          className={`marital-pill ${formData.maritalStatus === val ? 'marital-pill-active' : ''}`}
                        >
                          <input
                            type="radio"
                            name="maritalStatus"
                            value={val}
                            checked={formData.maritalStatus === val}
                            onChange={handleChange}
                          />
                          {icon} {label}
                        </label>
                      ))}
                    </div>
                  </div>
                  {/* Conditional: children info for non-first-marriage */}
                  {formData.maritalStatus !== 'First Marriage' && (
                    <>
                      <div className="form-group">
                        <label>No. of Children</label>
                        <select name="noOfChildren" value={formData.noOfChildren} onChange={handleChange}>
                          <option value="">Select</option>
                          <option>No Children</option>
                          <option>1 Child</option>
                          <option>2 Children</option>
                          <option>3 or more</option>
                        </select>
                      </div>
                      {formData.noOfChildren && formData.noOfChildren !== 'No Children' && (
                        <div className="form-group">
                          <label>Children Living With</label>
                          <select name="childrenLivingStatus" value={formData.childrenLivingStatus} onChange={handleChange}>
                            <option value="">Select</option>
                            <option>Living with me</option>
                            <option>Living with ex-spouse</option>
                            <option>Independently</option>
                          </select>
                        </div>
                      )}
                    </>
                  )}
                  <div className="form-group">
                    <label>Mother Tongue</label>
                    <select name="motherTongue" value={formData.motherTongue} onChange={handleChange} required>
                      <option value="">Select Language</option>
                      <option>Tamil</option>
                      <option>Telugu</option>
                      <option>Malayalam</option>
                      <option>Kannada</option>
                      <option>English</option>
                    </select>
                  </div>
                </div>
              </div>
            )}

            {step === 2 && (
              <div className="cp-section">
                <h2>Religious Information</h2>
                <div className="form-grid">
                  <div className="form-group">
                    <label>Religion</label>
                    <select name="religion" value={formData.religion} onChange={handleChange} required>
                      <option value="">Select Religion</option>
                      <option>Hindu</option>
                      <option>Christian</option>
                      <option>Muslim</option>
                      <option>Sikh</option>
                      <option>Jain</option>
                    </select>
                  </div>
                  <div className="form-group">
                    <label>Caste</label>
                    <input type="text" name="caste" placeholder="e.g. Mudaliar, Brahmin" value={formData.caste} onChange={handleChange} required />
                  </div>
                  <div className="form-group">
                    <label>Sub-Caste</label>
                    <input type="text" name="subCaste" placeholder="e.g. Saiva Pillai (Optional)" value={formData.subCaste} onChange={handleChange} />
                  </div>
                  <div className="form-group">
                    <label>Star / Nakshatra</label>
                    <input type="text" name="star" placeholder="e.g. Rohini" value={formData.star} onChange={handleChange} required />
                  </div>
                  <div className="form-group">
                    <label>Rasi / Moon Sign</label>
                    <input type="text" name="rasi" placeholder="e.g. Rishabam" value={formData.rasi} onChange={handleChange} required />
                  </div>
                  <div className="form-group">
                    <label>Gothram</label>
                    <input type="text" name="gothram" placeholder="Optional" value={formData.gothram} onChange={handleChange} />
                  </div>
                </div>
              </div>
            )}

            {step === 3 && (
              <div className="cp-section">
                <h2>Professional & Location Info</h2>
                <div className="form-grid">
                  <div className="form-group">
                    <label>Education</label>
                    <input type="text" name="education" required placeholder="e.g. B.E Computer Science" value={formData.education} onChange={handleChange} />
                  </div>
                  <div className="form-group">
                    <label>Profession / Occupation</label>
                    <input type="text" name="profession" required placeholder="e.g. Software Engineer" value={formData.profession} onChange={handleChange} />
                  </div>
                  <div className="form-group">
                    <label>Annual Income</label>
                    <select name="income" value={formData.income} onChange={handleChange} required>
                      <option value="">Select Income</option>
                      <option>Less than 3 LPA</option>
                      <option>3 - 6 LPA</option>
                      <option>6 - 10 LPA</option>
                      <option>10 - 15 LPA</option>
                      <option>15+ LPA</option>
                    </select>
                  </div>
                  <div className="form-group">
                    <label>Country Residing in</label>
                    <input type="text" name="country" value={formData.country} onChange={handleChange} required />
                  </div>
                  <div className="form-group">
                    <label>State</label>
                    <input type="text" name="state" value={formData.state} onChange={handleChange} required />
                  </div>
                  <div className="form-group">
                    <label>City</label>
                    <select name="city" value={formData.city} onChange={handleChange} required>
                      <option value="">Select City</option>
                      <option>Chennai</option>
                      <option>Coimbatore</option>
                      <option>Madurai</option>
                      <option>Tiruchirappalli</option>
                      <option>Salem</option>
                      <option>Tirunelveli</option>
                      <option>Erode</option>
                      <option>Vellore</option>
                      <option>Thoothukudi</option>
                      <option>Tiruppur</option>
                      <option>Kanchipuram</option>
                      <option>Thanjavur</option>
                      <option>Dindigul</option>
                      <option>Cuddalore</option>
                      <option>Nagercoil</option>
                      <option>Bangalore</option>
                      <option>Hyderabad</option>
                      <option>Pondicherry</option>
                      <option>Mumbai</option>
                      <option>Delhi</option>
                      <option>Other</option>
                    </select>
                  </div>
                </div>
              </div>
            )}

            {step === 4 && (
              <div className="cp-section">
                <h2>Family Details & About</h2>
                <div className="form-grid">
                  <div className="form-group">
                    <label>Family Type</label>
                    <select name="familyType" value={formData.familyType} onChange={handleChange} required>
                      <option>Nuclear Family</option>
                      <option>Joint Family</option>
                    </select>
                  </div>
                  <div className="form-group">
                    <label>Family Status</label>
                    <select name="familyStatus" value={formData.familyStatus} onChange={handleChange} required>
                      <option>Middle Class</option>
                      <option>Upper Middle Class</option>
                      <option>Rich / Affluent</option>
                    </select>
                  </div>
                  <div className="form-group">
                    <label>Father's Occupation</label>
                    <input type="text" name="fatherOcc" placeholder="e.g. Business, Retired" value={formData.fatherOcc} onChange={handleChange} required />
                  </div>
                  <div className="form-group">
                    <label>Mother's Occupation</label>
                    <input type="text" name="motherOcc" placeholder="e.g. Homemaker" value={formData.motherOcc} onChange={handleChange} required />
                  </div>
                  <div className="form-group f-full">
                    <label>About Yourself</label>
                    <textarea name="about" rows="4" required placeholder="Write a few lines about your personality, hobbies, and partner expectations..." value={formData.about} onChange={handleChange}></textarea>
                  </div>
                </div>
              </div>
            )}

            <div className="cp-actions">
              {step > 1 && (
                <button type="button" className="btn-prev" onClick={prevStep}>← Back</button>
              )}
              {step < 4 ? (
                <button type="submit" className="btn-next">Next Step →</button>
              ) : (
                <button type="submit" className="btn-submit" disabled={loading}>
                  {loading ? 'Creating...' : '✅ Create Profile'}
                </button>
              )}
            </div>
            
          </form>
        </div>
      </div>

      <SuccessModal 
        isOpen={showSuccess} 
        onClose={() => navigate('/matrimony?created=true')}
        title="Profile Created!"
        message="Profile Created Successfully! Finding your perfect matches..."
        actionText="View Matches"
      />

      {errorMessage && (
        <div className="error-toast fade-in">
          <span>⚠️ {errorMessage}</span>
          <button onClick={() => setErrorMessage('')}>✕</button>
        </div>
      )}
    </div>
  );
};

export default CreateProfile;
