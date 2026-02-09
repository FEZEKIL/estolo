# Deploy Estolo Backend to Render

Render is a free hosting platform that makes it easy to deploy FastAPI applications. Follow this guide to get your backend live in minutes.

## Prerequisites

- GitHub repository with backend code pushed (or connect directly)
- [Render account](https://render.com) (sign up with GitHub for easier integration)
- Optional: MySQL database on Render or external provider (for production)

## Option 1: Deploy from GitHub (Recommended)

### 1. Connect GitHub to Render

1. Go to [dashboard.render.com](https://dashboard.render.com)
2. Click **"New +"** → **"Web Service"**
3. Select **"Connect a repository"** or **"Deploy an existing repository"**
4. Authorize GitHub (if not already connected)
5. Find and select your `estolo` repository

### 2. Configure Deployment

1. **Name:** `estolo-backend` (or your preferred name)
2. **Environment:** `Python 3`
3. **Region:** Select closest to your users
4. **Branch:** `main`
5. **Build Command:** Leave empty (Render detects `requirements.txt`)
6. **Start Command:** 
   ```
   python -m uvicorn main:app --host 0.0.0.0 --port $PORT
   ```
7. **Plan:** Free (for development)

### 3. Add Environment Variables

Under **"Environment"**, add:

```
DB_ENGINE=sqlite
```

For MySQL database (if using):
```
DB_ENGINE=mysql
DB_HOST=your-database-host
DB_PORT=3306
DB_NAME=estolo
DB_USER=estolo_user
DB_PASSWORD=your_secure_password
```

### 4. Deploy

Click **"Create Web Service"** and wait (2-5 minutes for first deploy).

Your API will be live at: `https://estolo-backend.onrender.com`

## Option 2: Using render.yaml (Infrastructure as Code)

If you prefer defining infrastructure in code:

1. The `render.yaml` file is already in the backend directory
2. Push to GitHub
3. In Render dashboard, connect the repo as above
4. Render automatically reads `render.yaml` for configuration

## Option 3: Deploy via Render CLI

```bash
# Install Render CLI
npm install -g @render-com/cli

# Login
render login

# Deploy from backend directory
cd backend
render deploy
```

## Database Setup for Production

### Option A: SQLite (Development Only)
- ✅ Works immediately, zero setup
- ❌ Data lost on each Render deployment
- Use for: Testing, development, demos

### Option B: MySQL on Render
1. In Render dashboard, create a **PostgreSQL** or **MySQL** database
2. Copy connection details
3. Update environment variables in your service
4. Restart the service

### Option C: External MySQL
Use AWS RDS, Google Cloud SQL, TaurusDB, or other providers:

1. Create MySQL database in your provider
2. Get connection string
3. Set environment variables in Render:
   ```
   DB_ENGINE=mysql
   DB_HOST=your-host
   DB_PORT=3306
   DB_NAME=estolo
   DB_USER=user
   DB_PASSWORD=password
   ```

## Post-Deployment

### 1. Test Your API

```bash
# Health check
curl https://estolo-backend.onrender.com/health

# API docs
https://estolo-backend.onrender.com/docs
```

### 2. View Logs

In Render dashboard:
- Click your service
- Go to **"Logs"** tab
- Watch real-time requests and errors

### 3. Set Up Auto-Deploy

Render automatically redeploys when you push to GitHub (if connected). To test:

```bash
# Make a code change
git add .
git commit -m "test deployment"
git push origin main

# Watch the deployment in Render dashboard
```

## Common Issues

### Build Fails with "ModuleNotFoundError"

**Solution:** Ensure `requirements.txt` is in the repo and includes all dependencies:
```bash
pip freeze > requirements.txt
git add requirements.txt
git push
```

### Port Already in Use

**Solution:** Always use the `$PORT` environment variable:
```
python -m uvicorn main:app --host 0.0.0.0 --port $PORT
```

### Database Connection Failed

- ✅ Check environment variables are set correctly in Render
- ✅ Test database credentials locally
- ✅ Ensure database server is running (if using external)

### Data Disappears After Deploy

**Cause:** You're using SQLite (file-based, ephemeral on Render)

**Solution:** Switch to MySQL option (see Database Setup section)

### Slow Cold Starts

**Cause:** Free tier instances shut down after inactivity

**Solution:** Upgrade to Paid tier or keep your app "warm" with periodic pings

## Environment Variables Security

**❌ DO NOT:**
- Put secrets directly in `render.yaml` or `Procfile`
- Commit `.env` file to GitHub

**✅ DO:**
- Set environment variables in Render dashboard
- Use `.env.example` to document required variables
- Rotate credentials if exposed

## Monitoring & Updates

### View Service Status
- Dashboard shows deployment status, resource usage, recent logs

### Auto-Rollback
- Render keeps the previous deployment; roll back if needed

### Manual Restart
Render dashboard → Service → **"Restart"** button

## Scaling (Paid Features)

For production traffic:
- Upgrade from Free → Paid tier
- Enable auto-scaling
- Add caching (Redis)
- Use MySQL instead of SQLite

## Custom Domain

1. In Render dashboard, go to **"Settings"**
2. Under **"Custom Domain"**, add your domain (e.g., `api.estolo.com`)
3. Update DNS records as instructed
4. Enable HTTPS (automatic)

## Troubleshooting

### See Real-Time Logs
```
# Render dashboard → Service → Logs (watch live)
```

### SSH into Service (Paid tier only)
```
# Render dashboard → Service → "Shell"
```

### Check Python Version
```
python --version
```

(Should be 3.11.7 as per `runtime.txt`)

## Next Steps

1. ✅ Deploy backend to Render
2. ✅ Test API endpoints at `https://your-service.onrender.com`
3. Update Flutter app to point to your Render API endpoint
4. Set up MySQL database for persistent data (optional for production)
5. Configure custom domain (optional)

## Useful Links

- [Render Docs](https://render.com/docs)
- [Render Python Guide](https://render.com/docs/deploy-python)
- [FastAPI on Render](https://render.com/docs/deploy-python#fastapi)
- [Environment Variables](https://render.com/docs/environment-variables)

## Support

For Render-specific issues:
- Check [Render Status Page](https://status.render.com)
- Read [Render Docs](https://render.com/docs)
- Create [GitHub issue](../../issues) for code-related problems
