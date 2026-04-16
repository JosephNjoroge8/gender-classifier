# Deploying Gender Classifier to Infinityfree

## What You'll Need

1. **Infinityfree Account** (created above)
2. **FTP Credentials** (from Infinityfree email)
3. **FTP Client** (FileZilla - free software)
4. **Your project files** (already have this)

## Step 1: Prepare Files for Upload

Your Laravel project structure needs to be uploaded as-is.

Key files/folders to upload:
```
app/
bootstrap/
config/
database/
public/          ← Web root (public files)
resources/
routes/
storage/
vendor/           ← Dependencies (run composer install locally first)
.env              ← Configuration (create on server)
artisan
composer.json
composer.lock
```

## Step 2: Install Composer Locally (If Not Done)

Run locally on your computer:

```bash
cd /home/joseph/Desktop/HGNG_projects/gender-classifier
composer install
```

This creates the `vendor/` folder with all dependencies.

## Step 3: Create .env File for Production

Create a `.env` file in your project:

```
APP_NAME="Gender Classifier"
APP_ENV=production
APP_KEY=base64:19rcId4Xpw6Yk1rG4N9mby+0bmTApZk+TzGfCdytchY=
APP_DEBUG=false
APP_URL=https://genderclassifier.infinityfree.net

LOG_CHANNEL=stack
LOG_LEVEL=error

DB_CONNECTION=sqlite
DB_DATABASE=/home/u123456789/public_html/database/database.sqlite

CACHE_DRIVER=file
SESSION_DRIVER=file
QUEUE_DRIVER=sync

BROADCAST_DRIVER=log
```

Replace `https://genderclassifier.infinityfree.net` with your actual domain.

## Step 4: Download FTP Client

Download **FileZilla** (free):
https://filezilla-project.org/

## Step 5: Connect via FTP

In FileZilla:

1. File → Site Manager
2. New Site
3. Enter:
   - **Host:** ftpXX.infinityfree.net (from your email)
   - **Username:** (from your email)
   - **Password:** (from your email)
   - **Port:** 21
4. Connect

You should now see Infinityfree folders on right side.

## Step 6: Upload Project Files

1. On LEFT: navigate to `/home/joseph/Desktop/HGNG_projects/gender-classifier`
2. On RIGHT: navigate to `/public_html`
3. Upload EVERYTHING from your local folder to `/public_html`

This includes:
- `app/`
- `bootstrap/`
- `config/`
- `database/`
- `public/`
- `routes/`
- `storage/`
- `vendor/`
- `.env`
- `artisan`
- `composer.json`
- `composer.lock`

Takes 2-3 minutes depending on connection.

## Step 7: Create SQLite Database

1. Go to C Panel (link from Infinityfree email)
2. Look for: "File Manager"
3. Navigate to: `public_html/database/`
4. Create empty file: `database.sqlite`

## Step 8: Set File Permissions

Via C Panel / File Manager:

Make these folders writable (chmod 755):
- `storage/`
- `bootstrap/cache/`
- `public/`

(Usually done automatically, but verify)

## Step 9: Create app key

SSH into Infinityfree (if available) or run locally and copy:

```bash
# Run locally:
php artisan key:generate

# Copy the key from .env
# Should be: base64:19rcId4Xpw6Yk1rG4N9mby+0bmTApZk+TzGfCdytchY=
```

Add this to `.env` on server (via File Manager → Edit `.env`)

## Step 10: Run Migrations

SSH (if available):
```bash
php artisan migrate
```

If SSH not available, Infinityfree often auto-runs migrations on first request.

## Step 11: Test Your API

Visit: `https://genderclassifier.infinityfree.net/api/classify?name=james`

Should return:
```json
{
  "status": "success",
  "data": {
    "name": "james",
    "gender": "male",
    ...
  }
}
```

## Troubleshooting

**Problem: 500 Error**
→ Check `/storage/logs/laravel.log` for error details

**Problem: 404 on /api/classify**
→ Verify routes uploaded correctly in `routes/app.php`

**Problem: Database error**
→ Verify `database/database.sqlite` file exists

**Problem: Permission denied**
→ Check file permissions (should be 755 for folders, 644 for files)

