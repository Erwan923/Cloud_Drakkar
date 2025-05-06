# Cloud\_Drakkar
![CodeRabbit Pull Request Reviews](https://img.shields.io/coderabbit/prs/github/Erwan923/Cloud_Drakkar?utm_source=oss&utm_medium=github&utm_campaign=Erwan923%2FCloud_Drakkar&labelColor=171717&color=FF570A&link=https%3A%2F%2Fcoderabbit.ai&label=CodeRabbit+Reviews)
![Drakkar Logo](assets/logo.png)

Ce projet automatise de A à Z le déploiement d’une API de gestion de factures sur AWS :
Terraform : crée le réseau (VPC, subnets, Internet Gateway) + un cluster EKS HA + un Node Group
FastAPI + PostgreSQL (en mémoire pour la demo) packagé en Docker
Kubernetes (EKS) : orchestre et expose l’API via un LoadBalancer
GitHub Actions : pipeline CI/CD qui rebuild l’image, la pousse en ECR et redéploie automatiquement sur EKS à chaque push

## 📥 Installation

1. **Cloner le dépôt**

   ```bash
   git clone https://github.com/Erwan923/Cloud_Drakkar.git
   cd Cloud_Drakkar
   ```

2. **Ajouter le logo**

   * Placez votre fichier `A_logo_illustration_in_a_modern,_animated_style_de.png` dans le dossier `assets/` (créez-le si nécessaire) :

     ```bash
     mkdir -p assets
     mv /chemin/vers/A_logo_illustration_in_a_modern,_animated_style_de.png assets/logo.png
     ```
   * Le chemin relatif `assets/logo.png` est utilisé dans ce README pour l'affichage.

## 🔧 Structure du projet

```
Cloud_Drakkar/
├── .github/
│   └── workflows/deploy.yml   # CI/CD
├── assets/
│   └── logo.png               # Logo du projet
├── app/invoice-api/           # Code de l’API FastAPI
│   ├── main.py
│   ├── requirements.txt
│   └── Dockerfile
├── k8s/                       # Manifests Kubernetes
│   ├── invoice-deployment.yaml
│   └── invoice-service.yaml
└── terraform/                 # Infrastructure as Code
    ├── backend.tf
    ├── main.tf
    ├── outputs.tf
    ├── providers.tf
    └── variables.tf
```

## 🚀 Déploiement local

1. **Créer le bucket S3 et DynamoDB pour l’état Terraform**

   ```bash
   aws s3api create-bucket --bucket terraform-state-cloud-drakkar --region eu-west-3 --create-bucket-configuration LocationConstraint=eu-west-3
   aws dynamodb create-table --table-name terraform-locks --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --billing-mode PAY_PER_REQUEST --region eu-west-3
   ```

2. **Initialiser Terraform**

   ```bash
   cd terraform
   terraform init
   terraform apply -auto-approve
   ```

3. **Configurer kubectl**

   ```bash
   aws eks update-kubeconfig --region eu-west-3 --name drakkar-cluster --alias drakkar
   kubectl config use-context drakkar
   ```

4. **Déployer l’app**

   ```bash
   cd ../k8s
   kubectl apply -f invoice-deployment.yaml
   kubectl apply -f invoice-service.yaml
   ```

## 🎯 CI/CD GitHub Actions

Le workflow `.github/workflows/deploy.yml` :

* **Trigger** : `push` sur `main` branch
* **Steps** : checkout, configure AWS, login ECR, build & push Docker, setup kubectl, update kubeconfig, deploy K8s manifests

### Pour ajouter le workflow :

```bash
git add .github/workflows/deploy.yml assets/logo.png
git commit -m "Ajout logo et workflow CI/CD"
git push origin main
```

## 📖 Utilisation

* **Vérifier l’API** :

  ```bash
  ELB=$(kubectl get svc invoice-api-svc -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
  curl http://$ELB/health
  ```
* **Créer une facture** :

  ```bash
  curl -X POST "http://$ELB/invoices/" -H "Content-Type: application/json" -d '{"id":1,"amount":123.45,"description":"Test"}'
  ```

---

*Ce README a été conçu pour guider un utilisateur débutant dans l’utilisation de ce repo.*
