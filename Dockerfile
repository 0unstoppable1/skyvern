FROM mcr.microsoft.com/playwright/python:v1.40.0-jammy-python11

WORKDIR /app

# Install essential system dependencies
RUN apt-get update && apt-get install -y \
    git build-essential curl \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip tooling for stability
RUN pip install --upgrade pip setuptools wheel

# Install Skyvern from the stable PyPI package
RUN pip install skyvern

# Alternatively, install the latest from source:
# RUN pip install git+https://github.com/Skyvern-AI/skyvern.git

# Ensure Playwright has Chromium
RUN playwright install chromium

# Set up necessary directories with proper permissions
RUN mkdir -p /app/data /app/logs /app/skyvern/artifacts /tmp/chromium-cache \
    && chmod -R 755 /app/data /app/logs /app/skyvern/artifacts

# Environment setup
ENV PYTHONPATH=/app
ENV BROWSER_ARGS="--no-sandbox --disable-dev-shm-usage --disable-gpu"

# Use bindable volumes for persistence
VOLUME ["/app/data", "/app/logs", "/app/skyvern/artifacts"]

# Optional: healthcheck (make sure Skyvern serves this endpoint)
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Expose Skyvern’s ports
EXPOSE 8000 8080

# Default command to launch Skyvern
CMD ["skyvern", "run", "all"]
