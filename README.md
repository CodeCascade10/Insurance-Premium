# Insurance Premium Predictor 🛡️

A modern, full-stack web application for predicting insurance premiums using Machine Learning. Built with FastAPI backend and React frontend.

## Features

- 🎨 **Modern UI**: Beautiful, responsive design with smooth animations
- 🚀 **Fast API**: FastAPI backend with automatic API documentation
- 🤖 **ML Model**: Random Forest Regression model (R² Score: 0.8819)
- 📱 **Responsive**: Works seamlessly on desktop, tablet, and mobile devices
- ⚡ **Real-time Predictions**: Instant premium estimates

## Tech Stack

### Backend
- **FastAPI** - Modern, fast web framework for building APIs
- **scikit-learn** - Machine learning library
- **joblib** - Model serialization
- **Pydantic** - Data validation

### Frontend
- **Vanilla HTML/CSS/JavaScript** - Simple, lightweight, no build tools needed

## Project Structure

```
Insurance_project/
├── backend/
│   ├── main.py              # FastAPI application
│   └── requirements.txt     # Python dependencies
├── index.html               # Simple HTML frontend (single file!)
├── random_forest_regressor.pkl  # Trained ML model
├── insurance.csv           # Dataset
└── README.md
```

## Quick Start 🚀

### Easiest Way (One Command)

```bash
./start.sh
```

This will start both backend and frontend automatically. Then open your browser to:
- **Frontend UI**: http://localhost:8080
- **Backend API**: http://localhost:8000
- **API Docs**: http://localhost:8000/docs

---

## Manual Setup

### Prerequisites

- Python 3.8+ 
- The trained model file: `random_forest_regressor.pkl`

### Step 1: Start Backend

Open a terminal and run:

```bash
cd backend
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
python main.py
```

The backend will start at `http://localhost:8000`

### Step 2: Start Frontend

Open another terminal and run:

```bash
cd /home/kausik/Desktop/Insurance_project
python3 -m http.server 8080
```

Then open your browser to: **http://localhost:8080**

**OR** simply double-click `index.html` to open it directly in your browser (backend must be running first).

## Usage

1. Start both backend and frontend servers
2. Open your browser and navigate to `http://localhost:3000`
3. Fill in the form with your details:
   - Age (18-100)
   - Gender (Male/Female)
   - BMI (Body Mass Index)
   - Number of children
   - Smoking status
   - Region
4. Click "Predict Premium" to get an instant estimate
5. View your predicted premium amount

## API Endpoints

### POST `/predict`
Predict insurance premium based on input features.

**Request Body:**
```json
{
  "age": 40,
  "sex": "male",
  "bmi": 25.5,
  "children": 2,
  "smoker": "no",
  "region": "northeast"
}
```

**Response:**
```json
{
  "predicted_premium": 12345.67,
  "input_data": {
    "age": 40,
    "sex": "male",
    "bmi": 25.5,
    "children": 2,
    "smoker": "no",
    "region": "northeast"
  }
}
```

### GET `/health`
Check API health status.

### GET `/`
Get API information and available endpoints.

## Model Details

- **Algorithm**: Random Forest Regressor
- **R² Score**: 0.8819
- **RMSE**: 4658.57
- **Features**: Age, Sex, BMI, Children, Smoking Status, Region
- **Target**: Insurance Premium (expenses)

## Development

### Running in Production

**Backend:**
```bash
uvicorn backend.main:app --host 0.0.0.0 --port 8000
```

**Frontend:**
```bash
cd frontend
npm run build
# Serve the build folder using a static file server
```

## Deploy to Vercel 🚀

This project is ready to deploy on Vercel!

### Quick Deploy

1. **Push to GitHub** (if not already):
   ```bash
   git init
   git add .
   git commit -m "Ready for Vercel"
   git remote add origin <your-repo-url>
   git push
   ```

2. **Deploy on Vercel**:
   - Go to https://vercel.com/new
   - Import your GitHub repository
   - Click "Deploy" (settings are auto-detected)

3. **Done!** Your app will be live at `https://your-project.vercel.app`

See `VERCEL_DEPLOY.md` for detailed deployment instructions.

### Project Structure for Vercel
- `api/index.py` - Serverless function (FastAPI)
- `index.html` - Frontend (auto-served)
- `vercel.json` - Vercel configuration
- `random_forest_regressor.pkl` - Model file (9.3MB, within limits)

## License

This project is open source and available for educational purposes.

## Contributing

Feel free to submit issues and enhancement requests!

# Insurance-Premium
