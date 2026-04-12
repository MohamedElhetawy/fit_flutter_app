# FitX — Authentication Flow

**Version:** 1.0.0

---

## 1. Flow 1: Phone Number Registration (OTP)

```
Mobile App                    API Server                  Firebase / SMS Provider
    │                              │                              │
    │── Enter Phone Number ────────►│                              │
    │                              │── Validate format            │
    │                              │── Rate limit check           │
    │                              │── Generate 6-digit OTP       │
    │                              │── Store SHA256(OTP) in Redis (TTL: 5min)
    │                              │                              │
    │                              │── Send OTP via SMS ─────────►│
    │                              │                              │── Deliver SMS
    │◄── "OTP Sent" response ──────│                              │
    │                              │                              │
    │── Enter 6-digit OTP ─────────►│                              │
    │                              │── Hash input OTP             │
    │                              │── Compare with Redis hash    │
    │                              │── Check not expired          │
    │                              │── Invalidate OTP (single-use)│
    │                              │                              │
    │                              │── Create user record         │
    │                              │── Generate JWT (RS256)       │
    │                              │── Generate Refresh Token     │
    │                              │── Store RefreshToken hash    │
    │                              │                              │
    │◄── access_token +            │                              │
    │    refresh_token ────────────│                              │
    │                              │                              │
    │── Store tokens securely      │                              │
    │   (Keychain / Keystore)      │                              │
```

---

## 2. Flow 2: Google OAuth Login

```
Mobile App                    API Server              Google OAuth
    │                              │                       │
    │── Tap "Login with Google" ───►│                       │
    │                              │                       │
    │◄── Google Sign-In UI ────────────────────────────────│
    │── User authenticates ────────────────────────────────►│
    │◄── Google ID Token ──────────────────────────────────│
    │                              │                       │
    │── POST /auth/google ─────────►│                       │
    │   { id_token: "..." }        │                       │
    │                              │── Verify token ───────►│
    │                              │◄── Token valid (email, │
    │                              │    google_id, name)   │
    │                              │                       │
    │                              │── Find or create user │
    │                              │── Generate JWT        │
    │                              │── Generate Refresh    │
    │                              │                       │
    │◄── access_token +            │                       │
    │    refresh_token ────────────│                       │
```

---

## 3. Flow 3: Biometric Login (Returning User)

```
Mobile App                    API Server              Device Biometrics
    │                              │                       │
    │── App Open (warm start) ─────►│                       │
    │── Check: Biometric enabled?  │                       │
    │── Prompt biometric ──────────────────────────────────►│
    │◄── Biometric confirmed ──────────────────────────────│
    │                              │                       │
    │── Retrieve stored            │                       │
    │   refresh_token from         │                       │
    │   Keychain/Keystore          │                       │
    │                              │                       │
    │── POST /auth/refresh ────────►│                       │
    │   { refresh_token: "..." }   │                       │
    │                              │── Validate token hash │
    │                              │── Check not expired   │
    │                              │── Rotate token        │
    │                              │── Issue new JWT       │
    │                              │                       │
    │◄── new access_token +        │                       │
    │    new refresh_token ────────│                       │
    │── Store new refresh token    │                       │
```

---

## 4. Flow 4: Authenticated API Request

```
Mobile App                    API Gateway              Core API
    │                              │                       │
    │── GET /workouts/plan ────────►│                       │
    │   Authorization: Bearer {JWT}│                       │
    │                              │── Extract JWT         │
    │                              │── Verify RS256 signature
    │                              │── Check exp not past  │
    │                              │── Check jti not       │
    │                              │   blacklisted         │
    │                              │── Extract user_id,    │
    │                              │   role, tier          │
    │                              │── Forward request ────►│
    │                              │   + X-User-ID header  │
    │                              │                       │── RBAC check
    │                              │                       │── DB query
    │                              │◄── Response ──────────│
    │◄── Response ─────────────────│                       │
```

---

## 5. Flow 5: Token Refresh

```
Mobile App                    API Server
    │                              │
    │── API call fails with 401 ◄──│
    │                              │
    │── Check: is refresh_token    │
    │   available and not expired? │
    │                              │
    │── POST /auth/refresh ────────►│
    │   { refresh_token: "..." }   │── Hash input token
    │                              │── Find in DB
    │                              │── Check: not expired
    │                              │── Check: not already used
    │                              │── Invalidate old token
    │                              │── Issue new access_token
    │                              │── Issue new refresh_token (rotation)
    │◄── new tokens ───────────────│
    │                              │
    │── Retry original request ────►│
    │   with new access_token      │
```

If refresh token is also expired:

```
    │── Redirect to Login screen   │
    │   (clear all stored tokens)  │
```

---

## 6. Flow 6: Logout

```
Mobile App                    API Server
    │                              │
    │── POST /auth/logout ─────────►│
    │   Authorization: Bearer {JWT}│
    │                              │── Add jti to JWT blacklist (Redis, TTL = remaining JWT lifetime)
    │                              │── Invalidate refresh token in DB
    │                              │── (Optional: send logout event for analytics)
    │◄── 200 OK ───────────────────│
    │                              │
    │── Clear Keychain/Keystore    │
    │── Clear Redux state          │
    │── Navigate to Welcome screen │
```

---

## 7. Flow 7: Admin Login (2FA Required)

```
Admin Browser                 API Server              TOTP App
    │                              │                       │
    │── POST /auth/admin/login ────►│                       │
    │   { email, password }        │── Verify credentials  │
    │                              │── Account has 2FA?    │
    │                              │── Yes                 │
    │◄── { requires_2fa: true,     │                       │
    │      challenge_token }───────│                       │
    │                              │                       │
    │── Enter TOTP code ──────────►│                       │
    │   { challenge_token, totp }  │── Verify TOTP ────────►│
    │                              │◄── Valid ─────────────│
    │                              │── Generate admin JWT  │
    │                              │   (short-lived: 8h)   │
    │◄── admin_access_token ───────│                       │
```

---

## 8. Token Storage Strategy (Mobile)

| Token | Storage | Encryption | Access |
|-------|---------|-----------|--------|
| Access Token | In-memory (React state) | None needed (ephemeral) | Cleared on app kill |
| Refresh Token | iOS Keychain / Android Keystore | Hardware-backed encryption | Requires biometric or PIN |
| Device ID | Secure storage | AES via Keystore | Background accessible |

**Never store tokens in:**

- AsyncStorage (unencrypted)
- localStorage / sessionStorage
- Shared preferences (Android, unencrypted)

---

## 9. Partner Dashboard Auth

```
Partners authenticate via:
1. Email + Password (hashed with bcrypt, cost factor 12)
2. Magic Link (email-based, valid 10 minutes)

Sessions: HTTP-only, SameSite=Strict cookie
Duration: 8 hours idle timeout; 30-day absolute timeout
2FA: Optional for partners; mandatory for partner accounts managing >1000 EGP/month in transactions
```
