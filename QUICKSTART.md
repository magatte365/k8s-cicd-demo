# Guide de démarrage rapide CI/CD

## Étape 1 : Configuration initiale (5 min)

### 1.1 Exécuter le script de configuration

```bash
cd k8s-cicd-demo
chmod +x setup.sh
./setup.sh YOUR_GITHUB_USERNAME YOUR_DOCKERHUB_USERNAME
```

### 1.2 Créer les tokens requis

**Docker Hub Token :**
1. Aller sur https://hub.docker.com/settings/security
2. Cliquer "New Access Token"
3. Nom : `github-actions`
4. Permissions : `Read, Write, Delete`
5. Copier le token

**GitHub Personal Access Token :**
1. Aller sur https://github.com/settings/tokens
2. Cliquer "Generate new token (classic)"
3. Nom : `argocd-manifest-update`
4. Sélectionner : `repo` (Full control)
5. Copier le token

## Étape 2 : Créer le repository GitHub (2 min)

```bash
# Initialiser Git
git init
git add .
git commit -m "Initial commit: CI/CD pipeline setup"

# Créer le repo sur GitHub
# Aller sur https://github.com/new
# Nom du repo: k8s-cicd-demo
# Visibility: Public ou Private

# Pousser le code
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/k8s-cicd-demo.git
git push -u origin main

# Créer la branche dev
git checkout -b dev
git push -u origin dev
```

## Étape 3 : Configurer les secrets GitHub (2 min)

1. Aller sur votre repository GitHub
2. **Settings** → **Secrets and variables** → **Actions**
3. Cliquer **New repository secret** et ajouter :

| Nom du secret | Valeur |
|--------------|--------|
| `DOCKERHUB_USERNAME` | Votre username Docker Hub |
| `DOCKERHUB_TOKEN` | Le token créé à l'étape 1.2 |
| `GH_PAT` | Le GitHub PAT créé à l'étape 1.2 |

## Étape 4 : Déployer sur ArgoCD (2 min)

```bash
# Se connecter au master Kubernetes
ssh -i "mtb_keys.pem" ubuntu@13.39.144.79

# Copier les fichiers ArgoCD (depuis votre machine locale)
scp -i "mtb_keys.pem" argocd/*.yaml ubuntu@13.39.144.79:~/

# Sur le master, appliquer les applications
kubectl apply -f application-dev.yaml
kubectl apply -f application-prod.yaml

# Vérifier
argocd app list
argocd app get k8s-cicd-demo-dev
```

## Étape 5 : Tester le pipeline (1 min)

```bash
# Faire un changement
cd app
echo "console.log('Pipeline test');" >> server.js

# Commit et push
git add .
git commit -m "test: pipeline CI/CD"
git push origin dev
```

## Vérifier l'exécution

### GitHub Actions
1. Aller sur https://github.com/YOUR_USERNAME/k8s-cicd-demo/actions
2. Voir le workflow en cours d'exécution
3. Vérifier que tous les jobs sont verts ✅

### Docker Hub
1. Aller sur https://hub.docker.com/r/YOUR_USERNAME/k8s-cicd-demo/tags
2. Vérifier que l'image a été poussée avec le tag `dev-<sha>`

### ArgoCD
```bash
# Voir le statut
argocd app get k8s-cicd-demo-dev

# Forcer la synchronisation si nécessaire
argocd app sync k8s-cicd-demo-dev
```

### Kubernetes
```bash
# Voir les pods
kubectl get pods -l app=k8s-cicd-demo

# Voir les logs
kubectl logs -f deployment/dev-k8s-cicd-demo

# Tester l'application
kubectl get svc dev-k8s-cicd-demo
curl http://NODE_IP:NODE_PORT
```

## Workflow complet

```
Developer                GitHub Actions              ArgoCD                  Kubernetes
   │                           │                        │                         │
   ├─ git push dev ──────────> │                        │                         │
   │                           ├─ Run tests             │                         │
   │                           ├─ Build Docker image    │                         │
   │                           ├─ Push to Docker Hub    │                         │
   │                           ├─ Update manifest       │                         │
   │                           ├─ Commit changes ──────>│                         │
   │                           │                        ├─ Detect change          │
   │                           │                        ├─ Pull manifest          │
   │                           │                        ├─ Deploy ───────────────>│
   │                           │                        │                         ├─ Pull image
   │                           │                        │                         ├─ Create pods
   │                           │                        │                         ├─ Running ✅
```

## Troubleshooting rapide

### ❌ GitHub Actions échoue sur "Login to Docker Hub"
→ Vérifier les secrets `DOCKERHUB_USERNAME` et `DOCKERHUB_TOKEN`

### ❌ GitHub Actions échoue sur "Update manifest"
→ Vérifier le secret `GH_PAT` et ses permissions

### ❌ ArgoCD ne synchronise pas
```bash
argocd app get k8s-cicd-demo-dev --refresh
argocd app sync k8s-cicd-demo-dev
```

### ❌ Pods en erreur ImagePullBackOff
→ Vérifier que l'image existe sur Docker Hub
→ Vérifier le nom de l'image dans `k8s/base/deployment.yaml`

## URLs utiles

- **GitHub Actions** : https://github.com/YOUR_USERNAME/k8s-cicd-demo/actions
- **Docker Hub** : https://hub.docker.com/r/YOUR_USERNAME/k8s-cicd-demo
- **ArgoCD** : https://13.39.144.79:30912 (via tunnel SSH)

## Prochaines étapes

Une fois que tout fonctionne :

1. **Migrer vos applications existantes** (frontend, backend, mongodb)
2. **Ajouter des notifications** (Slack, Discord)
3. **Mettre en place un Ingress** pour l'accès externe
4. **Ajouter du monitoring** (Prometheus, Grafana)
5. **Scanner les vulnérabilités** (Trivy dans le pipeline)

Bon déploiement ! 🚀
