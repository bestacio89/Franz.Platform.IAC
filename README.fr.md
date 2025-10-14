# 🏗️ Franz.Platform.IAC  
### Automatisation d’infrastructure multi-cloud — Infrastructure-as-Code industrielle pour Azure, AWS et GCP

> 🇬🇧 This project is also available in English: [README.md](./README.md)

---

## 🌍 Présentation

**Franz.Platform.IAC** est la colonne vertébrale d’automatisation de l’écosystème **Franz** — un cadre d’Infrastructure-as-Code (*IaC*) multi-cloud de niveau industriel, conçu pour unifier les déploiements **Azure (Bicep)**, **AWS (Terraform)** et **GCP (Terraform)** sous un même modèle de gouvernance déterministe.

Il offre des déploiements reproductibles, modulaires et sensibles à l’environnement grâce à des pipelines CI/CD unifiés sur :
- **Azure DevOps**
- **GitHub Actions**
- **GitLab CI/CD**

La philosophie du projet est simple :  
> « Changez les variables, pas les pipelines. »

---

## 🗂️ Structure du dépôt

```

Infrastructure/
├── AzureDevOps-Bicep/      # Infrastructure Azure (Bicep)
├── Terraform-AWS/          # Infrastructure AWS (Terraform)
├── Terraform-GCP/          # Infrastructure GCP (Terraform)
└── pipelines/
├── azure-pipelines.yml
├── .github/workflows/deploy-infra.yml
└── .gitlab-ci.yml

````

Chaque dossier correspond à un fournisseur cloud spécifique.  
Le répertoire `pipelines` contient la logique d’orchestration standardisée pour chaque plateforme CI/CD.

---

## 🚀 Utilisation

### Étapes de déploiement
1. **Choisir le fournisseur cloud :** `azure`, `aws` ou `gcp`.  
2. **Définir l’environnement :** `dev`, `staging` ou `prod`.  
3. **Exécuter le pipeline approprié :** sur Azure DevOps, GitHub Actions ou GitLab CI/CD.  
4. **Laisser faire l’automatisation :** les pipelines exécutent le modèle IaC principal, déploient l’infrastructure et exportent les sorties pour une consommation GitOps.

---

## ☁️ Logique multi-cloud

Tous les pipelines de **Franz.Platform.IAC** reposent sur un modèle décisionnel unifié basé sur des paramètres :

```yaml
parameters:
  containerOrchestrator: [ aks, eks, gke, none ]
  databaseType: [ single, multi ]
  messagingType: [ kafka, rabbitmq, both ]
````

En modifiant uniquement les variables plutôt que le code des pipelines, on obtient un comportement déterministe, reproductible et portable sur tous les clouds pris en charge.

---

## 📤 Sorties et intégration GitOps

Chaque déploiement génère automatiquement un artefact nommé `infra-outputs.json` contenant :

* Les identifiants des ressources
* Les chaînes de connexion
* Les points d’accès et URI

Ces informations peuvent ensuite être exploitées par des outils GitOps tels que **ArgoCD**, **Flux** ou tout autre orchestrateur pour synchroniser le déploiement applicatif après la mise en place de l’infrastructure.

---

## 🧠 Philosophie

> **« Changez les variables, pas les pipelines. »**
> Franz.Platform.IAC industrialise le déploiement cloud en garantissant le déterminisme, la modularité et la reproductibilité sur l’ensemble des fournisseurs.

Le projet incarne une philosophie **centrée sur l’architecture**, permettant aux équipes de développement et de DevOps de se concentrer sur la logique métier tout en assurant la cohérence et la conformité de l’architecture.

---

## 🧩 Plateformes CI/CD supportées

| Plateforme         | Moteur IaC        | Fichier                              | Description                                            |
| ------------------ | ----------------- | ------------------------------------ | ------------------------------------------------------ |
| **Azure DevOps**   | Bicep             | `azure-pipelines.yml`                | Orchestrateur industriel pour les environnements Azure |
| **GitHub Actions** | Bicep / Terraform | `.github/workflows/deploy-infra.yml` | Déploiement multi-cloud manuel ou planifié             |
| **GitLab CI/CD**   | Bicep / Terraform | `.gitlab-ci.yml`                     | Pipeline de déploiement d’infrastructure à la demande  |

---

## 🧱 Prérequis

* **Azure CLI** ≥ 2.60
* **Terraform** ≥ 1.8
* **jq** (pour le traitement des sorties)
* Accès aux identifiants Azure, AWS et/ou GCP via des variables d’environnement ou un Key Vault / Secret Manager

---

## 📦 Exemple : déploiement manuel (GitHub)

```bash
# 1️⃣ Configurer les identifiants dans les secrets du dépôt
AZURE_SUBSCRIPTION_ID, AZURE_CLIENT_ID, AZURE_CLIENT_SECRET, AZURE_TENANT_ID

# 2️⃣ Lancer manuellement le workflow depuis l’onglet Actions
# Sélectionner l’environnement et les paramètres
# Le déploiement effectuera :
#  - L’authentification à Azure
#  - Le déploiement du modèle Bicep
#  - L’exportation des sorties dans l’artefact infra-outputs.json
```

---

## 🧭 Vision architecturale

**Franz.Platform.IAC** fait partie de l’écosystème **Franz**, qui comprend :

* **Franz.Common** — Règles métier, conventions et couche médiateur partagées.
* **Franz.API** — Modèle d’API cloud-native utilisant le framework Franz.
* **Aegis** — Moteur d’audit d’architecture et de qualité de code.
* **Archena.AI** — Assistant d’architecture piloté par l’intelligence artificielle.

Ensemble, ces projets forment une plateforme industrielle unifiée où **le code, l’infrastructure et l’architecture** évoluent de manière cohérente et intégrée.

---

## 📜 Licence et crédits

Développé et maintenu par **Bernardo Estacio Abreu**
Conception architecturale et intégration sous **AjnaTellus** et le **framework Franz**.

> Franz.Platform.IAC — *« Industrialiser le déploiement cloud, une variable à la fois. »*
> *Automatiser une fois, déployer partout.*

---

## 🧩 Contacts

* **LinkedIn :** [linkedin.com/in/bernardo-estacio](https://linkedin.com/in/bernardo-estacio)
* **GitHub :** [github.com/bestacio89](https://github.com/bestacio89)
* **GitLab :** [gitlab.com/AjnaTellus](https://gitlab.com/AjnaTellus)

```

