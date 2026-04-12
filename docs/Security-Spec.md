# FitX — Security & Privacy Specification
**Version:** 1.0.0  
**Status:** Approved for MVP  
**Philosophy:** Zero-Trust Architecture with Maximum User Privacy (On-Device Preferred)

---

## 1. Core Security Principles

### 1.1 "البرمجة الذكية الموفرة" (On-Device Processing First)
- **AI Camera Tracking:** All pose estimation (33 key points) and workout analysis happen **strictly on-device** using local ML models. Video feeds and photos of the user *never* leave the device. This ensures absolute privacy for users (especially women working out at home) and reduces cloud compute costs to zero.
- **Food Recognition:** The initial model runs locally for fast food detection. If a fallback to the cloud is needed, only compressed cropped frames are sent, and they are immediately discarded after inference.
- **Biometric Processing:** Smartwatch metrics (heart rate, HRV) are analyzed locally bridging Apple Health/Google Fit APIs to trigger adaptive workouts ("التدريب التكيفي الحنين") locally.

### 1.2 Data Minimization & Privacy
- **No Real Names Required:** Users can use nicknames.
- **Location Data:** Only used ephemerally to fetch local merchants or "Gym Mayor" status. Precise locations are bounded by geofences; the server only stores aggregate check-ins, not continuous GPS tracking logs.

---

## 2. Authentication & Authorization Structure

### 2.1 User Roles (Role-Based Access Control)
1. **Free User (البطل المبتدئ):** Standard JWT. Tightly rate-limited against cloud services (e.g., maximum 3 "Fridge Rescue" API calls per day).
2. **Pro User (البطل المحترف):** Elevated JWT with `pro: true`. Unlocks premium local models and unlimited API access for advanced routines.
3. **Partner/Merchant (الشريك المحلي):** Scoped access tokens. Restricted to their specific commercial dashboard (cannot access fitness/diet areas).
4. **Super Admin (المايسترو):** Mandatory Multi-Factor Authentication (MFA). Allowed to suspend merchants and adjust global parameters.

### 2.2 Auth Mechanisms
- **Primary Registration:** Phone Number + OTP. Essential for the Egyptian market to prevent fraud and multi-accounting.
- **Social Login:** Google & Apple Sign-In (optional, but encouraged for seamless entry).
- **Session Lifecycle:** 
  - Access Tokens: 15-minute expiry.
  - Refresh Tokens: HttpOnly, Secure cookies or Secure Storage (Mobile), 30-day rolling expiry.

---

## 3. Threat Mitigation & Anti-Fraud Algorithms

### 3.1 "عمدة الجيم" & Map Challenge Fraud (GPS Spoofing)
- **Risk:** Users mocking their GPS location to win "Gym Mayor" titles or fake walking steps to win challenges.
- **Mitigation:** 
  1. Deny access if OS-level `isMockLocationEnabled` flags are active.
  2. Cross-reference GPS check-ins with device pedometer/accelerometer data (you cannot travel 10km in 2 minutes, and you cannot check into a gym without physical motion data).

### 3.2 Merchant Trust & Fake Reviews ("دليل الجزار الذكي")
- **Risk:** Competitors leaving bad reviews, or a merchant manipulating their own 5-star rating.
- **Mitigation:** "Verified Transactions Only." A user can *only* rate a merchant if the system registered a verified physical QR code scan at that location within the last 24 hours. If a merchant's rating drops below 4.0, or they receive a "fraud" report, an automatic temporary hold is placed on their visibility pending Admin review.

### 3.3 Discount Code Abuse
- **Risk:** Taking a screenshot of a QR discount code and sharing it on WhatsApp.
- **Mitigation:** Time-based One-Time Passwords (TOTP) style QR codes. Promos generate a dynamic QR code that refreshes every 30 seconds. The merchant app validates against the active timestamp.

---

## 4. Payment & Financial Security

### 4.1 Payment Gateways (Fawry, Paymob, Instapay)
- **Zero PCI Scope:** FitX servers **never** touch or store credit card numbers. All transactions happen via secure iframes/redirects to our payment partners.
- **Webhook Security:** All webhook callbacks from Fawry/Paymob must be cryptographically verified using `HMAC-SHA256` signatures to ensure subscription activations are legitimate and not spoofed POST requests.

---

## 5. Infrastructure & API Hardening

### 5.1 Defense in Depth
- **WAF (Web Application Firewall):** Shield against SQLi, XSS, and bots.
- **Rate Limiting:** Protect the AI diet generator from being scraped. Limit IP/Device to 5 RPM (Requests Per Minute) for AI endpoints.
- **TLS 1.3 Strict:** Enforced across all mobile-to-API communication. Certificate Pinning implemented in the mobile app to prevent Man-in-the-Middle (MitM) attacks on public Egyptian Wi-Fi networks.
- **Secret Management:** Hardcoded API keys in the app or backend are strictly forbidden. Use Doppler (as specified in `CI-CD.md`) for backend injection.

### 5.2 Dependency Auditing
- Automated `npm audit` and `semgrep` security scanning on every GitHub Pull Request to catch vulnerable libraries before they reach production.
