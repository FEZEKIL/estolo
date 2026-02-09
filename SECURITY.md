# Security & Credentials Setup Guide

## ⚠️ CRITICAL: Exposed Credentials

The repository previously contained exposed API keys and secrets in version control:
- `google-services.json` (Firebase)
- `agconnect-services.json` (Huawei AppGallery)
- Credentials in markdown documentation

**These have been revoked and must not be used anymore.**

## Setup Instructions

### 1. Get Fresh Credentials

#### Firebase (Google Services)
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select/create your project
3. Go to **Project Settings** → **Service Accounts**
4. Download the new `google-services.json`
5. Copy to `android/app/google-services.json` (NOT committed to git)

#### Huawei AppGallery (agconnect-services.json)
1. Log in to [AppGallery Connect](https://appgallery.huawei.com/)
2. Select your app project
3. Go to **Project Settings**
4. Download the new `agconnect-services.json`
5. Copy to `android/app/agconnect-services.json` (NOT committed to git)

### 2. Add Credentials to Your Local Environment

**Do NOT commit any of these files!**

```bash
# Copy example files locally (one-time setup)
cp android/app/google-services.json.example android/app/google-services.json
cp android/app/agconnect-services.json.example android/app/agconnect-services.json

# Add your real credentials to the files above
# Replace all YOUR_* placeholders with actual values
```

### 3. Backend Configuration

Create `.env` file in `backend/` (not committed):

```bash
cp backend/.env.example backend/.env
```

Edit `backend/.env` and set your database credentials:

```env
DB_ENGINE=sqlite  # or mysql

# For MySQL:
DB_HOST=your-host
DB_PORT=3306
DB_NAME=estolo
DB_USER=your_user
DB_PASSWORD=your_secure_password
```

### 4. Development Setup

```bash
# Android app - Flutter will auto-detect google-services.json
flutter pub get

# Backend
cd backend
pip install -r requirements.txt
$env:DB_ENGINE="sqlite"
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

## Files to Never Commit

These are already in `.gitignore`:
- `google-services.json`
- `agconnect-services.json`
- `.env`
- `.env.local`
- `*.keystore`
- `*.jks`

## CI/CD Setup (GitHub Actions, etc.)

For automated deployments, add secrets to your CI/CD provider:

**GitHub Secrets:**
```
GOOGLE_SERVICES_JSON=<base64-encoded google-services.json>
AGCONNECT_SERVICES_JSON=<base64-encoded agconnect-services.json>
DB_PASSWORD=<production-password>
```

Encode file as base64:
```bash
base64 -i android/app/google-services.json
```

## Revoking Exposed Credentials

✅ **Already done** — the exposed credentials have been removed from the git history.

TODO for you:
1. ✅ Update `.gitignore` to exclude service files
2. ✅ Generate fresh API keys in Firebase
3. ✅ Generate fresh API keys in Huawei AppGallery
4. Add new credentials locally (NOT in git)
5. Update CI/CD secrets if using automated deployments

## Best Practices

- ✅ Use environment variables for all secrets
- ✅ Use `.env.example` to document required variables
- ✅ Use `.gitignore` to prevent committing secrets
- ✅ Use CI/CD secret managers for deployments
- ✅ Rotate credentials periodically
- ✅ Never commit credentials directly to code

## Resources

- [OWASP Secrets Management](https://owasp.org/www-community/Secrets_Management)
- [Flutter Security Best Practices](https://flutter.dev/docs/deployment/security)
- [Firebase Security](https://firebase.google.com/support/privacy-and-security)
