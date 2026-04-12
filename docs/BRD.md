# FitX — Business Requirements Document (BRD)
**Version:** 1.0.0  
**Status:** Draft  
**Prepared For:** FitX Stakeholders  
**Prepared By:** FitX Product & Business Team

---

## 1. Business Purpose

FitX exists to democratize fitness and healthy living for Egyptian youth by making professional-grade coaching affordable, culturally relevant, and deeply integrated with the local economy. 

The core business thesis: *Build a fitness super-app that makes money from the ecosystem around the user's health journey — subscriptions, merchant commissions, and targeted local advertising — not just from the user themselves.*

---

## 2. Business Objectives

### Short-Term (0–12 Months)
1. Acquire 200,000 registered users within 12 months of launch.
2. Build a paying merchant partner network of 500+ local businesses.
3. Generate first revenue stream via Pro subscriptions by Month 7.
4. Achieve break-even on operating costs by Month 14.

### Medium-Term (12–24 Months)
1. Become Egypt's #1 fitness app by MAU.
2. Launch gym white-label B2B product.
3. Raise a Seed round using traction metrics.
4. Expand to Saudi Arabia and UAE.

### Long-Term (24–48 Months)
1. Become the primary fitness data platform for MENA.
2. Launch FitX Health Insurance tie-in (fitness-linked insurance discounts).
3. IPO or strategic acquisition readiness.

---

## 3. Business Context

### Market Analysis

**Total Addressable Market (TAM):**
- Egypt has 105M population; ~35M are aged 15–40.
- Digital health market in Egypt projected at $1.2B by 2027.
- Gym market in Egypt growing at 12% YoY.

**Serviceable Addressable Market (SAM):**
- Smartphone users aged 18–35 interested in fitness: ~8M.

**Serviceable Obtainable Market (SOM):**
- Realistic 12-month target: 200,000 active users (2.5% of SAM).

### Competitive Landscape

| Competitor | Strengths | Weaknesses vs FitX |
|------------|-----------|-------------------|
| MyFitnessPal | Large food DB, established | USD pricing, no local foods, no Arabic |
| Nike Training Club | Brand trust, video quality | No localization, no merchant network |
| Local Egyptian apps | Arabic UI | Poor AI, no merchant integration, weak design |
| WhatsApp trainer groups | Free, familiar | No structure, no tracking, no accountability |

**FitX Differentiation:**
- 100% Egyptian food database (local dishes + market prices)
- Local merchant partnership network with real-time offers
- AI coaching at sub-$1/month price point
- Community-first design with Arabic-native UX
- Offline-first architecture (no data plan dependency for core features)

---

## 4. Revenue Model

### Revenue Streams

#### Stream 1: Pro Subscriptions
- Monthly Plan: 39 EGP/month
- Quarterly Plan: 99 EGP/3 months
- Annual Plan: 299 EGP/year
- **Target:** 10% conversion of free base → ~20,000 Pro users by Month 12
- **Projected ARR:** ~6M EGP at scale

#### Stream 2: Merchant Commission
- 10–15% commission on purchases made via FitX referral links
- Applies to: meat orders, supplement purchases, gym memberships
- **Target:** 500 merchants × avg. 50 transactions/month × 150 EGP avg. × 12% = ~4.5M EGP/year

#### Stream 3: Targeted In-App Advertising
- Free-tier users see geo-targeted ads from local gyms, restaurants, supplement brands
- CPM-based model: 50 EGP per 1,000 impressions to local businesses
- **Target:** 150,000 free users × 20 ad impressions/month = 3M impressions/month → ~150,000 EGP/month

#### Stream 4: B2B Licensing (Year 2+)
- White-label FitX for gyms: 2,000 EGP/month/gym
- Target 50 gyms by Month 24 → 100,000 EGP/month

### Revenue Projection

| Month | Subscriptions | Commissions | Ads | Total |
|-------|--------------|-------------|-----|-------|
| 7 | 20,000 EGP | 0 | 0 | 20,000 EGP |
| 12 | 200,000 EGP | 80,000 EGP | 60,000 EGP | 340,000 EGP |
| 18 | 500,000 EGP | 300,000 EGP | 150,000 EGP | 950,000 EGP |
| 24 | 900,000 EGP | 600,000 EGP | 250,000 EGP | 1,750,000 EGP |

