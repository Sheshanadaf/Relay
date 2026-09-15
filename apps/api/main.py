import os

import psycopg
import redis
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

from prometheus_client import CONTENT_TYPE_LATEST, Counter, generate_latest
from fastapi.responses import Response

jobs_queued = Counter("relay_jobs_queued_total", "Jobs accepted onto the Redis queue")

app = FastAPI()

DATABASE_URL = os.environ["DATABASE_URL"]
REDIS_URL = os.environ["REDIS_URL"]
QUEUE = "relay:jobs"

r = redis.Redis.from_url(REDIS_URL)


class JobIn(BaseModel):
    message: str


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/ready")
def ready():
    try:
        with psycopg.connect(DATABASE_URL) as conn:
            conn.execute("SELECT 1")
        r.ping()
    except Exception as exc:
        raise HTTPException(status_code=503, detail=str(exc)) from exc
    return {"status": "ready"}


@app.post("/jobs")
def create_job(body: JobIn):
    r.lpush(QUEUE, body.message)
    jobs_queued.inc()
    return {"queued": True, "message": body.message}

@app.get("/metrics")
def metrics():
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)