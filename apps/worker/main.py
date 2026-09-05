import os
import time

import redis

REDIS_URL = os.environ["REDIS_URL"]
QUEUE = "relay:jobs"

r = redis.Redis.from_url(REDIS_URL)

print("worker waiting for jobs", flush=True)

while True:
    item = r.brpop(QUEUE, timeout=5)
    if item is None:
        continue
    _queue_name, payload = item
    print("got job:", payload.decode(), flush=True)
    time.sleep(0.1)