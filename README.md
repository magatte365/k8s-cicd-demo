# Kubernetes CI/CD Pipeline Demo

Pipeline CI/CD complet utilisant **GitHub Actions**, **Docker Hub**, **ArgoCD** et **Kubernetes**.

## Architecture

```
Developer → GitHub → GitHub Actions → Docker Hub → ArgoCD → Kubernetes (vcluster)
```

## Structure du projet

```
k8s-cicd-demo/
├── app/                          # Application Node.js
│   ├── server.js                 # Serveur Express
│   ├── server.test.js            # Tests Jest
│   └── package.json              # Dépendances
├── k8s/                          # Manifests Kubernetes
│   ├── base/                     # Configuration de base
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── kustomization.yaml
│   └── overlays/                 # Configurations par environnement
│       ├── dev/
│       └── prod/
├── argocd/                       # Applications ArgoCD
│   ├── application-dev.yaml
│   └── application-prod.yaml
├── .github/workflows/            # Pipeline CI/CD
│   └── ci-cd.yaml
├── Dockerfile                    # Image Docker
└── README.md
```

## Prérequis

1. **Compte GitHub** avec un repository
2. **Compte Docker Hub**
3. **Cluster Kubernetes** avec ArgoCD installé
4. **my-vcluster** ajouté à ArgoCD

## Configuration

### 1. Créer le repository GitHub

```bash
cd k8s-cicd-demo
git init
git add .
git commit -m "Initial commit: CI/CD pipeline setup"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/k8s-cicd-demo.git
git push -u origin main

# Créer une branche dev
git checkout -b dev
git push -u origin dev
```

### 2. Configurer les secrets GitHub

Allez dans **Settings → Secrets and variables → Actions** et ajoutez :

| Secret Name | Value | Description |
|------------|-------|-------------|
| `DOCKERHUB_USERNAME` | votre_username | Username Docker Hub |
| `DOCKERHUB_TOKEN` | votre_token | Token d'accès Docker Hub |
| `GH_PAT` | votre_personal_access_token | GitHub Personal Access Token |

**Créer un Personal Access Token GitHub :**
1. GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Generate new token
3. Sélectionner : `repo` (Full control of private repositories)
4. Copier le token et l'ajouter comme secret `GH_PAT`

**Créer un Docker Hub Access Token :**
1. Docker Hub → Account Settings → Security → New Access Token
2. Copier le token et l'ajouter comme secret `DOCKERHUB_TOKEN`

### 3. Modifier les fichiers de configuration

**Fichier `k8s/base/deployment.yaml` :**
```bash
# Remplacer YOUR_DOCKERHUB_USERNAME par votre username Docker Hub
sed -i 's/YOUR_DOCKERHUB_USERNAME/your_actual_username/g' k8s/base/deployment.yaml
```

**Fichiers ArgoCD :**
```bash
# Remplacer YOUR_GITHUB_USERNAME dans argocd/*.yaml
sed -i 's/YOUR_GITHUB_USERNAME/your_actual_username/g' argocd/application-*.yaml
```

### 4. Déployer les applications ArgoCD

```bash
# Se connecter au master Kubernetes
ssh -i "mtb_keys.pem" ubuntu@13.39.144.79

# Appliquer les applications ArgoCD
kubectl apply -f argocd/application-dev.yaml
kubectl apply -f argocd/application-prod.yaml

# Vérifier
argocd app list
argocd app get k8s-cicd-demo-dev
```

## Workflow CI/CD

### Push sur la branche `dev`

1. **GitHub Actions s'exécute :**
   - Run tests
   - Build Docker image
   - Tag : `dev-<sha>`
   - Push to Docker Hub
   - Update `k8s/base/deployment.yaml`

2. **ArgoCD détecte le changement :**
   - Sync automatique vers my-vcluster
   - Déploiement dans namespace `default`
   - 1 replica (environnement dev)

### Push sur la branche `main`

1. **GitHub Actions s'exécute :**
   - Run tests
   - Build Docker image
   - Tag : `main-<sha>` + `latest`
   - Push to Docker Hub
   - Update `k8s/base/deployment.yaml`

2. **ArgoCD déploie en production :**
   - Sync automatique
   - 3 replicas (haute disponibilité)

## Test du pipeline

### 1. Faire un changement

```bash
# Modifier l'application
cd app
# Éditer server.js - changer le message

git add .
git commit -m "feat: update welcome message"
git push origin dev
```

### 2. Suivre l'exécution

```bash
# GitHub Actions
# Aller sur https://github.com/YOUR_USERNAME/k8s-cicd-demo/actions

# ArgoCD
argocd app sync k8s-cicd-demo-dev
argocd app get k8s-cicd-demo-dev

# Kubernetes
kubectl get pods -n default
kubectl logs -f <pod-name>
```

### 3. Accéder à l'application

```bash
# Récupérer le NodePort
kubectl get svc -n default

# Accéder via navigateur
curl http://NODE_IP:NODE_PORT
```

## Commandes utiles

```bash
# Voir les applications ArgoCD
argocd app list

# Forcer la synchronisation
argocd app sync k8s-cicd-demo-dev

# Voir les logs
kubectl logs -f deployment/dev-k8s-cicd-demo

# Rollback
argocd app rollback k8s-cicd-demo-dev

# Supprimer une application
argocd app delete k8s-cicd-demo-dev
```

## Endpoints de l'application

- `GET /` - Message de bienvenue
- `GET /health` - Health check
- `GET /api/info` - Informations sur l'application

## Troubleshooting

### Le workflow GitHub Actions échoue

- Vérifier les secrets GitHub
- Vérifier le nom d'utilisateur Docker Hub dans deployment.yaml

### ArgoCD ne synchronise pas

```bash
# Vérifier la connexion au cluster
argocd cluster list

# Vérifier l'application
argocd app get k8s-cicd-demo-dev

# Forcer le refresh
argocd app get k8s-cicd-demo-dev --refresh
```

### L'image Docker n'est pas trouvée

- Vérifier que l'image existe sur Docker Hub
- Vérifier le nom de l'image dans deployment.yaml

## Évolutions possibles

- [ ] Ajouter des tests d'intégration
- [ ] Implémenter un déploiement Canary
- [ ] Ajouter des notifications Slack/Discord
- [ ] Mettre en place un reverse proxy (Ingress)
- [ ] Ajouter du monitoring (Prometheus/Grafana)
- [ ] Scanner les vulnérabilités (Trivy)

## Licence

MIT
