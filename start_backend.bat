@echo off
echo Starting Insurance Premium Predictor Backend...
cd backend

if not exist "venv" (
    echo Creating virtual environment...
    python -m venv venv
)

call venv\Scripts\activate.bat

echo Installing dependencies...
pip install -r requirements.txt

if not exist "..\random_forest_regressor.pkl" (
    echo Warning: Model file not found!
    echo Please ensure random_forest_regressor.pkl exists in the project root.
)

echo Starting FastAPI server on http://localhost:8000
echo API docs available at http://localhost:8000/docs
python main.py

pause

