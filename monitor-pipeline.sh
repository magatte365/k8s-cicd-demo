#!/bin/bash

# Script de monitoring du pipeline CI/CD
# Usage: ./monitor-pipeline.sh

echo "🔍 Monitoring du Pipeline CI/CD"
echo "================================"
echo ""

echo "📊 GitHub Actions:"
echo "   URL: https://github.com/magatte365/k8s-cicd-demo/actions"
echo "   Aller sur ce lien pour voir le workflow en temps réel"
echo ""

echo "🐳 Docker Hub:"
echo "   URL: https://hub.docker.com/r/magatte2380/k8s-cicd-demo/tags"
echo "   Vérifier que l'image a été poussée"
echo ""

echo "📦 ArgoCD Applications:"
ssh -i "mtb_keys.pem" -o StrictHostKeyChecking=no ubuntu@13.39.144.79 "argocd app list | grep k8s-cicd-demo"
echo ""

echo "🚀 Pods dans le vcluster:"
ssh -i "mtb_keys.pem" -o StrictHostKeyChecking=no ubuntu@13.39.144.79 "kubectl get pods -n vcluster-ns | grep k8s-cicd-demo"
echo ""

echo "📝 Pour rafraîchir automatiquement toutes les 10 secondes:"
echo "   watch -n 10 ./monitor-pipeline.sh"
