# Architecture du Pipeline CI/CD

## Vue d'ensemble

```
┌──────────────────────────────────────────────────────────────────────┐
│                        PIPELINE CI/CD COMPLET                         │
└──────────────────────────────────────────────────────────────────────┘

┌─────────────┐
│  Developer  │
│   (Local)   │
└──────┬──────┘
       │ git push
       ▼
┌─────────────────────────────────────────────────────────────┐
│                         GITHUB                              │
│  ┌──────────────┐         ┌──────────────┐                 │
│  │   main       │         │     dev      │                 │
│  │  (prod)      │         │  (staging)   │                 │
│  └──────┬───────┘         └──────┬───────┘                 │
│         │                        │                          │
│         └────────────┬───────────┘                          │
│                      │                                      │
│              ┌───────▼───────┐                              │
│              │ GitHub Actions │                             │
│              │   Workflow     │                             │
│              └───────┬────────┘                             │
│                      │                                      │
│         ┌────────────┼────────────┐                         │
│         ▼            ▼            ▼                         │
│    ┌────────┐  ┌─────────┐  ┌─────────┐                   │
│    │ Test   │  │  Build  │  │ Update  │                   │
│    │        │  │ & Push  │  │Manifest │                   │
│    └────────┘  └────┬────┘  └────┬────┘                   │
│                     │            │                         │
└─────────────────────┼────────────┼─────────────────────────┘
                      │            │
                      ▼            │ (commit manifest)
               ┌─────────────┐    │
               │ Docker Hub  │    │
               │             │    │
               │ Images:     │    │
               │ - main-xxx  │    │
               │ - dev-yyy   │    │
               │ - latest    │    │
               └─────────────┘    │
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────┐
│                    KUBERNETES CLUSTER                        │
│  ┌──────────────────────────────────────────────────────┐   │
│  │                      ArgoCD                          │   │
│  │  ┌──────────────────┐    ┌──────────────────┐       │   │
│  │  │ k8s-cicd-demo-dev│    │k8s-cicd-demo-prod│       │   │
│  │  │                  │    │                  │       │   │
│  │  │ Watch: dev branch│    │Watch: main branch│       │   │
│  │  │ Path: overlays/dev    │Path: overlays/prod      │   │
│  │  └────────┬─────────┘    └────────┬─────────┘       │   │
│  │           │                       │                 │   │
│  └───────────┼───────────────────────┼─────────────────┘   │
│              │                       │                     │
│              ▼                       ▼                     │
│  ┌────────────────────┐   ┌────────────────────┐          │
│  │   my-vcluster      │   │   my-vcluster      │          │
│  │   (namespace)      │   │   (namespace)      │          │
│  │                    │   │                    │          │
│  │ ┌────────────────┐ │   │ ┌────────────────┐ │          │
│  │ │ dev-k8s-cicd-  │ │   │ │ prod-k8s-cicd- │ │          │
│  │ │ demo           │ │   │ │ demo           │ │          │
│  │ │ (1 replica)    │ │   │ │ (3 replicas)   │ │          │
│  │ └────────────────┘ │   │ └────────────────┘ │          │
│  └────────────────────┘   └────────────────────┘          │
└─────────────────────────────────────────────────────────────┘
```

## Flux de déploiement détaillé

### 1. Développement (Branche `dev`)

```
Developer
   │
   ├─ 1. Code changes
   ├─ 2. git commit -m "feat: new feature"
   └─ 3. git push origin dev
          │
          ▼
GitHub (dev branch)
   │
   └─ Webhook triggers GitHub Actions
          │
          ▼
GitHub Actions Workflow
   │
   ├─ JOB 1: Test
   │    ├─ Checkout code
   │    ├─ Setup Node.js
   │    ├─ npm install
   │    └─ npm test ✅
   │
   ├─ JOB 2: Build & Push
   │    ├─ Docker build
   │    ├─ Tag: dev-<sha>
   │    └─ Push to Docker Hub ✅
   │
   └─ JOB 3: Update Manifest
        ├─ Update deployment.yaml
        │   image: dockerhub/app:dev-abc1234
        └─ git commit & push ✅
               │
               ▼
GitHub (manifest updated)
   │
   └─ ArgoCD detects change
          │
          ▼
ArgoCD (k8s-cicd-demo-dev)
   │
   ├─ 1. Git fetch
   ├─ 2. Compare desired state vs actual
   ├─ 3. Sync to cluster
   └─ 4. Apply manifests
          │
          ▼
Kubernetes (my-vcluster)
   │
   ├─ 1. Pull new image from Docker Hub
   ├─ 2. Rolling update deployment
   ├─ 3. Terminate old pods
   └─ 4. Start new pods ✅
          │
          └─ Application running!
```

### 2. Production (Branche `main`)

