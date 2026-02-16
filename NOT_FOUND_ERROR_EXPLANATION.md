# Vercel NOT_FOUND Error: Comprehensive Analysis & Fix

## 1. The Fix ✅

### What Was Changed

**File: `vercel.json`**
- Changed the static file route from `"dest": "/$1"` to use `rewrites` instead
- Separated API routes from static file serving using `rewrites` for better path handling

**File: `api/index.py`**
- Added `StripAPIPrefixMiddleware` to handle path prefix stripping
- This middleware intercepts requests and removes `/api` prefix before FastAPI routes are matched

### Why This Works

When Vercel routes `/api/predict` to your serverless function, it may pass the full path `/api/predict` to Mangum. However, your FastAPI routes are defined as `/predict` (without the `/api` prefix). The middleware bridges this gap by:

1. Intercepting the request before it reaches FastAPI routing
2. Stripping the `/api` prefix if present
3. Passing the modified path to FastAPI, which then matches `/predict` correctly

---

## 2. Root Cause Analysis 🔍

### What Was Actually Happening vs. What Should Happen

**What was happening:**
- User requests: `https://your-app.vercel.app/api/predict`
- Vercel routes this to `api/index.py` serverless function
- Vercel passes the request path (potentially including `/api/predict`) to Mangum
- Mangum converts it to an ASGI request and passes to FastAPI
- FastAPI tries to match `/api/predict` against its route definitions (`/predict`, `/health`, `/`)
- **No match found → NOT_FOUND (404) error**

**What should happen:**
- User requests: `https://your-app.vercel.app/api/predict`
- Vercel routes to `api/index.py`
- The path should be transformed to `/predict` before FastAPI routing
- FastAPI matches `/predict` → Success ✅

### What Conditions Triggered This Error?

1. **Path Prefix Mismatch**: Your `vercel.json` routes `/api/*` to the function, but FastAPI routes don't account for the `/api` prefix
2. **Vercel Routing Behavior**: Depending on Vercel's routing implementation, it may pass the full original path rather than stripping the prefix
3. **Mangum Path Handling**: Mangum passes the path as-is to FastAPI without modification

### What Misconception Led to This?

**The Misconception**: Assuming that Vercel automatically strips the `/api` prefix when routing to serverless functions.

**Reality**: Vercel's routing behavior can vary:
- With the old `routes` format, it may pass the full path
- With modern file-based routing, it strips the directory name
- The behavior isn't always consistent, so explicit handling is safer

---

## 3. Teaching the Concept 📚

### Why Does This Error Exist?

The NOT_FOUND error exists to **protect you from silent failures**. It's Vercel's way of saying:
- "I received a request for this path"
- "I routed it to your serverless function"
- "But your application couldn't find a matching route"
- "Rather than returning garbage or crashing, I'm returning a clear 404"

This is **defensive programming** at the infrastructure level.

### The Correct Mental Model

Think of Vercel's routing as a **multi-layer system**:

```
User Request: /api/predict
    ↓
[Vercel Routing Layer] → Routes to api/index.py
    ↓
[Serverless Function] → Receives request (path may still be /api/predict)
    ↓
[Mangum Adapter] → Converts to ASGI format
    ↓
[FastAPI Router] → Tries to match /api/predict against routes
    ↓
[Your Route Handlers] → /predict, /health, /
```

**The Problem**: The path transformation should happen between Vercel routing and FastAPI routing, but it wasn't.

**The Solution**: Add middleware that transforms the path before FastAPI sees it.

### How This Fits Into the Broader Framework

**Vercel's Architecture:**
- **Routing Layer**: Handles URL-to-function mapping
- **Serverless Runtime**: Executes your function
- **Your Application**: FastAPI handles business logic

**The Gap**: There's no automatic path prefix stripping between Vercel's routing and your application's routing. You must handle it explicitly.

**This Pattern Appears In:**
- API Gateway → Lambda functions (AWS)
- Cloud Functions → Express apps (Google Cloud)
- Any proxy/routing layer → application framework

---

## 4. Warning Signs to Recognize This Pattern 🚨

### What to Look For

1. **Routes Work Locally But Fail on Vercel**
   - ✅ Local: `http://localhost:8000/predict` works
   - ❌ Vercel: `https://app.vercel.app/api/predict` returns 404
   - **Cause**: Path prefix mismatch

2. **API Routes Return 404 But Root Works**
   - ✅ `/api/` or `/api` might work (root route)
   - ❌ `/api/predict` returns 404
   - **Cause**: Sub-routes not matching due to prefix

3. **Inconsistent Routing Behavior**
   - Some routes work, others don't
   - Routes with same prefix pattern fail
   - **Cause**: Path transformation not applied consistently

### Code Smells & Patterns

**Smell #1: Hardcoded Path Prefixes in Route Definitions**
```python
# ❌ BAD: Hardcoding /api in FastAPI routes
@app.post("/api/predict")  # This won't work with Vercel routing

# ✅ GOOD: Define routes without prefix, handle prefix in middleware
@app.post("/predict")  # Clean route definition
```

