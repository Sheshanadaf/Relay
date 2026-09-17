# Relay

Relay is a small **dispatch** product: a web page sends a message to an API, the API puts a job on **Redis**, a **worker** prints it. **Postgres** is there so the API can say it is really ready, not only “the process started.”

This repo is the public evidence of how that system is built and operated: Docker, GitHub Actions, Kubernetes on **kind**, Helm, Argo CD, Terraform on AWS, and a small Prometheus + Grafana path.

It is **not** a Kubernetes tutorial dump. Tools that do not run this product (Jenkins, Ansible, a bastion host) are out of the repo on purpose.

## Architecture (what runs today)

```
browser → Ingress (nginx) → web → API → Redis list relay:jobs → worker
                              ↓
                           Postgres (readiness)
```

**GitOps:** GitHub `main` holds `charts/relay`. Argo CD in the cluster watches that path and applies it into namespace `relay`.

**CI:** GitHub Actions builds Compose images and runs tests / a `/ready` check. CI does **not** `kubectl apply` the live app.

**Laptop cluster:** [kind](https://kind.sigs.k8s.io/) cluster `relay` (kubectl context `kind-relay`). Local images `relay-api`, `relay-worker`, `relay-web` must be loaded into kind (`kind load docker-image`). Argo CD does not copy Docker images.

**Metrics:** A **small** Prometheus in namespace `monitoring` scrapes `http://api.relay.svc.cluster.local:8080/metrics` (cluster DNS, not Ingress). Grafana graphs `relay_jobs_queued_total`. Alert `RelayApiDown` is Inactive while that scrape is UP. We did **not** keep kube-prometheus-stack on this node; it was too heavy next to the app.

## AWS (what exists today)

Terraform under `terraform/aws/` (region `ap-south-1`): lab VPC, public subnet, S3, remote state + lock. **No EKS in this revision.** EKS is the next slice (same git, images on ECR, Argo CD on the cluster).

Do not commit `*.tfstate`. Do not `terraform destroy` unless you intend to delete the lab.

## Layout

| Path | Role |
|---|---|
| `apps/api` | FastAPI: `/health`, `/ready`, `POST /jobs`, `/metrics` |
| `apps/worker` | Redis `brpop` on `relay:jobs` |
| `apps/web` | nginx; proxies `/health` `/ready` `/jobs` to the API (not `/metrics`) |
| `docker-compose.yml` | Local five-container run; only web publishes `8080:80` |
| `.github/workflows/ci.yml` | Build, pytest, Compose `/ready` |
| `charts/relay` | Helm chart Argo CD uses |
| `deploy/gitops/application.yaml` | Argo CD Application → namespace `relay` |
| `deploy/kubernetes/` | Raw YAML (how we learned; live path is Helm + Argo) |
| `deploy/observability/` | Small Prometheus + Grafana (`kubectl apply`, not the Relay Argo app) |
| `terraform/kind` | Tiny ConfigMap (Terraform + Kubernetes practice) |
| `terraform/aws` | Cheap AWS lab + remote state |

## Run with Compose

Needs Docker Desktop (Linux containers).

```bash
cd Relay
docker compose up -d --build
```

Open `http://127.0.0.1:8080` (not `0.0.0.0` in the browser).  
`/health` = process. `/ready` = Postgres and Redis. Queue a job from the page; worker logs show it.

`--build` after you change Dockerfiles or app code. `docker compose down` removes Compose containers **and** the Compose network (use this before kind if port 8080 fights).

API listen address `--host 0.0.0.0` is **inside** the container. The browser still uses `127.0.0.1`.

## Run on kind (GitOps)

1. Cluster `kind-relay` exists; Ingress nginx for kind is installed.
2. `docker compose down` if Compose still holds port 8080.
3. `docker compose build` then:

```bash
kind load docker-image relay-api:latest --name relay
kind load docker-image relay-worker:latest --name relay
kind load docker-image relay-web:latest --name relay
```

4. Argo CD Application (`deploy/gitops/application.yaml`) points at this repo, path `charts/relay`, destination namespace **`relay`**.
5. Port-forward Ingress (keep this terminal open):

```bash
kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80
```

Open `http://127.0.0.1:8080`. After app image changes: build, `kind load`, then `kubectl rollout restart deployment/api deployment/worker deployment/web -n relay` (tag `latest` often does not restart by itself).

Argo CD UI (optional): `kubectl port-forward svc/argocd-server -n argocd 8443:443` → `https://127.0.0.1:8443`.

## Metrics (optional)

```bash
kubectl apply -f deploy/observability/namespace.yaml
kubectl apply -f deploy/observability/prometheus.yaml
kubectl apply -f deploy/observability/grafana.yaml
kubectl -n monitoring port-forward svc/prometheus 9090:9090
kubectl -n monitoring port-forward svc/grafana 3001:3000
```

Prometheus: `http://127.0.0.1:9090` → Status → Targets → `relay-api` UP. Query `relay_jobs_queued_total`.  
Grafana: `http://127.0.0.1:3001` (admin / `relay-lab`) → Explore the same metric.

`/metrics` on the API is **not** on Ingress port 8080 (nginx does not proxy that path). Prometheus does not need it to; it scrapes the API Service inside the cluster.

## What this repo is not

- **Jenkins** — CI is GitHub Actions. A second CI would be noise.
- **Ansible** — no VM/bastion in this project. GitOps owns the cluster.
- **kube-prometheus-stack on kind** — tried; removed so the app stays healthy.

Those tools still belong in interviews. They will show up in a **later** repo if a VM or a Jenkins job is real.

## Next

Amazon **EKS** in `ap-south-1`: ECR for images, GitHub Actions push, Argo CD on EKS, same Helm chart. That needs an AWS bill (control plane + usually NAT). Until that lands, the running demo is **kind**.

## License

Use as a portfolio/study project.
