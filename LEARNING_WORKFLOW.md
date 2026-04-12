# Complete Workflow Guide: Gender Classifier API Project

## Table of Contents
1. [Terminal Context Explanation](#terminal-context-explanation)
2. [Overall Project Workflow](#overall-project-workflow)
3. [The Complete Development Journey](#the-complete-development-journey)
4. [How to Repeat This Independently](#how-to-repeat-this-independently)
5. [Key Concepts & Patterns](#key-concepts--patterns)

---

## Terminal Context Explanation

### What We Just Ran

```bash
# Last command run (from terminal context)
php --version && composer --version
```

**Output:** Shows you have PHP 8.4 and Composer 2.x installed (required for this project)

### Git Status

```bash
Changes not staged for commit:
  modified:   Dockerfile
  modified:   README.md

Untracked files:
  vercel.json
  .vercelignore
```

**Translation:**
- `modified:` files = Changed but not committed (git sees the changes)
- `Untracked:` files = New files git doesn't know about yet

### Git Log (Last 10 Commits)

```
1610a85 fix: include composer install in Dockerfile
1593fd5 perf: ultra-minimal Dockerfile for fast deployment
10bd350 fix: simplify Dockerfile to use pre-built vendor
...
```

**Translation:** These are snapshots of your work. Each commit is a checkpoint you can return to.

---

## Overall Project Workflow

### Phase 1: Planning & Setup (Days 1-2)

```
Task Given
    ↓
Understand Requirements (100-point spec)
    ↓
Choose Technology Stack (PHP 8.4 + Laravel)
    ↓
Create Project Structure
    └─ Create app/Http/Controllers/ClassifyController.php
    └─ Create app/Http/Middleware/AddCorsHeaders.php
    └─ Create routes/api.php
    ↓
Test Locally (php artisan serve)
```

**Command Examples:**
```bash
laravel new gender-classifier
cd gender-classifier
php artisan make:controller ClassifyController
php artisan serve
```

### Phase 2: Core Development (Days 3-4)

```
Implement Controller Logic
    ├─ Gate 1: Check if name parameter exists
    ├─ Gate 2: Check if name is a string (type)
    ├─ Gate 3: Check if name has content after trim
    ↓
Test Locally
    ├─ Test happy path: ?name=james → success
    ├─ Test missing: (no param) → 400
    ├─ Test array: ?name[]=john → 422
    ↓
Call Genderize API
    ├─ Make HTTP GET to api.genderize.io
    ├─ Parse response (extract gender, probability, count)
    ├─ Handle errors (timeouts, failures)
    ↓
Transform Data
    ├─ Rename count → sample_size
    ├─ Compute is_confident (AND logic)
    ├─ Generate processed_at timestamp
    ↓
Return Proper JSON
    ├─ Success: { status, data }
    ├─ Error: { status, message }
```

**Key Bug Found & Fixed:**
```php
// ❌ WRONG - causes fatal error if name is array
$name = trim($_GET['name']);  // trim() on array crashes

// ✅ CORRECT - check type BEFORE trim
$name = $_GET['name'] ?? null;
if (!is_string($name)) {
    return error(422, "must be string");  
}
$name = trim($name);
```

### Phase 3: Git & Version Control (Day 5)

```
Local Testing Complete
    ↓
Create GitHub Repository
    ├─ Name: gender-classifier
    ├─ Public visibility
    ├─ Initialize with README
    ↓
Push Code to GitHub
    ├─ git init
    ├─ git add .
    ├─ git commit -m "initial commit"
    ├─ git remote add origin <URL>
    ├─ git push -u origin Main
```

**What This Does:**
- Backs up your code in cloud
- Enables easy deployment
- Creates history/audit trail
- Enables collaboration

### Phase 4: Deployment Setup (Day 6)

```
Choose Deployment Platform
    ├─ Option A: Render (Docker-based)
    ├─ Option B: Railway (fast Laravel deployment)
    └─ Option C: Vercel (serverless - what we chose)
    ↓
Create Configuration Files
    ├─ vercel.json (tells Vercel how to build)
    ├─ .vercelignore (files to skip deployment)
    └─ Dockerfile (containerization backup)
    ↓
Set Environment Variables
    ├─ APP_KEY (encryption key)
    ├─ APP_ENV=production
    └─ APP_DEBUG=false
    ↓
Deploy to Platform
    ├─ Connect GitHub repository
    ├─ Platform auto-detects configuration
    ├─ Platform builds & deploys
    ↓
Test Live Endpoint
    └─ Verify https://live-url/api/classify works
```

### Phase 5: Documentation (Day 7)

```
Update README.md
    ├─ Add Vercel deployment instructions
    ├─ Add evaluation criteria checklist
    ├─ Add troubleshooting guide
    ├─ Add performance targets
    ↓
Commit to GitHub
    ├─ git add README.md
    ├─ git commit -m "docs: update..."
    ├─ git push
```

---

## The Complete Development Journey

### Day 1: Project Understanding

**Goal:** Understand what we're building

```bash
# Terminal: Read the requirements
# Write down:
# - What is the endpoint? /api/classify
# - What are inputs? name query parameter
# - What are outputs? gender, probability, etc.
# - What can go wrong? Missing param, wrong type, API down
# - How do I validate? Multiple gates (presence, type, content)
```

### Day 2: Local Setup

**Goal:** Get Laravel running locally

```bash
# Step 1: Create Laravel project
laravel new gender-classifier
cd gender-classifier

# Step 2: Create controller
php artisan make:controller --api ClassifyController

# Step 3: Create middleware
php artisan make:middleware AddCorsHeaders

# Step 4: Verify setup
php artisan route:list
php artisan serve
```

**Verification:**
- Navigate to http://127.0.0.1:8000 in browser
- See Laravel welcome page
- Run: `curl http://127.0.0.1:8000/api/classify` (should get 404 initially)

### Day 3: Implement Core Logic

**Goal:** Make the endpoint work

```bash
# File: routes/api.php
# Add: Route::get('/classify', ClassifyController@classify);

# File: app/Http/Controllers/ClassifyController.php
# Code logic:
# 1. Fetch name parameter
# 2. Validate presence + type
# 3. Call Genderize API
# 4. Transform data
# 5. Return JSON
```

**Test Each Gate:**
```bash
# Gate 1: Present?
curl "http://127.0.0.1:8000/api/classify?name=james"       # ✅ Success
curl "http://127.0.0.1:8000/api/classify"                  # ❌ 400 Missing
curl "http://127.0.0.1:8000/api/classify?name="            # ❌ 400 Empty

# Gate 2: String?
curl "http://127.0.0.1:8000/api/classify?name[]=john"      # ❌ 422 Array

# Gate 3: After trim?
curl "http://127.0.0.1:8000/api/classify?name=   "         # ❌ 400 Whitespace
```

### Day 4: Add CORS Middleware

**Goal:** Allow browser access from any domain

```bash
# File: app/Http/Middleware/AddCorsHeaders.php
# Code: Add `Access-Control-Allow-Origin: *` header to all responses

# File: bootstrap/app.php  
# Register middleware: $middleware->api(prepend: [AddCorsHeaders::class])
```

**Verification:**
```bash
curl -i "http://127.0.0.1:8000/api/classify?name=james" | grep -i "access-control"
# Should see: Access-Control-Allow-Origin: *
```

### Day 5: Create GitHub Repository

**Goal:** Back up code and enable deployment

```bash
# Step 1: Go to https://github.com and create new repo
# Repository name: gender-classifier
# Public visibility: ON
# Initialize: Leave unchecked (we have code already)

# Step 2: Copy HTTPS URL from GitHub (e.g., https://github.com/JosephNjoroge8/gender-classifier.git)

# Step 3: In terminal, add remote
git remote add origin https://github.com/JosephNjoroge8/gender-classifier.git
git branch -M Main                    # Rename default branch to Main
git push -u origin Main               # Push local code to GitHub
```

**What Happened:**
- `-u` = set upstream (link local Main to remote Main)
- Now `git push` and `git pull` work automatically
- Code is backed up on GitHub

### Day 6: Prepare Deployment Files

**Goal:** Tell Vercel how to run our app

**File 1: vercel.json**
```json
{
  "builds": [
    {
      "src": "public/index.php",
      "use": "@vercel/php"
    }
  ],
  "routes": [
    {
      "src": "/(.*)",
      "dest": "public/index.php"
    }
  ]
}
```

**Translation:**
- `builds`: "Use @vercel/php runtime for public/index.php"
- `routes`: "Send ALL requests to public/index.php" (Laravel routing)
- This tells Vercel: "This is a PHP app, here's the entry point"

**File 2: .vercelignore**
```
.git
tests
README.md
storage/logs
```

**Translation:** "Don't upload these files to Vercel (they waste space and time)"

**File 3: Dockerfile** (optional backup for other platforms)
```dockerfile
FROM php:8.4-apache
WORKDIR /var/www/html
COPY composer.* .
RUN curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer install --no-dev
COPY . .
```

**Translation:**
- `FROM`: Start with PHP 8.4 container
- `COPY composer*`: Copy dependency list
- `RUN composer install`: Download dependencies
- `COPY . .`: Copy application code

### Day 7: Deploy & Verify

**Goal:** Make app live on the internet

```bash
# Step 1: Push config files to GitHub
git add vercel.json .vercelignore README.md Dockerfile
git commit -m "Add deployment configuration"
git push

# Step 2: Go to https://vercel.com
# - Click "Add New..." → "Project"
# - Select gender-classifier repository
# - Click "Import"
# - Vercel auto-detects config, builds, and deploys

# Step 3: Test live URL
curl "https://gender-classifier-xxxx.vercel.app/api/classify?name=james"

# Step 4: Verify CORS
curl -i "https://gender-classifier-xxxx.vercel.app/api/classify?name=maria" \
  | grep -i "access-control"
```

---

## How to Repeat This Independently

### Step 1: Plan the Project

Create a checklist:
```
□ What is the endpoint?
□ What are inputs? (types, validation rules)
□ What are outputs? (fields, format)
□ What can go wrong? (error cases)
□ How do I validate input? (gates/validations)
□ What external API do I call?
□ How do I transform data?
□ Where do I deploy?
```

### Step 2: Create Local Project

```bash
# Initialize
laravel new project-name
cd project-name

# Test it works
php artisan serve
# Visit http://127.0.0.1:8000 in browser
```

### Step 3: Implement Core Logic

**Structure your controller like this:**
```php
public function classify(Request $request) {
    // GATE 1: Presence check
    if (!$request->has('name')) {
        return response()->json([
            'status' => 'error',
            'message' => 'name is required'
        ], 400);
    }

    $name = $request->input('name');

    // GATE 2: Type check
    if (!is_string($name)) {
        return response()->json([
            'status' => 'error',
            'message' => 'name must be string'
        ], 422);
    }

    $name = trim($name);

    // GATE 3: Content check
    if (empty($name)) {
        return response()->json([
            'status' => 'error',
            'message' => 'name cannot be empty'
        ], 400);
    }

    // CALL EXTERNAL API
    try {
        $response = Http::timeout(15)->get('https://api.example.com', [
            'name' => $name
        ]);
        $data = $response->json();
    } catch (Exception $e) {
        return response()->json([
            'status' => 'error',
            'message' => 'External API failed'
        ], 502);
    }

    // TRANSFORM DATA
    return response()->json([
        'status' => 'success',
        'data' => [
            'name' => $name,
            'result' => $data['result'],
            'processed_at' => now()->utc()->toISOString()
        ]
    ], 200);
}
```

This pattern works for ANY API gateway:
1. Validate input (multiple gates)
2. Call external API (with error handling)
3. Transform response
4. Return proper JSON

### Step 4: Test Locally

```bash
# Terminal 1: Run server
php artisan serve

# Terminal 2: Test
curl "http://127.0.0.1:8000/api/classify?name=test"
curl "http://127.0.0.1:8000/api/classify"              # Missing param
curl "http://127.0.0.1:8000/api/classify?name[]=test" # Wrong type
```

### Step 5: Create GitHub Repository

```bash
# 1. On GitHub.com: Create new repository

# 2. In terminal:
git init
git add .
git commit -m "Initial commit: API skeleton with validation"
git branch -M Main
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git push -u origin Main

# Verify: Check GitHub.com, your code should appear there
```

### Step 6: Create Deployment Config

**For Vercel:** Create `vercel.json`
```json
{
  "builds": [{"src": "public/index.php", "use": "@vercel/php"}],
  "routes": [{"src": "/(.*)", "dest": "public/index.php"}]
}
```

**For Docker (Heroku, Railway):** Create `Dockerfile`
```dockerfile
FROM php:8.4-apache
WORKDIR /var/www/html
COPY . .
RUN apt-get update && apt-get install -y composer
RUN composer install --no-dev
```

**For AWS Lambda:** Create `serverless.yml`
```yaml
service: my-api
provider:
  name: aws
  runtime: php81
```

**Key principle:** Different platforms need different config, but logic is the same.

### Step 7: Deploy

```bash
# Commit config files
git add vercel.json .vercelignore
git commit -m "Add deployment configuration"
git push

# Then:
# - Vercel: Go to vercel.com → Import project
# - Render: Go to render.com → Create service → Connect GitHub
# - Railway: Run `railway up`
```

### Step 8: Test Live

```bash
curl "https://your-live-url.com/api/endpoint?param=value"
```

---

## Key Concepts & Patterns

### Pattern 1: Input Validation (Three Gates)

**Why:** Prevent bad data from reaching business logic

```
Gate 1 (Presence) → Gate 2 (Type) → Gate 3 (Content) → Business Logic
     ↓ Error                ↓ Error         ↓ Error           ↓ Success
    400              422                  400             200 + data
```

**This pattern applies to:**
- Query parameters
- Request body fields
- File uploads
- Database inputs

### Pattern 2: External API Error Handling

```php
try {
    $response = Http::timeout(15)->get($url, $params);
    return success($response->json());
} catch (Exception $e) {
    // Log for debugging
    Log::error('API Error: ' . $e->getMessage());
    
    // Return proper error
    return error(502, 'External service unavailable');
}
```

**Why:** External APIs can be slow, down, or unreachable

### Pattern 3: Data Transformation

```
Raw Data From API          Your API's Contract
    ↓                                ↑
    ┌────────────────────────────────┘
    │
    ├─ Rename fields (count → sample_size)
    ├─ Compute new fields (is_confident)
    ├─ Remove sensitive fields
    ├─ Add metadata (processed_at)
    └─ Format for client consumption
```

**Why:** Separation of concerns - your API contract shouldn't depend on external APIs

### Pattern 4: HTTP Status Codes (Semantic Meaning)

```
200 OK              → Request succeeded, returning data
400 Bad Request     → Client error in input (missing/content)
404 Not Found       → Resource doesn't exist
422 Unprocessable   → Structure valid, but content invalid (type error)
500 Error           → Server bug (yours)
502 Bad Gateway     → External service failed
503 Unavailable     → Server temporarily down (maintenance)
```

**Why:** Client understands what went wrong without reading message

### Pattern 5: CORS (Cross-Origin Resource Sharing)

```
Browser             Your Server
    │                   │
    ├─ OPTIONS request  │
    │────────────────→  │
    │                  [Check if origin allowed]
    │  ← CORS headers ──┤
    │                   │
    ├─ GET /api/...    │
    │────────────────→  │
```

**Header needed:**
```
Access-Control-Allow-Origin: *
```

**Why:** Browsers by default block cross-domain requests (security feature)

### Pattern 6: Git Workflow (Save Points)

```
Working Directory (your code)
    ↑↓
    ├─ git add . (stage files)
    ↓
Staging Area (ready to commit)
    ├─ git commit (save snapshot)
    ↓
Local Repository (snapshots on your computer)
    ├─ git push (send to GitHub)
    ↓
Remote Repository (GitHub.com)
```

**Each level lets you rollback:**
- `git restore file.php` - undo changes to file
- `git reset HEAD~1` - undo last commit
- `git checkout abc123` - go back to old version

### Pattern 7: Environment Variables

```
Development (local)          Production (live)
    ↓                            ↓
.env.example                 (env from platform)
    ↓                            ↓
APP_DEBUG=true              APP_DEBUG=false
APP_URL=http://localhost    APP_URL=https://prod.com
```

**Why:** Different secrets, settings per environment

---

## Common Mistakes to Avoid

### ❌ Mistake 1: Type checking AFTER trim()

```php
// WRONG - crashes if $name is array
$name = trim($name);
if (!is_string($name)) { ... }
```

```php
// RIGHT - check type first
if (!is_string($name)) { ... }
$name = trim($name);
```

### ❌ Mistake 2: Hardcoding timestamps

```php
// WRONG - same timestamp for every request
'processed_at' => '2026-04-12T10:30:45.000000Z'
```

```php
// RIGHT - fresh timestamp per request
'processed_at' => now()->utc()->toISOString()
```

### ❌ Mistake 3: Missing CORS headers

```php
// WRONG - browser blocks cross-origin requests
return response()->json($data);
```

```php
// RIGHT - allow browser access
return response()->json($data)
    ->header('Access-Control-Allow-Origin', '*');
```

### ❌ Mistake 4: Deploying without testing

```bash
# WRONG order
1. Modify code
2. Deploy

# RIGHT order
1. Modify code
2. Test locally
3. Commit to git
4. Deploy
5. Test live endpoint
```

### ❌ Mistake 5: Ignoring error cases

```php
// WRONG - assumes API always works
$response = Http::get($url);
$data = $response->json();
```

```php
// RIGHT - handle failures
try {
    $response = Http::timeout(15)->get($url);
    if (!$response->successful()) {
        return error(502, 'API failed');
    }
    $data = $response->json();
} catch (Exception $e) {
    return error(502, 'API unreachable');
}
```

---

## How to Learn More

### Your Next Projects

1. **Weather API Gateway**
   - Validate city name
   - Call OpenWeatherMap API
   - Return: city, temperature, conditions
   - Add caching (don't call API if called recently)

2. **Email Validator**
   - Validate email format
   - Call Mailgun verify API
   - Return: valid, suggestion, type
   - Add rate limiting (max 10 req/min per IP)

3. **Language Detection**
   - Validate text input
   - Call translation API
   - Return: language, confidence, text preview
   - Add batch endpoint (multiple texts at once)

### Resources

- [Laravel Documentation](https://laravel.com/docs)
- [HTTP Status Codes](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status)
- [REST API Best Practices](https://restfulapi.net)
- [Git Tutorial](https://git-scm.com/book/en/v2)
- [CORS Explained](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)

---

## Summary: The Universal API Pattern

**Repeat this for any API gateway project:**

```
INPUT VALIDATION     EXTERNAL API      DATA TRANSFORM      RESPONSE
(3 gates)            (+ error handle)   (rename, compute)  (JSON format)
     ↓                    ↓                   ↓                 ↓
Check presence   →   Call with timeout →  Extract fields →  Return proper
Check type       →   Handle 502/503    →  Compute new   →   HTTP status
Check content    →   Catch exceptions  →  Add metadata  →   + data or error
```

This single pattern solves 80% of backend API problems.

---

**Questions?** Check the code examples in the actual files:
- [ClassifyController.php](app/Http/Controllers/ClassifyController.php) - Business logic
- [AddCorsHeaders.php](app/Http/Middleware/AddCorsHeaders.php) - Middleware
- [routes/api.php](routes/api.php) - Routing
