# Use the official Flutter Docker image
FROM cirrusci/flutter:3.29.0

# Set working directory inside the container
WORKDIR /app

# Copy project files to the container
COPY . .

# Install dependencies
RUN flutter pub get

# Enable web support
RUN flutter config --enable-web

# Build the Flutter web app
RUN flutter build web --release

# Move the built web app to Vercel's output directory
RUN mkdir -p /vercel/output && cp -r build/web/* /vercel/output

# Set the default command (for debugging)
CMD ["ls", "-la", "/vercel/output"]
