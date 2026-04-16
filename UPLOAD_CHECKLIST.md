# Infinityfree Upload Checklist

## ✅ STEP 1: System Ready (Local Preparation)

- [x] PHP 8.4 installed locally
- [x] Composer installed (`vendor` folder exists with 39 packages)
- [x] `database/database.sqlite` created (empty file ready for migrations)
- [x] `.env` file exists (for local testing)
- [x] `.env.infinityfree` template created (for production)
- [x] APP_KEY already generated: `base64:19rcId4Xpw6Yk1rG4N9mby+0bmTApZk+TzGfCdytchY=`
- [x] `INFINITYFREE_DEPLOYMENT.md` guide created
- [x] Project tested locally and working

## ✅ STEP 2: Files Ready for Upload

**Location:** `/home/joseph/Desktop/HGNG_projects/gender-classifier/`

**Upload these folders/files to `/public_html` on Infinityfree:**

### Core Application Files
- [ ] `app/` - Controllers, Middleware, Models (REQUIRED)
- [ ] `bootstrap/` - Initialization files (REQUIRED)
- [ ] `config/` - Configuration (REQUIRED)
- [ ] `database/` - Migrations, seeds, database.sqlite (REQUIRED)
- [ ] `public/` - Web root entry point (REQUIRED)
- [ ] `resources/` - Views, CSS, JS (REQUIRED)
- [ ] `routes/` - API routes (REQUIRED)
- [ ] `storage/` - Logs and cache (REQUIRED)
- [ ] `vendor/` - Dependencies from composer (REQUIRED)

### Core Files
- [ ] `.env` (UPDATE BEFORE UPLOAD - see below)
- [ ] `artisan` - Command runner script
- [ ] `composer.json` - Dependency manifest
- [ ] `composer.lock` - Dependency lock file

### DO NOT UPLOAD
- [ ] `.git` - Git history (not needed on server)
- [ ] `tests/` - Unit tests (not needed on server)
- [ ] `phpunit.xml` - Test configuration
- [ ] `.gitignore` - Git settings
- [ ] `.versionignore` - Vercel config
- [ ] `vercel.json` - Vercel config
- [ ] `Dockerfile` - Docker config
- [ ] `LEARNING_WORKFLOW.md` - Learning document
- [ ] `COMMAND_CHEATSHEET.md` - Local reference
- [ ] `COMPLETION_SUMMARY.md` - Local reference
- [ ] `INFINITYFREE_DEPLOYMENT.md` - This deployment guide
- [ ] `.env.infinityfree` - Keep locally, upload as `.env` instead

## 🔧 STEP 3: Pre-Upload Configuration

### Update .env Before Upload

Before uploading, create the production `.env` file:

```bash
# In your terminal, replace YOUR_DOMAIN with actual domain from email:
sed -i 's/APP_URL=.*/APP_URL=https://YOUR_DOMAIN.infinityfree.net/' .env
sed -i 's/APP_ENV=.*/APP_ENV=production/' .env
sed -i 's/APP_DEBUG=.*/APP_DEBUG=false/' .env
sed -i 's/DB_DATABASE=.*/DB_DATABASE=database\/database.sqlite/' .env
sed -i 's/SESSION_DRIVER=.*/SESSION_DRIVER=file/' .env
sed -i 's/CACHE_STORE=.*/CACHE_STORE=file/' .env
sed -i 's/LOG_LEVEL=.*/LOG_LEVEL=error/' .env
```

**Or manually edit `.env` and change:**
- `APP_ENV=production`
- `APP_DEBUG=false`
- `APP_URL=https://YOUR_DOMAIN.infinityfree.net`
- `DB_DATABASE=database/database.sqlite`
- `SESSION_DRIVER=file`
- `CACHE_STORE=file`
- `LOG_LEVEL=error`

### Verify After Updates

```bash
grep "APP_ENV\|APP_DEBUG\|APP_URL\|DB_DATABASE" .env
```

Should show:
```
APP_ENV=production
APP_DEBUG=false
APP_URL=https://YOUR_DOMAIN.infinityfree.net
DB_DATABASE=database/database.sqlite
```

## 📤 STEP 4: Upload via FTP

### Get Infinityfree FTP Credentials

