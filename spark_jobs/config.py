"""
Configuration pour les jobs Spark Structured Streaming.
"""
import os

# Kafka Configuration (Local Docker)
KAFKA_BOOTSTRAP_SERVERS = os.environ.get('KAFKA_SERVERS', 'localhost:9092')
KAFKA_TOPICS = {
    'TICKER': 'rawticker',
    'TRADE': 'rawtrade',
    'ARTICLE': 'rawarticle',
    'ALERT': 'rawalert',
}

# TimescaleDB Configuration
TIMESCALE_CONFIG = {
    'host': 'localhost',
    'port': '15432', 
    'database': 'crypto_viz_ts',
    'user': 'postgres',
    'password': '',
}

# JDBC URL pour TimescaleDB (PostgreSQL)
TIMESCALE_JDBC_URL = f"jdbc:postgresql://{TIMESCALE_CONFIG['host']}:{TIMESCALE_CONFIG['port']}/{TIMESCALE_CONFIG['database']}"

# Spark Configuration
SPARK_APP_NAME = "CRYPTO_VIZ_Streaming"
SPARK_MASTER = os.environ.get('SPARK_MASTER', 'local[*]')

# Checkpointing
CHECKPOINT_LOCATION = os.environ.get('CHECKPOINT_LOCATION', '/tmp/spark_checkpoints')
