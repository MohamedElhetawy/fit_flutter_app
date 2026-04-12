# FitX — AI Integration Specification

**Version:** 1.0.0

---

## 1. AI Features Overview

| Feature | AI Type | Where | Model | Tier |
|---------|---------|-------|-------|------|
| Food Recognition | Computer Vision (TFLite) | On-device | Custom EfficientNet-Lite | Free |
| Pose Correction | Pose Estimation (TFLite) | On-device | MediaPipe + custom | Pro |
| Fridge Rescue | LLM | Cloud (Claude API) | claude-sonnet-4-20250514 | Free (3/month) |
| Budget Meal Planning | Optimization + LLM | Cloud | Algorithm + Claude | Free/Pro |
| Workout Plan Generation | Rule-based | Server | Algorithm | Free |
| Adaptive Training | Rules + heuristics | Server | Algorithm | Pro |
| Voice Coach Scripts | LLM | Cloud (Claude API) | claude-sonnet-4-20250514 | Pro |
| Nutritional Analysis | Rule-based | Server | Mifflin-St Jeor | Free |

---

## 2. On-Device AI (TensorFlow Lite)

### 2.1 Food Recognition Model

**Architecture:** EfficientNet-Lite2 with transfer learning  
**Training Dataset:** 50,000 images of Egyptian dishes (custom collected + augmented)  
**Classes:** 50 Egyptian food categories (top-20 at MVP, expanding to 50 post-launch)  
**Model Size:** ~15MB (post-quantization, INT8)  
**Input:** 224×224 RGB image  
**Output:** Softmax probability distribution over 50 classes

**Top 20 Classes at Launch:**
كشري، فول، طعمية، هواوشي، بيض مقلي، بيض مسلوق، جبن قريش، لبن، أرز أبيض، عدس، شوربة، فراخ مشوية، كفتة، ملوخية، بامية، بطاطس، سلاطة خضرا، موز، تفاح، برتقال

**Performance Targets:**

- Top-1 Accuracy: ≥80% on test set
- Top-3 Accuracy: ≥95% on test set
- Inference Time: <3s on Samsung Galaxy A32 (2GB RAM)
- Battery per 10 uses: <0.5%

**Model Update Strategy:**

```
Models hosted on Cloudflare R2 + CDN
Version manifest checked at app startup (max 1x/day)
Delta update: Only if model version has changed
Download in background (Wi-Fi preferred, mobile data if <5MB)
Old model kept until new model verified working
```

---

### 2.2 Pose Detection Model

**Architecture:** MediaPipe BlazePose (base model) + FitX custom form-analysis layer  
**Input:** Camera frames at 30fps  
**Output:** 33 body landmark coordinates (x, y, z, visibility)

**Form Analysis Layer (rule-based on top of landmarks):**

```typescript
interface PoseRule {
  exercise: ExerciseType;
  jointName: string;       // e.g., 'left_knee', 'right_elbow'
  minAngle: number;        // Valid range
  maxAngle: number;
  feedbackAr: string;      // What to say if violated
  severity: 'warning' | 'error';
}

// Example rules:
const SQUAT_RULES: PoseRule[] = [
  {
    exercise: 'squat',
    jointName: 'knee',
    minAngle: 80,
    maxAngle: 160,
    feedbackAr: 'ركبتك جوا أوي — فرد جسمك شوية',
    severity: 'error'
  },
  {
    exercise: 'squat',
    jointName: 'back',
    minAngle: 150,
    maxAngle: 180,
    feedbackAr: 'حافظ على ضهرك مستقيم يا بطل',
    severity: 'warning'
  }
];
```

**Performance Targets:**

- Landmark detection: 30fps on iPhone 12 / Samsung A54
- Form feedback latency: <500ms from error to audio
- Battery: <5% per 30-minute session
- Accuracy: Validated by certified personal trainer on 50 test videos

---

## 3. Cloud AI (Claude API)

### 3.1 Integration Architecture

```
Mobile App
    │
    ▼
FitX API (Node.js)
    │
    ▼
AI Service (Python/FastAPI)
    │
    ▼
Anthropic Claude API
(claude-sonnet-4-20250514)
```

The AI Service sits between the API and Claude to:

1. Apply prompt templates
2. Handle retries and timeouts
3. Cache identical requests (Redis, 24h TTL)
4. Monitor cost and usage
5. Scrub PII before sending

### 3.2 API Call Pattern

```python
import anthropic

client = anthropic.Anthropic()  # API key from environment

async def call_claude(
    system: str,
    user_message: str,
    max_tokens: int = 1000,
    temperature: float = 0.7
) -> str:
    # Check cache first
    cache_key = f"claude:{hash_string(system + user_message)}"
    cached = await redis.get(cache_key)
    if cached:
        return cached
    
    # Call API
    try:
        response = client.messages.create(
            model="claude-sonnet-4-20250514",
            max_tokens=max_tokens,
            system=system,
            messages=[{"role": "user", "content": user_message}]
        )
        result = response.content[0].text
        
        # Cache result
        await redis.set(cache_key, result, ex=86400)
        return result
        
    except anthropic.RateLimitError:
        raise ServiceUnavailableError("AI service temporarily at capacity")
    except anthropic.APITimeoutError:
        raise ServiceUnavailableError("AI service timeout")
```

### 3.3 Cost Management

```
Estimated token usage per feature:
  Fridge Rescue: ~500 input + 600 output = 1,100 tokens (~$0.003/call)
  Budget Meal Plan: ~800 input + 1,200 output = 2,000 tokens (~$0.005/call)
  Voice Script: ~300 input + 200 output = 500 tokens (~$0.001/call)

Monthly estimate (50k MAU, 10% use AI features):
  ~5,000 Fridge Rescue calls × $0.003 = $15
  ~3,000 Meal Plan calls × $0.005 = $15
  ~10,000 Voice Scripts × $0.001 = $10
  Total estimated Claude cost: ~$40/month

Cost controls:
  - Cache identical requests (saves ~30% calls)
  - Free tier: 3 AI-assisted calls/month
  - Pro tier: Unlimited AI calls
  - Monthly hard cap: $200 (circuit breaker)
```

---

## 4. AI Fallback Strategy

| Feature | Primary | Fallback |
|---------|---------|---------|
| Food Recognition | On-device TFLite | Manual search |
| Pose Correction | On-device MediaPipe | Text instructions |
| Fridge Rescue | Claude API | Pre-built recipe templates (offline) |
| Budget Planner | Algorithm + Claude | Algorithm only (no prose explanation) |
| Voice Scripts | Claude API | Pre-recorded generic scripts |

All AI features must gracefully degrade — the app must never crash or block due to AI unavailability.
