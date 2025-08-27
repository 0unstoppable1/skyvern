FROM mcr.microsoft.com/playwright/python:v1.40.0-jammy

WORKDIR /app

# Install additional system dependencies
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Clone Skyvern repository
RUN git clone https://github.com/Skyvern-AI/skyvern.git .

# Upgrade pip first
RUN pip install --upgrade pip

# Install skyvern directly from PyPI (most reliable approach)
RUN pip install skyvern-automate

# Alternatively, if you need the latest from source, use this instead:
# RUN pip install git+https://github.com/Skyvern-AI/skyvern.git

# Playwright is already installed in this base image
# Just ensure chromium is available
RUN playwright install chromium

# Create necessary directories with proper permissions
RUN mkdir -p /app/data \
    /app/logs \
    /app/skyvern/artifacts \
    /tmp/chromium-cache \
    && chmod -R 755 /app/data /app/logs /app/skyvern/artifacts

# Set environment variables
ENV PYTHONPATH=/app

# Browser optimization
ENV BROWSER_ARGS="--no-sandbox --disable-dev-shm-usage --disable-gpu"

# Set up volumes for persistent data
VOLUME ["/app/data", "/app/logs", "/app/skyvern/artifacts"]

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Expose ports
EXPOSE 8000 8080

# Start Skyvern
CMD ["skyvern", "run", "all"]
