# Flutter Test Runner Script
# Run this script to test the dark mode functionality

Write-Host "🧪 Running Flutter Tests for Dark Mode Toggle..." -ForegroundColor Cyan

# Get dependencies first
Write-Host "📦 Getting dependencies..." -ForegroundColor Yellow
flutter pub get

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Dependencies installed successfully" -ForegroundColor Green
    
    # Run tests
    Write-Host "🔍 Running widget tests..." -ForegroundColor Yellow
    flutter test
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ All tests passed!" -ForegroundColor Green
        Write-Host "🎉 Dark mode toggle is working correctly!" -ForegroundColor Magenta
    } else {
        Write-Host "❌ Some tests failed. Check the output above." -ForegroundColor Red
    }
} else {
    Write-Host "❌ Failed to get dependencies. Make sure Flutter is installed." -ForegroundColor Red
}

Write-Host "`n🚀 To run the app:" -ForegroundColor Cyan
Write-Host "flutter run" -ForegroundColor White
