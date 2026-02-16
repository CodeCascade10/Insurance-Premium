from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import joblib
import numpy as np
import os

# Initialize FastAPI app
app = FastAPI(
    title="Insurance Premium Predictor API",
    description="API for predicting insurance premiums using Random Forest Regression",
    version="1.0.0"
)

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify your frontend URL
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load the trained model
model_path = os.path.join(os.path.dirname(__file__), "..", "random_forest_regressor.pkl")
try:
    model = joblib.load(model_path)
except FileNotFoundError:
    model = None
    print(f"Warning: Model file not found at {model_path}")

# Request model
class InsuranceInput(BaseModel):
    age: int = Field(..., ge=18, le=100, description="Age of the person")
    sex: str = Field(..., description="Gender: 'male' or 'female'")
    bmi: float = Field(..., ge=10, le=60, description="Body Mass Index")
    children: int = Field(..., ge=0, le=10, description="Number of children")
    smoker: str = Field(..., description="Smoking status: 'yes' or 'no'")
    region: str = Field(..., description="Region: 'southwest', 'southeast', 'northwest', or 'northeast'")

# Response model
class PredictionResponse(BaseModel):
    predicted_premium: float
    input_data: dict

@app.get("/")
async def root():
    return {
        "message": "Insurance Premium Predictor API",
        "status": "running",
        "endpoints": {
            "predict": "/predict",
            "health": "/health",
            "docs": "/docs"
        }
    }

@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "model_loaded": model is not None
    }

@app.post("/predict", response_model=PredictionResponse)
async def predict_premium(input_data: InsuranceInput):
    """
    Predict insurance premium based on input features
    """
    if model is None:
        raise HTTPException(status_code=503, detail="Model not loaded. Please ensure the model file exists.")
    
    try:
        # Map categorical variables to numeric (matching training data encoding)
        sex_map = {'female': 0, 'male': 1}
        smoker_map = {'no': 0, 'yes': 1}
        region_map = {
            'southwest': 1,
            'southeast': 2,
            'northwest': 3,
            'northeast': 4
        }
        
        # Convert input to model format
        features = np.array([[
            input_data.age,
            sex_map.get(input_data.sex.lower(), 0),
            input_data.bmi,
            input_data.children,
            smoker_map.get(input_data.smoker.lower(), 0),
            region_map.get(input_data.region.lower(), 1)
        ]])
        
        # Make prediction
        prediction = model.predict(features)[0]
        
        return PredictionResponse(
            predicted_premium=round(float(prediction), 2),
            input_data=input_data.dict()
        )
    
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Prediction error: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

