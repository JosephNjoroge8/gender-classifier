# Command Cheat Sheet - Quick Reference

## Essential Commands for This Project

### Development

```bash
# Start the development server
php artisan serve

# Run migrations (creates database tables)
php artisan migrate

# Check all routes
php artisan route:list

# Clear cache
php artisan cache:clear
```

### Testing

```bash
# Test happy path
curl "http://127.0.0.1:8000/api/classify?name=james"

# Test missing parameter (400)
curl "http://127.0.0.1:8000/api/classify"

# Test empty parameter (400)
curl "http://127.0.0.1:8000/api/classify?name="

# Test array parameter (422)
curl "http://127.0.0.1:8000/api/classify?name[]=john&name[]=jane"

# Test with error output
curl -i "http://127.0.0.1:8000/api/classify?name=james"

# Pretty print JSON response
curl "http://127.0.0.1:8000/api/classify?name=james" | python3 -m json.tool

# Check CORS headers
curl -i "http://127.0.0.1:8000/api/classify?name=james" | grep -i access-control

# Extract just the status code
curl -o /dev/null -s -w "%{http_code}" "http://127.0.0.1:8000/api/classify?name=james"
```

### Git - Version Control

```bash
# Check status
git status

# See changes made to files
git diff

# See changes to specific file
git diff filename.php

# See last 10 commits
git log --oneline -10

# Show a specific commit's changes
git show abc123

# Add all changes to staging
git add .

# Add specific file to staging
git add filename.php

# Commit changes
git commit -m "feat: description of what changed"

# Push to GitHub
git push

# Pull from GitHub
git pull

# Create new branch
git checkout -b feature-name

# Switch branches
git checkout branch-name

# See all branches
git branch

# Undo changes to a file (not committed)
git restore filename.php

# Undo last commit (keep changes)
git reset HEAD~1

# Undo last commit AND changes
git reset --hard HEAD~1

# View a past version
git checkout abc123

# Create a new commit that undoes a previous commit
git revert abc123
```

### Git - Initial Setup (First Time Only)

```bash
# Initialize git repo
git init

# Add GitHub as remote
git remote add origin https://github.com/USERNAME/repo-name.git

# Rename branch to Main
git branch -M Main

# Push to GitHub (first time)
git push -u origin Main

# After first push, just use:
git push
git pull
```

### Docker & Deployment

```bash
# Build Docker image
docker build -t gender-classifier .

# Run Docker container
docker run -p 8000:80 gender-classifier

# Test deployed app
curl "https://gender-classifier-xxxx.vercel.app/api/classify?name=james"
```

### File Management

```bash
# List files
ls -la

# See file contents
cat filename.php

# Create file
touch filename.php

# Delete file
rm filename.php

# Move/rename file
mv old-name.php new-name.php

# Search for text in files
grep -r "search-term" .

# Count lines in file
wc -l filename.php

# View first 20 lines
head -20 filename.php

# View last 20 lines
tail -20 filename.php

# View file with line numbers
cat -n filename.php
```

---

## Message Template for Commits

Use this format for clear commit history:

```
type: brief description

optional longer explanation about why this change

Examples:
  feat: add CORS headers middleware
  fix: handle array parameters correctly
  docs: update README with Vercel instructions
  perf: optimize database queries
  refactor: reorganize validation logic
```

Types:
- `feat:` = new feature
- `fix:` = bug fix
- `docs:` = documentation only
- `perf:` = performance improvement
- `refactor:` = code reorganization (no functional change)
- `test:` = add/update tests
- `conf:` = configuration changes

---

## File Paths - What Goes Where

```
gender-classifier/
├── app/Http/Controllers/ClassifyController.php
│   └─ Business logic (validation, API calls, transformation)
│
├── app/Http/Middleware/AddCorsHeaders.php
│   └─ CORS header injection (same on all responses)
│
├── routes/api.php
│   └─ Define GET /api/classify route
│
├── bootstrap/app.php
│   └─ Register AddCorsHeaders middleware
│
├── .env
│   └─ Configuration (APP_KEY, APP_ENV, etc.)
│
├── public/index.php
│   └─ Entry point (don't edit, Laravel creates it)
│
├── vercel.json
│   └─ Deployment config (tells Vercel how to run)
│
├── Dockerfile
│   └─ Container config (for Docker/other platforms)
│
└── README.md
    └─ Documentation (update with all info for users)
```

