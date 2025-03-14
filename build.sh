#!/bin/bash

# Exit on errors and print each command before executing
set -ex

# Debugging: Print working directory
pwd

# **Fix: Ensure Flutter is installed using a pre-built release (instead of Git clone)**
if [ ! -d "flutter" ]; then
  echo "Flutter not found. Downloading official Flutter 3.29.0..."
  curl -fsSL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.29.0-stable.tar.xz | tar -xJ
fi

# Set Flutter path
export PATH="$PATH:`pwd`/flutter/bin"

# Debugging: Verify Flutter installation
flutter doctor || { echo "Flutter installation failed"; exit 1; }

# **Fix: Explicitly set Flutter version to avoid "0.0.0-unknown" error**
flutter --version || { echo "Flutter version issue"; exit 1; }

# Install dependencies
flutter pub get || { echo "Flutter package install failed"; exit 1; }

# Enable web support
flutter config --enable-web || { echo "Failed to enable web support"; exit 1; }

# Build Flutter Web
flutter build web --release || { echo "Flutter build failed"; exit 1; }

# Ensure old 'public/' directory is removed before moving the new build
rm -rf public || { echo "Failed to remove old public directory"; exit 1; }
mv build/web public || { echo "Failed to move build/web to public"; exit 1; }

# Debugging: List files in 'public' to ensure the move was successful
ls -la public/ || { echo "Failed to list public directory"; exit 1; }
