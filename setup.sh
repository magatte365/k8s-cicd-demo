#!/bin/bash

# Script de configuration du pipeline CI/CD
# Usage: ./setup.sh <github-username> <dockerhub-username>

set -e

GITHUB_USERNAME=$1
DOCKERHUB_USERNAME=$2

if [ -z "$GITHUB_USERNAME" ] || [ -z "$DOCKERHUB_USERNAME" ]; then
    echo "Usage: ./setup.sh <github-username> <dockerhub-username>"
    exit 1
fi

echo "🚀 Configuration du pipeline CI/CD..."
echo "GitHub Username: $GITHUB_USERNAME"
echo "Docker Hub Username: $DOCKERHUB_USERNAME"
echo ""

# Remplacer les placeholders
echo "📝 Mise à jour des fichiers de configuration..."

# Deployment
sed -i.bak "s/YOUR_DOCKERHUB_USERNAME/$DOCKERHUB_USERNAME/g" k8s/base/deployment.yaml

# ArgoCD applications
sed -i.bak "s/YOUR_GITHUB_USERNAME/$GITHUB_USERNAME/g" argocd/application-dev.yaml
sed -i.bak "s/YOUR_GITHUB_USERNAME/$GITHUB_USERNAME/g" argocd/application-prod.yaml

# Supprimer les fichiers de backup
find . -name "*.bak" -delete

echo "✅ Configuration terminée!"
echo ""
echo "📋 Prochaines étapes:"
echo "1. Créer le repository GitHub: https://github.com/new"
echo "2. Configurer les secrets GitHub:"
echo "   - DOCKERHUB_USERNAME=$DOCKERHUB_USERNAME"
echo "   - DOCKERHUB_TOKEN=<votre-token>"
echo "   - GH_PAT=<votre-personal-access-token>"
echo ""
echo "3. Initialiser le repository:"
echo "   git init"
echo "   git add ."
echo "   git commit -m \"Initial commit: CI/CD pipeline setup\""
echo "   git branch -M main"
echo "   git remote add origin https://github.com/$GITHUB_USERNAME/k8s-cicd-demo.git"
echo "   git push -u origin main"
echo "   git checkout -b dev"
echo "   git push -u origin dev"
echo ""
echo "4. Déployer sur ArgoCD:"
echo "   kubectl apply -f argocd/application-dev.yaml"
echo "   kubectl apply -f argocd/application-prod.yaml"