---

## Common Errors & Fixes

```
Error: "Route not found" (404)
Fix:
  1. Check routes/api.php has the route
  2. Check bootstrap/app.php registers the routes
  3. Restart php artisan serve
  
Error: "Type error: trim() expects string" (500)
Fix:
  1. Check type with is_string() BEFORE trim()
  2. Order matters: fetch → check presence → check type → trim → check content

Error: "CORS header missing" (browser blocks request)
Fix:
  1. Check AddCorsHeaders.php exists
  2. Check bootstrap/app.php registers it
  3. Run: curl -i http://localhost/api/ | grep -i access-control

Error: "502 Bad Gateway" on live
Fix:
  1. Check Vercel build logs
  2. Test locally: php artisan serve
  3. If local works: platform issue (check env vars, APP_KEY)
  4. If local broken: commit fix and push

Error: "Composer install fails"
Fix:
  1. Check PHP version: php --version (need 8.1+)
  2. Check Composer: composer --version
  3. Update: composer update
  4. Or: rm composer.lock && composer install
```

---

## Vercel Deployment Quick Steps

```bash
# Step 1: Make sure all changes are committed
git status
git add .
git commit -m "Ready for deployment"

# Step 2: Push to GitHub
git push

# Step 3: On Vercel.com
# - Click "Add Project"
# - Select gender-classifier
# - Add Environment Variables:
#   APP_KEY=base64:...
#   APP_ENV=production
#   APP_DEBUG=false
# - Click Deploy
# - Wait 1-2 minutes

# Step 4: Test
curl "https://live-url/api/classify?name=james"
```

---

## Useful URLs

- **GitHub Repository:** https://github.com/JosephNjoroge8/gender-classifier
- **Vercel Dashboard:** https://vercel.com/dashboard
- **Genderize.io Docs:** https://genderize.io
- **Laravel Docs:** https://laravel.com/docs
- **HTTP Status Codes:** https://httpwg.org/specs/rfc9110.html#status.codes

---

## Next Project Template

When starting a new API project, copy this checklist:

```markdown
# New Project Setup

## Day 1: Planning
- [ ] Document endpoint URL
- [ ] Document inputs (parameters, types, validation)
- [ ] Document outputs (JSON fields)
- [ ] Document error cases (400, 422, 502)
- [ ] Document validation gates
- [ ] Choose external API (get docs + API key)
- [ ] Choose deployment platform

## Day 2: Local Setup
- [ ] laravel new project-name
- [ ] php artisan make:controller ApiController
- [ ] php artisan make:middleware CorsHeaders
- [ ] php artisan serve (verify works)

## Day 3: Implementation
- [ ] Create routes
- [ ] Implement validation gates
- [ ] Call external API
- [ ] Transform data
- [ ] Add CORS middleware
- [ ] Test locally (all error cases)

## Day 4: Git Repository
- [ ] git init
- [ ] git add .
- [ ] git commit -m "initial"
- [ ] Create GitHub repo
- [ ] git remote add origin
- [ ] git push -u origin Main

## Day 5: Deployment Config
- [ ] Create vercel.json
- [ ] Create .vercelignore
- [ ] Create Dockerfile (optional)
- [ ] git commit and push

## Day 6: Deploy
- [ ] Connect to Vercel
- [ ] Add environment variables
- [ ] Deploy
- [ ] Test live endpoint

## Day 7: Documentation
- [ ] Update README
- [ ] Add examples
- [ ] Document all error cases
- [ ] Final git push
```

---

## Profile: You're Now a Backend Developer! 🚀

Skills mastered:
✅ REST API design
✅ Input validation (3-gate pattern)
✅ External API integration
✅ Error handling (status codes)
✅ Data transformation
✅ Middleware (CORS)
✅ Git workflows
✅ Cloud deployment (Vercel)

Next level: Learn to build without AI assistance using these same patterns!
