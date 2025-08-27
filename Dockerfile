FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    gnupg \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Clone Skyvern repository
RUN git clone https://github.com/Skyvern-AI/skyvern.git .

# Install Python dependencies
RUN pip install --no-cache-dir -e .

# Install Playwright and Chromium with dependencies
RUN playwright install chromium --with-deps

# Create necessary directories with proper permissions
RUN mkdir -p /app/data \
    /app/logs \
    /app/skyvern/artifacts \
    /tmp/chromium-cache \
    && chmod -R 755 /app/data /app/logs /app/skyvern/artifacts

# Set environment variables (no resource limits)
ENV PYTHONPATH=/app

# Browser optimization (no memory limits)
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
