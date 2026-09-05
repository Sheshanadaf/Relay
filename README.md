# Relay

Relay is a small dispatch product used as a **DevOps portfolio**. The goal is not a list of logos. It is one system you can take from git to a running stack, then keep adding how a company actually ships and operates software.

**Who:** Sheshan Hebron — AWS-focused, building the Docker / Kubernetes / CI / IaC side in public.

## What Relay does

A browser talks to nginx. nginx proxies to a FastAPI API. The API queues work on Redis. A worker pulls jobs. Postgres holds data. `/health` is process liveness. `/ready` checks dependencies.

## Where it is today

**Module 1 (this folder): Docker Compose on a laptop.**

- Images built from Dockerfiles (layers, non-root user)
- Compose network DNS (`api`, `postgres`, `redis`, `web`, `worker`)
- Reverse proxy, queue, probes

```bash
docker compose up --build