1. Go to: https://www.infinityfree.net/
2. Sign in to your account
3. Click your hosting account
4. Find FTP credentials email or click "Manage"
5. Copy:
   - **FTP Host:** (e.g., `ftp23.infinityfree.net`)
   - **FTP Username:** (e.g., `if1234567_genderclassifier`)
   - **FTP Password:** (save securely)

### Upload Using FileZilla

1. **Download FileZilla:** https://filezilla-project.org/download.php
2. **Open FileZilla**
3. **File → Site Manager**
4. **New Site**
5. **Configure:**
   - **Host:** `ftp23.infinityfree.net` (from your email)
   - **Protocol:** FTP
   - **Encryption:** Use plain FTP
   - **Logon Type:** Normal
   - **User:** (your FTP username)
   - **Password:** (your FTP password)
6. **Click Connect**

### Upload Files

**LEFT side (Local):** Navigate to `/home/joseph/Desktop/HGNG_projects/gender-classifier`

**RIGHT side (Remote):** Navigate to `/public_html`

**Select and upload:**
- Right-click selected folders → Upload
- Upload time: 2-5 minutes depending on connection

**Important: Upload in this order:**
1. `vendor/` (largest, ~50MB)
2. `app/`, `bootstrap/`, `config/`, `routes/`, `storage/`, `database/`, `public/`, `resources/`
3. `.env`, `artisan`, `composer.json`, `composer.lock`

## 🗄️ STEP 5: Configure Database on Server

### Via C Panel File Manager

1. Go to Infinityfree C Panel
2. Click **File Manager**
3. Navigate to `/public_html/database/`
4. Verify `database.sqlite` exists (should be 116KB)

### Create Tables (if needed)

If migrations don't auto-run, you may need to run:
```
php artisan migrate
```

(Can run via Terminal/SSH if available after connection)

## 🧪 STEP 6: Test Your API

After upload completes:

### Test Endpoint

Visit in browser:
```
https://YOUR_DOMAIN.infinityfree.net/api/classify?name=james
```

### Expected Response

```json
{
  "status": "success",
  "data": {
    "name": "james",
    "gender": "male",
    "probability": 0.98,
    "sample_size": 234,
    "is_confident": true,
    "timestamp": "2026-04-14T22:45:30Z"
  }
}
```

### Test Other Cases

**Test validation gates:**
```
# Test 1: Missing parameter (400)
https://YOUR_DOMAIN.infinityfree.net/api/classify

# Test 2: Array parameter (422)
https://YOUR_DOMAIN.infinityfree.net/api/classify?name[]=john

# Test 3: Empty name (400)
https://YOUR_DOMAIN.infinityfree.net/api/classify?name=
```

## ⚠️ STEP 7: Troubleshooting

### Problem: 500 Error
```
Check logs: /storage/logs/laravel.log
```

### Problem: 404 on /api/classify
```
Verify: routes/api.php uploaded correctly
Verify: public/index.php exists
```

### Problem: Database error
```
Verify: database/database.sqlite exists and is writable
```

### Problem: Permission denied
```
Set permissions:
- Folders: 755 (read, write, execute)
- Files: 644 (read, write)
```

### Problem: Connection timeout
```
Check: Genderize.io API is accessible (may be blocked on server)
Alternative: Add timeout configuration
```

## 📝 Final Checklist

Before hitting "Upload All":

- [ ] `.env` updated with production settings
- [ ] `YOUR_DOMAIN` replaced in `.env` APP_URL
- [ ] FTP credentials copied from email (3 items)
- [ ] FileZilla installed and configured
- [ ] Local `/home/joseph/Desktop/HGNG_projects/gender-classifier` folder ready
- [ ] Remote `/public_html` folder ready (new or empty)
- [ ] Upload started (2-5 minutes)
- [ ] No upload errors in FileZilla
- [ ] Test endpoint: `/api/classify?name=james`
- [ ] Getting 200 response with JSON data
- [ ] CORS headers present (test with curl -i)

## 🚀 Success Indicators

✅ **You're live when:**
1. FileZilla shows all files uploaded (green checks)
2. API responds to `/api/classify?name=james`
3. Returns JSON with gender classification data
4. No 500 errors in `/storage/logs/laravel.log`
5. CORS headers allow all origins

## Questions?

Refer to:
- `INFINITYFREE_DEPLOYMENT.md` - Full deployment guide
- `README.md` - API documentation
- `COMMAND_CHEATSHEET.md` - Quick commands reference
