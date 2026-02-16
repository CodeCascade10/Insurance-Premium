# Deploying to Vercel

This guide will help you deploy your Insurance Premium Predictor to Vercel.

## Prerequisites

1. A Vercel account (sign up at https://vercel.com)
2. Vercel CLI installed (optional, but recommended):
   ```bash
   npm install -g vercel
   ```

## Deployment Steps

### Option 1: Using Vercel Dashboard (Easiest)

1. **Push your code to GitHub/GitLab/Bitbucket**
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin <your-repo-url>
   git push -u origin main
   ```

2. **Import Project on Vercel**
   - Go to https://vercel.com/new
   - Import your Git repository
   - Vercel will auto-detect the settings

3. **Configure Build Settings**
   - Framework Preset: **Other**
   - Root Directory: `.` (project root)
   - Build Command: Leave empty
   - Output Directory: Leave empty
   - Install Command: Leave empty

4. **Add Environment Variables** (if needed)
   - None required for this project

5. **Deploy!**
   - Click "Deploy"
   - Wait for deployment to complete

### Option 2: Using Vercel CLI

1. **Install Vercel CLI** (if not already installed)
   ```bash
   npm install -g vercel
   ```

2. **Login to Vercel**
   ```bash
   vercel login
   ```

3. **Deploy**
   ```bash
   vercel
   ```
   
   Follow the prompts:
   - Set up and deploy? **Yes**
   - Which scope? (Select your account)
   - Link to existing project? **No**
   - Project name? (Press Enter for default)
   - Directory? (Press Enter for current directory)

4. **For Production Deployment**
   ```bash
   vercel --prod
   ```

## Important Notes

### Model File Size
- Vercel has a 50MB limit for serverless functions
- If your `random_forest_regressor.pkl` file is larger than 50MB, consider:
  - Using a smaller model
  - Storing the model in cloud storage (S3, Cloudinary) and loading it at runtime
  - Using Vercel's Pro plan which has higher limits

### File Structure
Make sure your project structure looks like this:
```
Insurance_project/
├── api/
│   ├── index.py          # Serverless function
│   └── requirements.txt  # Python dependencies
├── index.html            # Frontend
├── random_forest_regressor.pkl  # Model file (must be < 50MB)
├── vercel.json           # Vercel configuration
└── .vercelignore         # Files to exclude
```

### API Endpoints
After deployment, your API will be available at:
- `https://your-project.vercel.app/api/predict`
- `https://your-project.vercel.app/api/health`

The frontend will automatically use `/api` when deployed on Vercel.

## Troubleshooting

### Model Not Found Error
If you get "Model not loaded" errors:
1. Ensure `random_forest_regressor.pkl` is in the project root
2. Check that the file is not in `.vercelignore`
3. Verify file size is under 50MB

### Build Errors
- Check that all dependencies are in `api/requirements.txt`
- Ensure Python 3.9+ is selected in Vercel settings
- Check build logs in Vercel dashboard

### CORS Issues
- The API already has CORS enabled for all origins
- If issues persist, check browser console for specific errors

## Updating Your Deployment

After making changes:
```bash
git add .
git commit -m "Update code"
git push
```

Vercel will automatically redeploy on push to your main branch.

Or manually:
```bash
vercel --prod
```

## Custom Domain

To add a custom domain:
1. Go to your project settings on Vercel
2. Navigate to "Domains"
3. Add your custom domain
4. Follow DNS configuration instructions

