# PowerShell script to generate expert system visualizations
# Run this script to create all graph representations

Write-Host "🎨 Expert System Graph Generator" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

# Check if Python is installed
try {
    $pythonVersion = python --version 2>&1
    Write-Host "✅ Python found: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Python not found. Please install Python first." -ForegroundColor Red
    exit 1
}

Write-Host "`n📦 Installing required Python packages..." -ForegroundColor Yellow

# Install required packages
$packages = @("networkx", "matplotlib", "numpy")

foreach ($package in $packages) {
    Write-Host "Installing $package..." -ForegroundColor White
    try {
        pip install $package --quiet
        Write-Host "✅ $package installed successfully" -ForegroundColor Green
    } catch {
        Write-Host "❌ Failed to install $package" -ForegroundColor Red
    }
}

Write-Host "`n🎯 Generating visualizations..." -ForegroundColor Yellow

# Run the Python visualization script
try {
    python visualize_expert_system.py
    Write-Host "✅ Python visualizations generated successfully!" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to generate Python visualizations" -ForegroundColor Red
}

# Check if Graphviz is available
Write-Host "`n🔍 Checking for Graphviz..." -ForegroundColor Yellow
try {
    $dotVersion = dot -V 2>&1
    Write-Host "✅ Graphviz found: $dotVersion" -ForegroundColor Green
    
    Write-Host "🎨 Generating DOT graph..." -ForegroundColor White
    dot -Tpng expert_system.dot -o expert_system_architecture.png
    dot -Tsvg expert_system.dot -o expert_system_architecture.svg
    Write-Host "✅ DOT graphs generated successfully!" -ForegroundColor Green
    
} catch {
    Write-Host "⚠️  Graphviz not found. Install from: https://graphviz.org/download/" -ForegroundColor Yellow
    Write-Host "   You can still use the DOT file with online Graphviz tools" -ForegroundColor White
}

# Open the interactive HTML file
Write-Host "`n🌐 Opening interactive visualization..." -ForegroundColor Yellow
try {
    Start-Process "expert_system_interactive.html"
    Write-Host "✅ Interactive HTML opened in browser!" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Could not open HTML file automatically" -ForegroundColor Yellow
    Write-Host "   Please open 'expert_system_interactive.html' manually" -ForegroundColor White
}

Write-Host "`n📁 Generated Files:" -ForegroundColor Cyan
Write-Host "==================" -ForegroundColor Cyan

$files = @(
    "visualize_expert_system.py",
    "expert_system.dot", 
    "expert_system_interactive.html",
    "rule_dependency_graph.png",
    "knowledge_base_graph.png",
    "decision_tree_graph.png", 
    "confidence_network.png",
    "expert_system_architecture.png",
    "expert_system_architecture.svg"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "✅ $file" -ForegroundColor Green
    } else {
        Write-Host "❌ $file (not generated)" -ForegroundColor Red
    }
}

Write-Host "`n🎉 Graph generation complete!" -ForegroundColor Green
Write-Host "`n📋 Usage Instructions:" -ForegroundColor Cyan
Write-Host "=====================" -ForegroundColor Cyan
Write-Host "1. PNG files - Static high-quality images for reports" -ForegroundColor White
Write-Host "2. HTML file - Interactive visualization (open in browser)" -ForegroundColor White
Write-Host "3. DOT file - Edit and regenerate with Graphviz" -ForegroundColor White  
Write-Host "4. Python script - Customize and regenerate graphs" -ForegroundColor White

Read-Host "`nPress Enter to exit"
