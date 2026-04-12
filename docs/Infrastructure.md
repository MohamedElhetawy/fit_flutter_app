# FitX — Infrastructure
**Version:** 1.0.0

---

## 1. Infrastructure Overview

FitX uses a **cloud-native, cost-optimized** infrastructure designed to scale from 0 to 1M users without requiring a complete rearchitecture.

**Design Principle:** Start cheap, scale intentionally. No overprovisioning.

---

## 2. Infrastructure Components

### Compute (Fly.io)

| Service | Config (MVP) | Config (Growth) | Monthly Cost (Est.) |
|---------|-------------|-----------------|---------------------|
| fitx-api | 2× shared-cpu-2x, 512MB RAM | 4× shared-cpu-4x, 1GB RAM | $20–50 |
| fitx-ai-service | 1× performance-2x, 2GB RAM | 2× performance-4x, 4GB RAM | $30–80 |
| fitx-notifications | 1× shared-cpu-1x, 256MB RAM | 2× shared-cpu-2x | $10–20 |

**Deployment Regions:**
- Primary: ams (Amsterdam) — closest Fly.io region to Egypt
- Secondary: mad (Madrid) — European failover
- Future: Middle East region when available

**Auto-scaling Config:**
```toml
[http_service.concurrency]
  type = "requests"
  soft_limit = 200
  hard_limit = 250

[auto_stop_machines]
  enabled = true  # Scale to zero on staging (cost saving)
  stop_timeout = "5m"
```

### Database (Supabase)
- Plan: Pro ($25/month)
- Engine: PostgreSQL 15
- Region: EU West (Frankfurt) — best latency to Egypt
- Storage: 8GB SSD (expandable)
- Connections: 200 max (PgBouncer pooler enabled)
- Backups: Daily automatic, 30-day retention
- Read Replicas: Added at 100k+ MAU

### Cache (Upstash Redis)
- Plan: Pay-as-you-go (Free tier: 10k commands/day)
- Region: EU West
- Max Memory: 256MB (upgradeable)
- Persistence: AOF enabled
- Expected Cost: $0–$10/month (MVP), $20–50 (growth)

### File Storage (Cloudflare R2)
- Cost: $0.015/GB storage + $0 egress (no egress fees!)
- Buckets:
  - `fitx-media` — exercise images, food images, merchant photos
  - `fitx-audio` — voice coach clips, workout audio cues
  - `fitx-models` — TFLite model files for OTA updates
  - `fitx-exports` — user data export files (temporary, TTL 24h)
- CDN: Cloudflare CDN automatically serves R2 content globally

### CDN & DNS (Cloudflare)
- Plan: Free (more than sufficient for MVP)
- Features Used:
  - CDN for all static assets
  - DDoS protection (automatic)
  - WAF rules (custom for FitX)
  - DNS management
  - SSL certificates (automatic)

### Push Notifications (Firebase)
- Plan: Spark (Free)
- FCM for Android + APNs bridge for iOS
- Capacity: Up to 1M notifications/day free

### SMS (Twilio / Local Provider)
- Provider: Primary = local Egyptian SMS provider (lower cost, better delivery)
- Fallback: Twilio
- Cost: ~0.05–0.15 EGP per SMS

### Payment Processing (Fawry + Paymob)
- Fawry: Egyptian market leader; no fixed monthly fee; 2.5% per transaction
- Paymob: Credit card processing; 2.75% per transaction
- No PCI scope on FitX servers (all card data handled by PSP)

---

## 3. Network Architecture

```
[End User in Egypt]
        │
        ▼
[Cloudflare CDN / WAF]  ← Static assets served from cache here
        │
        ▼
[Fly.io Edge Load Balancer]
        │
    ┌───┴───┐
    ▼       ▼
[API 1]  [API 2]   ← Fly.io VMs in Amsterdam
    │       │
    └───┬───┘
        │
    ┌───▼────────────────────────────────────┐
    │          Private Network (Fly.io)       │
    │                                         │
    │   [PostgreSQL]   [Redis]   [AI Service] │
    │   (Supabase)   (Upstash)               │
    └─────────────────────────────────────────┘
```

---

## 4. Cost Summary (MVP Phase)

| Service | Monthly Cost (EGP estimate) |
|---------|---------------------------|
| Fly.io Compute | ~1,200 EGP |
| Supabase Pro | ~1,200 EGP |
| Upstash Redis | ~200 EGP |
| Cloudflare R2 | ~100 EGP |
| Cloudflare (DNS/CDN/WAF) | Free |
| Firebase (FCM) | Free |
| SMS (OTP) | ~500 EGP (10k users) |
| Sentry (error tracking) | Free (team plan) |
| GitHub Actions | Free (public/team) |
| Doppler (secrets) | Free (team plan) |
| **Total Infrastructure** | **~3,200 EGP/month** |

This cost is covered by just ~82 Pro subscribers at 39 EGP/month.

---

## 5. Disaster Recovery

| Scenario | RTO | RPO | Recovery Action |
|----------|-----|-----|-----------------|
| Single API instance failure | <30s | 0 | Fly.io auto-restart + load balance |
| Full Fly.io region down | 5 min | 0 | Redeploy to secondary region (mad) |
| Database failure | 4 hours | 24 hours | Restore from daily Supabase backup |
| Redis failure | 2 min | 0 | Upstash automatic failover; app falls back to DB |
| CDN outage | Immediate | 0 | Origin serving as fallback |