**Smell #2: Assuming Automatic Path Stripping**
```python
# ❌ BAD: Assuming Vercel strips /api automatically
# No path handling code

# ✅ GOOD: Explicit path handling
class StripAPIPrefixMiddleware(BaseHTTPMiddleware):
    # Explicitly handle path transformation
```

**Smell #3: Mismatched Route Patterns**
```json
// vercel.json
{
  "routes": [
    { "src": "/api/(.*)", "dest": "api/index.py" }
  ]
}
```
If your FastAPI routes don't account for this, you'll have issues.

### Similar Mistakes in Related Scenarios

1. **Next.js API Routes**: Similar issue if you mount Express/FastAPI under `/api`
2. **AWS API Gateway**: Proxy integrations need path mapping configuration
3. **Docker Reverse Proxies**: Nginx/Traefik need `proxy_pass` path rewriting
4. **Microservices**: Service mesh routing requires path transformation

---

## 5. Alternatives & Trade-offs 🔄

### Alternative 1: Mount FastAPI with Prefix (Current Approach - Recommended)

**Implementation**: Use middleware to strip prefix
```python
class StripAPIPrefixMiddleware(BaseHTTPMiddleware):
    # Strips /api prefix
```

**Pros:**
- ✅ Clean route definitions (`/predict` not `/api/predict`)
- ✅ Works with any routing configuration
- ✅ Easy to test locally (just don't use `/api` prefix)
- ✅ Flexible - can handle multiple prefixes

**Cons:**
- ❌ Requires middleware code
- ❌ Slight performance overhead (minimal)

**Best For**: Production deployments where you want clean separation

---

### Alternative 2: Define Routes with `/api` Prefix

**Implementation**: Change FastAPI routes to include prefix
```python
@app.post("/api/predict")  # Include prefix in route
```

**Pros:**
- ✅ Simple - no middleware needed
- ✅ Explicit - routes show full path

**Cons:**
- ❌ Routes don't match local development (localhost:8000/predict)
- ❌ Less flexible if you change routing
- ❌ Duplicates routing logic

**Best For**: Quick fixes, but not recommended for production

---

### Alternative 3: Use Vercel's Modern File-Based Routing

**Implementation**: Create separate files for each route
```
api/
  ├── predict.py  # Handles /api/predict
  ├── health.py   # Handles /api/health
  └── index.py    # Handles /api/
```

**Pros:**
- ✅ Vercel automatically strips directory prefix
- ✅ No manual path handling needed
- ✅ Better for microservices architecture

**Cons:**
- ❌ More files to maintain
- ❌ Code duplication (shared logic needs to be imported)
- ❌ Harder to use FastAPI's full feature set (docs, dependencies, etc.)

**Best For**: Simple endpoints, microservices

---

### Alternative 4: Use Vercel's `rewrites` Instead of `routes`

**Implementation**: Use rewrites to transform paths
```json
{
  "rewrites": [
    { "source": "/api/:path*", "destination": "/api/index.py?path=:path*" }
  ]
}
```

**Pros:**
- ✅ Path transformation at Vercel level
- ✅ No application code changes

**Cons:**
- ❌ Query parameter approach is hacky
- ❌ Doesn't work well with Mangum/FastAPI
- ❌ Less control over path handling

**Best For**: Simple static rewrites, not recommended for APIs

---

### Alternative 5: Use Sub-Application Mounting

**Implementation**: Mount FastAPI app with prefix
```python
from fastapi import FastAPI
main_app = FastAPI()
api_app = FastAPI()

api_app.post("/predict")  # Define routes without prefix
main_app.mount("/api", api_app)  # Mount at /api
```

**Pros:**
- ✅ Clean separation
- ✅ FastAPI-native approach

**Cons:**
- ❌ More complex setup
- ❌ May not work well with Mangum/Vercel

**Best For**: Complex applications with multiple API versions

---

## Recommended Solution: Middleware Approach (Current Fix)

The middleware approach (Alternative 1) is recommended because:

1. **Separation of Concerns**: Routing configuration (Vercel) vs. route definitions (FastAPI)
2. **Testability**: Routes work the same locally and in production
3. **Flexibility**: Easy to change routing without touching route definitions
4. **Maintainability**: Clear, explicit path handling

---

## Testing Your Fix

### Local Testing
```bash
# Start your FastAPI app locally
cd backend
uvicorn main:app --reload

# Test endpoints (no /api prefix needed locally)
curl http://localhost:8000/predict
curl http://localhost:8000/health
```

### Vercel Testing
```bash
# Deploy to Vercel
vercel --prod

# Test endpoints (with /api prefix)
curl https://your-app.vercel.app/api/predict
curl https://your-app.vercel.app/api/health
```

### Expected Behavior
- ✅ Both local and Vercel should work
- ✅ Routes respond correctly
- ✅ No 404 errors

---

## Summary

**The Problem**: Path prefix mismatch between Vercel routing (`/api/*`) and FastAPI routes (`/predict`)

**The Solution**: Middleware that strips `/api` prefix before FastAPI routing

**The Lesson**: Never assume automatic path transformation - always handle it explicitly

**The Pattern**: This applies to any routing layer → application framework integration

