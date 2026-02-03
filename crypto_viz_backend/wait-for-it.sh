#!/bin/bash
# wait-for-it.sh: Wait for services to be ready before starting Django

set -e

TIMESCALE_HOST="${TIMESCALE_DB_HOST:-timescaledb}"
TIMESCALE_PORT="${TIMESCALE_DB_PORT:-5432}"
KAFKA_HOST="${KAFKA_HOST:-kafka}"
KAFKA_PORT="${KAFKA_PORT:-29092}"
REDIS_HOST="${REDIS_HOST:-redis}"
REDIS_PORT="${REDIS_PORT:-6379}"

echo "Waiting for TimescaleDB at $TIMESCALE_HOST:$TIMESCALE_PORT..."
while ! nc -z "$TIMESCALE_HOST" "$TIMESCALE_PORT" 2>/dev/null; do
    sleep 1
done
echo "✓ TimescaleDB is ready"

echo "Waiting for Kafka at $KAFKA_HOST:$KAFKA_PORT..."
while ! nc -z "$KAFKA_HOST" "$KAFKA_PORT" 2>/dev/null; do
    sleep 1
done
echo "✓ Kafka is ready"

echo "Waiting for Redis at $REDIS_HOST:$REDIS_PORT..."
while ! nc -z "$REDIS_HOST" "$REDIS_PORT" 2>/dev/null; do
    sleep 1
done
echo "✓ Redis is ready"

echo "All services are ready!"
sleep 5  # Extra buffer to ensure services are fully initialized
exec "$@"
