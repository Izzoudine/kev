# Multi-stage build pour optimiser la taille de l'image
# Stage 1: Build dependencies
FROM python:3.11-alpine AS builder

# Install build dependencies
RUN apk add --no-cache \
    gcc \
    musl-dev \
    postgresql-dev \
    libffi-dev \
    openssl-dev \
    python3-dev

# Create virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Stage 2: Runtime image
FROM python:3.11-alpine AS runtime

# Security: Create non-root user
RUN addgroup -g 1000 -S appgroup && \
    adduser -u 1000 -S appuser -G appgroup

# Install runtime dependencies only
RUN apk add --no-cache \
    postgresql-client \
    libpq \
    curl \
    netcat-openbsd

# Copy virtual environment from builder
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONFAULTHANDLER=1

# Set working directory
WORKDIR /app

# Copy application code
COPY . .

# Create wait script, make executable, and set ownership properly
RUN echo '#!/bin/sh' > /app/wait-for-it.sh && \
    echo 'set -e' >> /app/wait-for-it.sh && \
    echo 'TIMESCALE_HOST="${TIMESCALE_DB_HOST:-timescaledb}"' >> /app/wait-for-it.sh && \
    echo 'TIMESCALE_PORT="${TIMESCALE_DB_PORT:-5432}"' >> /app/wait-for-it.sh && \
    echo 'KAFKA_HOST="${KAFKA_HOST:-kafka}"' >> /app/wait-for-it.sh && \
    echo 'KAFKA_PORT="${KAFKA_PORT:-29092}"' >> /app/wait-for-it.sh && \
    echo 'REDIS_HOST="${REDIS_HOST:-redis}"' >> /app/wait-for-it.sh && \
    echo 'REDIS_PORT="${REDIS_PORT:-6379}"' >> /app/wait-for-it.sh && \
    echo '' >> /app/wait-for-it.sh && \
    echo 'echo "Waiting for TimescaleDB..."' >> /app/wait-for-it.sh && \
    echo 'while ! nc -z "$TIMESCALE_HOST" "$TIMESCALE_PORT" 2>/dev/null; do sleep 1; done' >> /app/wait-for-it.sh && \
    echo 'echo "✓ TimescaleDB is ready"' >> /app/wait-for-it.sh && \
    echo '' >> /app/wait-for-it.sh && \
    echo 'echo "Waiting for Kafka..."' >> /app/wait-for-it.sh && \
    echo 'while ! nc -z "$KAFKA_HOST" "$KAFKA_PORT" 2>/dev/null; do sleep 1; done' >> /app/wait-for-it.sh && \
    echo 'echo "✓ Kafka is ready"' >> /app/wait-for-it.sh && \
    echo '' >> /app/wait-for-it.sh && \
    echo 'echo "Waiting for Redis..."' >> /app/wait-for-it.sh && \
    echo 'while ! nc -z "$REDIS_HOST" "$REDIS_PORT" 2>/dev/null; do sleep 1; done' >> /app/wait-for-it.sh && \
    echo 'echo "✓ Redis is ready"' >> /app/wait-for-it.sh && \
    echo 'sleep 5' >> /app/wait-for-it.sh && \
    echo 'exec "$@"' >> /app/wait-for-it.sh && \
    chmod +x /app/wait-for-it.sh && \
    mkdir -p /app/staticfiles && \
    chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 8000

# Run gunicorn with optimized settings
CMD ["gunicorn", "crypto_viz.wsgi:application", "--bind", "0.0.0.0:8000", "--workers", "2", "--threads", "4", "--worker-class", "gthread", "--worker-tmp-dir", "/dev/shm", "--log-level", "info", "--access-logfile", "-", "--error-logfile", "-"]
