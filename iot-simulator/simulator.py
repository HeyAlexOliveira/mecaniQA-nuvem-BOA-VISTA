import os
import random
import time
from datetime import datetime

from prometheus_client import Counter, Gauge, Histogram, start_http_server

METRICS_PORT = int(os.getenv("METRICS_PORT", "8000"))
BASE_RATE = float(os.getenv("BASE_RATE", "5"))
PEAK_MULTIPLIER = float(os.getenv("PEAK_MULTIPLIER", "10"))
FORCE_PEAK = os.getenv("FORCE_PEAK", "false").lower() == "true"
WORKSHOPS = ["oficina-centro", "oficina-norte", "oficina-sul"]

SENSORS = {
    "engine_temperature": (70.0, 120.0),
    "battery_voltage": (11.0, 14.8),
    "oil_pressure": (20.0, 80.0),
}

READINGS = Counter(
    "mecaniqa_sensor_readings_total",
    "Total de leituras de sensores recebidas",
    ["sensor_type", "workshop"],
)

ERRORS = Counter(
    "mecaniqa_sensor_errors_total",
    "Total de falhas de leitura",
    ["sensor_type", "workshop"],
)

LAST_VALUE = Gauge(
    "mecaniqa_sensor_last_value",
    "Ultimo valor lido por sensor",
    ["sensor_type", "workshop"],
)

PROCESSING = Histogram(
    "mecaniqa_reading_processing_seconds",
    "Tempo de processamento de cada leitura",
    buckets=(0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1.0),
)

PEAK_ACTIVE = Gauge(
    "mecaniqa_peak_window_active",
    "1 se estamos na janela de pico, 0 caso contrario",
)

CURRENT_RATE = Gauge(
    "mecaniqa_simulated_rate_per_second",
    "Taxa atual de leituras simuladas por segundo",
)


def is_peak():
    if FORCE_PEAK:
        return True
    now = datetime.now()
    return now.hour in (8, 17) and now.minute < 30


def process_reading(sensor, workshop):
    lo, hi = SENSORS[sensor]

    with PROCESSING.time():
        value = random.uniform(lo, hi)

        time.sleep(
            random.uniform(
                0.001,
                0.03 if is_peak() else 0.01
            )
        )

        if random.random() < (0.05 if is_peak() else 0.01):
            ERRORS.labels(sensor, workshop).inc()
            return

        READINGS.labels(sensor, workshop).inc()
        LAST_VALUE.labels(sensor, workshop).set(value)


def main():
    start_http_server(METRICS_PORT)

    print(
        f"[iot-simulator] metricas em :{METRICS_PORT}/metrics",
        flush=True
    )

    while True:
        peak = is_peak()

        rate = BASE_RATE * (
            PEAK_MULTIPLIER if peak else 1
        )

        PEAK_ACTIVE.set(1 if peak else 0)
        CURRENT_RATE.set(rate)

        start = time.time()

        for _ in range(int(rate)):
            process_reading(
                random.choice(list(SENSORS)),
                random.choice(WORKSHOPS)
            )

        time.sleep(
            max(
                0,
                1 - (time.time() - start)
            )
        )


if __name__ == "__main__":
    main()