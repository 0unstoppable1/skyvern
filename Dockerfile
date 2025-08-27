# Use Python 3.11 slim image as base
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies for Playwright and general build
RUN apt-get update && apt-get install -y \
    git curl wget unzip \
    fonts-liberation libatk1.0-0 libatk-bridge2.0-0 \
    libcups2 libdrm2 libxkbcommon0 libxcomposite1 libxdamage1 libxfixes3 \
    libxrandr2 libgbm1 libasound2 libpangocairo-1.0-0 libgtk-3-0 \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip and tooling
RUN pip install --upgrade pip setuptools wheel

# Install Playwright and Chromium
RUN pip install playwright && playwright install chromium

# Install Skyvern
RUN pip install skyvern

# Create necessary directories
RUN mkdir -p /app/data /app/logs /app/skyvern/artifacts /tmp/chromium-cache \
    && chmod -R 755 /app/data /app/logs /app/skyvern/artifacts

# Set environment variables
ENV PYTHONPATH=/app
ENV BROWSER_ARGS="--no-sandbox --disable-dev-shm-usage --disable-gpu"

# Expose the port required by Claw Cloud
EXPOSE 8000

# Healthcheck adjusted for 8080
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Mount persistent volumes
VOLUME ["/app/data", "/app/logs", "/app/skyvern/artifacts"]

# Start Skyvern on port 8080
CMD ["skyvern", "run", "all"]
