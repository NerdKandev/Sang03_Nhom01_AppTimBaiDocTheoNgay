#!/bin/bash

# Setup Git branches for different teams
echo "🚀 Setting up Git branches for different teams..."

# Create branches for each team
echo "📝 Creating branches..."

# UI/Theme team
git checkout -b feature/ui-theme
echo "✅ Created feature/ui-theme branch"

# Admin Panel team  
git checkout -b feature/admin-panel
echo "✅ Created feature/admin-panel branch"

# User Features team
git checkout -b feature/user-features
echo "✅ Created feature/user-features branch"

# TTS/Schedule team
git checkout -b feature/tts-schedule
echo "✅ Created feature/tts-schedule branch"

# Return to main branch
git checkout main
echo "✅ Returned to main branch"

echo ""
echo "🎯 Branches created successfully!"
echo "📋 Available branches:"
git branch -a

echo ""
echo "📖 Instructions for teams:"
echo "1. UI/Theme team: git checkout feature/ui-theme"
echo "2. Admin Panel team: git checkout feature/admin-panel"  
echo "3. User Features team: git checkout feature/user-features"
echo "4. TTS/Schedule team: git checkout feature/tts-schedule"
echo ""
echo "🚀 Ready for development!"