---

## 5. Cost Structure

### Fixed Costs (Monthly)
| Item | Cost |
|------|------|
| Cloud Infrastructure (Firebase/Supabase) | 2,000–5,000 EGP |
| App Store Developer Accounts | ~500 EGP (annual amortized) |
| Domain + SSL + CDN | ~200 EGP |
| Team Salaries (2 engineers, 1 designer) | 30,000–50,000 EGP |

### Variable Costs
| Item | Cost |
|------|------|
| AI API Calls (Pro users only) | ~5 EGP per Pro user/month |
| Payment Processing Fees | 2.5% of transactions |
| Marketing (performance + content) | 5,000–15,000 EGP/month |

### Unit Economics (Target)
- Customer Acquisition Cost (CAC): 15–25 EGP
- Lifetime Value — Free User: 8 EGP (ad revenue)
- Lifetime Value — Pro User: 400 EGP (12-month avg)
- LTV:CAC Ratio (Pro): ~16:1 ✅

---

## 6. Stakeholder Map

| Stakeholder | Role | Interest | Influence |
|-------------|------|----------|-----------|
| Mohammed (Founder) | Product + Tech Lead | High | High |
| Seif (Co-founder) | Operations + Growth | High | High |
| Pro Users | Core revenue source | Medium | High |
| Free Users | Acquisition funnel + ad revenue | Low | Medium |
| Merchant Partners | Commission revenue source | Medium | Medium |
| Investors (future) | ROI + equity value | High | High |
| App Stores (Google/Apple) | Distribution gatekeepers | Low | High |

---

## 7. Business Rules

1. **Price Lock:** Pro subscription pricing will not increase for the first 12 months post-launch.
2. **Merchant Quality Gate:** Any merchant rated below 4.0 stars (average of 20+ ratings) is automatically suspended and users are compensated.
3. **Data Sovereignty:** All Egyptian user data must be stored in compliance with Egyptian data protection law; no data sold to third parties.
4. **Commission Transparency:** Users always see the commission relationship; FitX never silently promotes products.
5. **Free Tier Preservation:** Core workout and food logging features remain free permanently.
6. **Arabic First:** All user-facing copy must be in Egyptian Arabic as the default; English is secondary.

---

## 8. Regulatory & Compliance Requirements

| Requirement | Regulation | Action |
|-------------|------------|--------|
| Data Privacy | Egyptian Personal Data Protection Law (2020) | Privacy policy + data minimization |
| Payment Processing | Central Bank of Egypt regulations | Use licensed PSPs (Fawry, Paymob) |
| Nutritional Claims | Egyptian Food Safety Authority | No medical claims in copy |
| App Distribution | Google Play + Apple App Store policies | Content policy compliance review |

---

## 9. Business Assumptions

1. Egyptian smartphone penetration among 18–35 age group is ≥75%.
2. Users are willing to pay 39 EGP/month for a proven fitness tool.
3. Local merchants will accept a 10–15% commission model if it delivers verified customers.
4. AI pose detection can run on mid-range Android phones (Snapdragon 665+) at acceptable performance.
5. Growth is primarily organic/word-of-mouth in Phase 1, reducing CAC.

---

## 10. Business Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| EGP devaluation increases USD-denominated costs | High | Medium | Max out local infrastructure; minimize USD costs |
| Competitor (e.g., regional app) copies model | Medium | High | Speed to market + community lock-in |
| Merchant partners fail to honor deals | Medium | High | Pre-screening + automated rating enforcement |
| App Store rejection or policy changes | Low | Critical | Full compliance review pre-submission |
| User data breach | Low | Critical | End-to-end encryption + security audits |

---

## 11. Success Criteria for Business Sign-Off

The following must be met before production launch:
- [ ] MVP passes QA with 0 critical bugs
- [ ] Legal review of Terms of Service and Privacy Policy complete
- [ ] Payment integration tested with live transactions
- [ ] 50 merchant partners signed before launch
- [ ] App Store / Play Store approval received
- [ ] Customer support process established