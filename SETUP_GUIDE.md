# Guide de configuration - CI/CD Pipeline

## ✅ Ce qui est déjà fait

- [x] Projet configuré avec vos identifiants
  - GitHub : **magatte365**
  - Docker Hub : **magatte2380**
- [x] Git initialisé avec les branches `main` et `dev`
- [x] Tous les fichiers prêts à être poussés

## 📋 Ce qu'il reste à faire (15 minutes)

### Étape 1 : Créer le repository GitHub (2 min)

1. Aller sur : https://github.com/new
2. Repository name : **k8s-cicd-demo**
3. Visibility : **Public** (ou Private si vous préférez)
4. ⚠️ **NE PAS** cocher "Add a README file"
5. ⚠️ **NE PAS** cocher "Add .gitignore"
6. Cliquer sur **"Create repository"**

### Étape 2 : Créer le Docker Hub Access Token (3 min)

1. Aller sur : https://hub.docker.com/settings/security
2. Cliquer sur **"New Access Token"**
3. Description : `github-actions-k8s-cicd-demo`
4. Access permissions : **Read, Write, Delete**
5. Cliquer sur **"Generate"**
6. ✅ **COPIER LE TOKEN** (vous ne pourrez plus le revoir !)
   ```
   Exemple : dckr_pat_xxxxxxxxxxxxxxxxxxxxx
   ```

### Étape 3 : Créer le GitHub Personal Access Token (3 min)

1. Aller sur : https://github.com/settings/tokens
2. Cliquer sur **"Generate new token"** → **"Generate new token (classic)"**
3. Note : `argocd-manifest-update`
4. Expiration : **No expiration** (ou 90 days)
5. ✅ **Cocher uniquement** : `repo` (Full control of private repositories)
   - [x] repo
     - [x] repo:status
     - [x] repo_deployment
     - [x] public_repo
     - [x] repo:invite
     - [x] security_events
6. Cliquer sur **"Generate token"**
7. ✅ **COPIER LE TOKEN** (vous ne pourrez plus le revoir !)
   ```
   Exemple : ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   ```

### Étape 4 : Configurer les secrets GitHub (3 min)

1. Aller sur votre repository : https://github.com/magatte365/k8s-cicd-demo
2. Aller dans **Settings** → **Secrets and variables** → **Actions**
3. Cliquer sur **"New repository secret"**
4. Ajouter les 3 secrets suivants :

#### Secret 1 : DOCKERHUB_USERNAME
- Name : `DOCKERHUB_USERNAME`
- Secret : `magatte2380`
- Cliquer sur **"Add secret"**

#### Secret 2 : DOCKERHUB_TOKEN
- Name : `DOCKERHUB_TOKEN`
- Secret : (coller le token Docker Hub de l'étape 2)
- Cliquer sur **"Add secret"**

#### Secret 3 : GH_PAT
- Name : `GH_PAT`
- Secret : (coller le GitHub PAT de l'étape 3)
- Cliquer sur **"Add secret"**

### Étape 5 : Pousser le code vers GitHub (1 min)

Une fois le repository créé sur GitHub, exécutez ces commandes :

```bash
cd C:/Users/Administrator/k8s-cicd-demo

# Ajouter le remote
git remote add origin https://github.com/magatte365/k8s-cicd-demo.git

# Pousser la branche main
git push -u origin main

# Pousser la branche dev
git push -u origin dev
```

Vous pouvez aussi utiliser GitHub Desktop ou VSCode pour pousser le code.

## ✅ Vérification

Une fois que vous avez terminé, vérifiez :

1. **Repository GitHub** : https://github.com/magatte365/k8s-cicd-demo
   - [ ] Le code est visible
   - [ ] Les deux branches `main` et `dev` existent
   - [ ] Les 3 secrets sont configurés

2. **Pas encore de workflow exécuté** (normal, on n'a pas encore fait de commit après la configuration)

## 🚀 Prochaine étape

Une fois tout configuré, revenez me voir et je vais :
1. Déployer les applications ArgoCD sur le cluster
2. Faire un test complet du pipeline
3. Migrer vos applications existantes

---

**Besoin d'aide ?**

Si vous rencontrez un problème, faites-moi savoir à quelle étape vous êtes bloqué !