```
Developer
   │
   ├─ 1. Merge dev → main (via Pull Request)
   └─ 2. Approve & Merge
          │
          ▼
GitHub (main branch)
   │
   └─ Same workflow as dev
      BUT with:
      - Tag: main-<sha> + latest
      - Deploy to overlays/prod
      - 3 replicas (high availability)
```

## Composants et responsabilités

### GitHub
- **Rôle** : Source control & CI orchestration
- **Responsabilités** :
  - Version control (Git)
  - Trigger workflows on push
  - Run CI jobs (test, build, deploy)
  - Store secrets (Docker Hub, GitHub PAT)

### GitHub Actions
- **Rôle** : CI Pipeline
- **Responsabilités** :
  - Run automated tests
  - Build Docker images
  - Push to registry
  - Update Kubernetes manifests

### Docker Hub
- **Rôle** : Container registry
- **Responsabilités** :
  - Store Docker images
  - Provide image tags for rollback
  - Serve images to Kubernetes

### ArgoCD
- **Rôle** : CD Engine (GitOps)
- **Responsabilités** :
  - Monitor Git repository for changes
  - Sync desired state to cluster
  - Automatic deployment
  - Self-healing & auto-sync

### Kubernetes (my-vcluster)
- **Rôle** : Container orchestration
- **Responsabilités** :
  - Run containers
  - Health checks
  - Rolling updates
  - Load balancing
  - Auto-restart on failure

## Environnements

| Environnement | Branche Git | Overlay | Replicas | Auto-sync |
|--------------|-------------|---------|----------|-----------|
| **Development** | `dev` | `overlays/dev` | 1 | ✅ |
| **Production** | `main` | `overlays/prod` | 3 | ✅ |

## Sécurité

### Secrets gérés
- `DOCKERHUB_USERNAME` : Username Docker Hub
- `DOCKERHUB_TOKEN` : Token d'accès Docker Hub
- `GH_PAT` : GitHub Personal Access Token (pour commit auto)

### Bonnes pratiques appliquées
- ✅ Multi-stage Docker build (image légère)
- ✅ Non-root user dans le container
- ✅ Health checks (liveness & readiness)
- ✅ Resource limits (CPU & memory)
- ✅ Automated tests avant le build
- ✅ Image tagging avec SHA (traçabilité)
- ✅ GitOps (Git = source de vérité)

## Rollback

### Option 1 : Via ArgoCD
```bash
argocd app history k8s-cicd-demo-prod
argocd app rollback k8s-cicd-demo-prod <revision-id>
```

### Option 2 : Via Git
```bash
# Revert le commit
git revert <commit-hash>
git push

# ArgoCD sync automatiquement
```

### Option 3 : Via Kubernetes
```bash
kubectl rollout undo deployment/prod-k8s-cicd-demo
```

## Monitoring & Observabilité

### Logs
```bash
# Application logs
kubectl logs -f deployment/dev-k8s-cicd-demo

# ArgoCD logs
kubectl logs -f -n argocd deployment/argocd-server
```

### Métriques
```bash
# Pod status
kubectl get pods -l app=k8s-cicd-demo

# Deployment status
kubectl rollout status deployment/dev-k8s-cicd-demo

# ArgoCD app status
argocd app get k8s-cicd-demo-dev
```

## Évolutions futures

### Phase 2
- [ ] Ajouter un Ingress Controller (Nginx/Traefik)
- [ ] Certificats SSL automatiques (cert-manager)
- [ ] Notifications Slack/Discord sur déploiement
- [ ] Tests d'intégration E2E

### Phase 3
- [ ] Blue/Green deployment
- [ ] Canary deployment (progressive rollout)
- [ ] A/B testing
- [ ] Feature flags

### Phase 4
- [ ] Prometheus & Grafana (monitoring)
- [ ] ELK Stack (logs centralisés)
- [ ] Distributed tracing (Jaeger)
- [ ] Security scanning (Trivy, Snyk)

## Temps de déploiement

| Étape | Durée estimée |
|-------|--------------|
| Git push | < 1 sec |
| GitHub Actions (tests) | ~30 sec |
| GitHub Actions (build & push) | ~2 min |
| GitHub Actions (update manifest) | ~5 sec |
| ArgoCD sync detection | ~3 min (polling) |
| Kubernetes rolling update | ~30 sec |
| **TOTAL** | **~6-7 minutes** |

*Note : Le temps peut être réduit en configurant ArgoCD avec des webhooks au lieu du polling.*

## Contact & Support

Pour toute question ou problème, consulter :
- **README.md** : Documentation complète
- **QUICKSTART.md** : Guide de démarrage rapide
- **GitHub Issues** : Rapporter un problème

---

**Pipeline créé avec ❤️ pour Kubernetes CI/CD Demo**
