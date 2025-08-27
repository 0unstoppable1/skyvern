FROM python:3.11-slim

WORKDIR /app

# Install system dependencies required for Playwright Chromium
RUN apt-get update && apt-get install -y \
    git curl wget unzip \
    fonts-liberation libatk1.0-0 libatk-bridge2.0-0 \
    libcups2 libdrm2 libxkbcommon0 libxcomposite1 libxdamage1 libxfixes3 \
    libxrandr2 libgbm1 libasound2 libpangocairo-1.0-0 libgtk-3-0 \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip tooling
RUN pip install --upgrade pip setuptools wheel

# Install Playwright and Chromium
RUN pip install playwright && playwright install chromium

# Install Skyvern from PyPI
RUN pip install skyvern

# Create required directories
RUN mkdir -p /app/data /app/logs /app/skyvern/artifacts /tmp/chromium-cache \
    && chmod -R 755 /app/data /app/logs /app/skyvern/artifacts

# Environment setup
ENV PYTHONPATH=/app
ENV BROWSER_ARGS="--no-sandbox --disable-dev-shm-usage --disable-gpu"

# Volumes
VOLUME ["/app/data", "/app/logs", "/app/skyvern/artifacts"]

# Optional healthcheck (adjust if Skyvern doesn’t expose /health)
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Ports
EXPOSE 8000 8080

# Start Skyvern
CMD ["skyvern", "run", "all"]
