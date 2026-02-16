#!/bin/bash

echo "🚀 Starting Insurance Premium Predictor..."
echo ""

# Check if backend is already running
if curl -s http://localhost:8000/health > /dev/null 2>&1; then
    echo "✅ Backend is already running on http://localhost:8000"
else
    echo "📦 Starting backend server..."
    cd backend
    
    # Check if venv exists
    if [ ! -d "venv" ]; then
        echo "Creating virtual environment..."
        python3 -m venv venv
    fi
    
    source venv/bin/activate
    
    # Install dependencies if needed
    if ! python -c "import fastapi" 2>/dev/null; then
        echo "Installing dependencies..."
        pip install -q -r requirements.txt
    fi
    
    # Start backend in background
    python main.py &
    BACKEND_PID=$!
    echo "✅ Backend started (PID: $BACKEND_PID)"
    echo "   API: http://localhost:8000"
    echo "   Docs: http://localhost:8000/docs"
    cd ..
    
    # Wait for backend to be ready
    echo "Waiting for backend to be ready..."
    for i in {1..10}; do
        if curl -s http://localhost:8000/health > /dev/null 2>&1; then
            echo "✅ Backend is ready!"
            break
        fi
        sleep 1
    done
fi

echo ""
echo "🌐 Starting frontend server..."
cd "$(dirname "$0")"

# Check if port 8080 is already in use
if lsof -Pi :8080 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "✅ Frontend server already running on http://localhost:8080"
else
    python3 -m http.server 8080 &
    FRONTEND_PID=$!
    echo "✅ Frontend started (PID: $FRONTEND_PID)"
    echo "   UI: http://localhost:8080"
fi

echo ""
echo "═══════════════════════════════════════════════════════"
echo "🎉 Application is running!"
echo ""
echo "   Frontend: http://localhost:8080"
echo "   Backend API: http://localhost:8000"
echo "   API Docs: http://localhost:8000/docs"
echo ""
echo "Press Ctrl+C to stop all servers"
echo "═══════════════════════════════════════════════════════"
echo ""

# Wait for user interrupt
wait

