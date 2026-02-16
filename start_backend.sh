#!/bin/bash

# Start Backend Server
echo "🚀 Starting Insurance Premium Predictor Backend..."
cd backend

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

# Install dependencies
echo "📥 Installing dependencies..."
pip install -r requirements.txt

# Check if model file exists
if [ ! -f "../random_forest_regressor.pkl" ]; then
    echo "⚠️  Warning: Model file not found!"
    echo "Please ensure random_forest_regressor.pkl exists in the project root."
fi

# Start server
echo "✅ Starting FastAPI server on http://localhost:8000"
echo "📚 API docs available at http://localhost:8000/docs"
python main.py

