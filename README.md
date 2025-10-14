
# 🏗️ Franz.Platform.IAC  
### Multi-Cloud Infrastructure Automation — Industrial-grade Infrastructure-as-Code for Azure, AWS & GCP

> 🇫🇷 Ce projet est également disponible en français : [README.fr.md](./README.fr.md)

---

## 🌍 Overview

**Franz.Platform.IAC** is the infrastructure automation backbone of the **Franz Ecosystem** — an industrial-grade, multi-cloud Infrastructure-as-Code (IaC) framework designed to unify **Azure (Bicep)**, **AWS (Terraform)**, and **GCP (Terraform)** deployments under a single, deterministic governance model.

It provides reproducible, modular, and environment-aware deployments through standardized CI/CD pipelines across:
- **Azure DevOps**
- **GitHub Actions**
- **GitLab CI/CD**

The philosophy behind the project is simple:  
> “Change variables, not pipelines.”

---

## 🗂️ Repository Structure

```

Infrastructure/
├── AzureDevOps-Bicep/      # Azure infrastructure (Bicep)
├── Terraform-AWS/          # AWS infrastructure (Terraform)
├── Terraform-GCP/          # GCP infrastructure (Terraform)
└── pipelines/
├── azure-pipelines.yml
├── .github/workflows/deploy-infra.yml
└── .gitlab-ci.yml

````

Each directory corresponds to a specific cloud provider implementation.  
The `pipelines` folder contains identical orchestration logic adapted for each CI/CD platform.

---

## 🚀 Usage

### Deployment Steps
1. **Select your cloud provider:** `azure`, `aws`, or `gcp`.  
2. **Set your environment:** `dev`, `staging`, or `prod`.  
3. **Run the appropriate pipeline:** on Azure DevOps, GitHub Actions, or GitLab CI/CD.  
4. **Observe automation:** pipelines execute the main IaC template, deploy the infrastructure, and export deployment outputs for GitOps consumption.

---

## ☁️ Multi-Cloud Logic

All Franz.Platform.IAC pipelines share a unified parameter-driven decision model:

```yaml
parameters:
  containerOrchestrator: [ aks, eks, gke, none ]
  databaseType: [ single, multi ]
  messagingType: [ kafka, rabbitmq, both ]
````

By changing parameters rather than pipeline logic, you achieve deterministic, reproducible, and portable behavior across all supported clouds.

---

## 📤 Outputs & GitOps Integration

Each deployment automatically produces an artifact named `infra-outputs.json` containing:

* Resource IDs
* Connection strings
* Endpoints and URIs

These outputs are consumed by GitOps tools such as **ArgoCD**, **Flux**, or any automation layer to synchronize application deployments post-infrastructure provisioning.

---

## 🧠 Philosophy

> **“Change variables, not pipelines.”**
> Franz.Platform.IAC industrializes cloud deployment through determinism, modularity, and reproducibility across all hyperscalers.

The project embodies an **architectural-first philosophy**, enabling developers and DevOps teams to focus on domain logic while enforcing architectural consistency and compliance.

---

## 🧩 Supported CI/CD Platforms

| Platform           | IaC Engine        | File                                 | Description                                          |
| ------------------ | ----------------- | ------------------------------------ | ---------------------------------------------------- |
| **Azure DevOps**   | Bicep             | `azure-pipelines.yml`                | Industrial-grade orchestrator for Azure environments |
| **GitHub Actions** | Bicep / Terraform | `.github/workflows/deploy-infra.yml` | Manual or scheduled multi-cloud deployment           |
| **GitLab CI/CD**   | Bicep / Terraform | `.gitlab-ci.yml`                     | Manual, on-demand infrastructure deployment pipeline |

---

## 🧱 Requirements

* **Azure CLI** ≥ 2.60
* **Terraform** ≥ 1.8
* **jq** (for output parsing)
* Access to Azure, AWS, and/or GCP credentials via environment variables or Key Vault/Secret Manager

---

## 📦 Example: Manual Deployment (GitHub)

```bash
# 1️⃣ Configure credentials in repository secrets
AZURE_SUBSCRIPTION_ID, AZURE_CLIENT_ID, AZURE_CLIENT_SECRET, AZURE_TENANT_ID

# 2️⃣ Trigger manually from Actions tab
# Select environment and parameters
# Deployment will:
#  - Authenticate with Azure
#  - Deploy Bicep template
#  - Export outputs as infra-outputs.json artifact
```

---

## 🧭 Architecture Vision

**Franz.Platform.IAC** is part of the broader **Franz Ecosystem**, which includes:

* **Franz.Common** — Shared business rules, conventions, and mediator layer.
* **Franz.API** — Cloud-native API template, using the Franz framework.
* **Aegis** — Architecture and code-quality auditing engine.
* **Archena.AI** — AI-driven architectural assistant.

Together, they form a unified industrial platform where **code, infrastructure, and architecture** evolve coherently across projects.

---

## 📜 License & Credits

Developed and maintained by **Bernardo Estacio Abreu**
Architectural design and framework integration under **AjnaTellus** and the **Franz Framework**.

> Franz.Platform.IAC — *“Industrializing cloud deployment, one variable at a time.”*
> *Automate once, deploy everywhere.*

---

## 🧩 Connect

* **LinkedIn:** [linkedin.com/in/bernardo-estacio](https://linkedin.com/in/bernardo-estacio)
* **GitHub:** [github.com/bestacio89](https://github.com/bestacio89)
* **GitLab:** [gitlab.com/AjnaTellus](https://gitlab.com/AjnaTellus)

