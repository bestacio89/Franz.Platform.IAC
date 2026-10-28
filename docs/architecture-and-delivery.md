# Infrastructure architecture and delivery contract

## Purpose

Franz.Platform.IAC is the infrastructure reference implementation for Franz services. It supports multiple cloud providers and CI/CD systems without pretending their resource models are interchangeable.

## Architectural boundaries

- **Workload contract:** environment, service identity, container image digest, network exposure, health probes, resources, scaling, persistence, messaging, telemetry, and secret references.
- **Cloud implementation:** provider-native resources and security controls. Azure uses Bicep; AWS and GCP use Terraform. Provider modules own provider-specific details.
- **Delivery adapter:** GitHub Actions, GitLab CI/CD, or Azure Pipelines. Adapters invoke the same validation and deployment lifecycle for a selected provider; they must not duplicate infrastructure logic.
- **Cluster workload:** Kubernetes manifests/Helm/Kustomize and GitOps configuration are separate from cloud provisioning. Provisioning a cluster must not implicitly deploy an application unless the selected workload contract explicitly requests it.

## Supported deployment profiles

| Profile | Azure | AWS | GCP | Intended use |
| --- | --- | --- | --- | --- |
| Managed application | Azure Container Apps / App Service | ECS / App Runner | Cloud Run | Default for services that do not require Kubernetes APIs |
| Managed Kubernetes | AKS | EKS | GKE | Workloads that need Kubernetes scheduling, operators, or platform-level control |
| State and data | Azure Database services | RDS / managed data services | Cloud SQL / managed data services | Prefer managed data services unless there is a documented operational reason not to |
| Secrets and identity | Managed Identity + Key Vault | IAM roles + Secrets Manager/SSM | Workload Identity + Secret Manager | Avoid long-lived credentials in pipelines and application configuration |

The profiles are alternatives, not a promise that every combination of database, broker, and compute engine is valid. Each provider module must declare supported combinations and reject unsupported values.

## Infrastructure lifecycle

1. Validate formatting, syntax, module inputs, policy, and secret handling without cloud credentials.
2. Initialize with a remote state backend and locking appropriate to the selected provider.
3. Produce a plan/what-if artifact for review; never apply a plan from an untrusted pull request.
4. Apply only from a trusted branch or protected environment with short-lived workload identity where supported.
5. Publish a non-secret deployment manifest containing resource IDs, endpoints, image digest, environment, and commit provenance.
6. Deploy application workloads from immutable artifacts, run smoke/health checks, and preserve a rollback path.

Pull-request validation must not authenticate to cloud accounts or create infrastructure. Production apply must require environment protection/approval and least-privilege permissions.

## State and secrets

- Terraform state is a sensitive data store even when outputs are marked sensitive. Use remote state encryption, versioning, access control, and locking.
- Backend bootstrap resources must be provisioned separately from the state they store.
- Never commit state, plan files, credentials, private keys, real tfvars, or secret-bearing deployment outputs.
- Prefer OIDC/federated identity for GitHub Actions, GitLab, and Azure Pipelines where supported. Avoid client secrets and static service-account keys.
- Infrastructure outputs consumed by CI/CD must exclude passwords, connection strings, tokens, and secret values. Export secret references instead.
- Secret values must not be echoed to logs or included in downloadable artifacts.

## Naming and configuration

Keep service/environment/region and workload choices in typed provider variables or parameter files. Keep CI configuration concerned with orchestration and identity, not cloud resource definitions. Provider-specific naming and constraints remain in the provider layer.

## Kubernetes standards

For Kubernetes workloads, the baseline should include:
- non-root containers, a read-only root filesystem where feasible, dropped Linux capabilities, seccomp, and explicit resource requests/limits;
- startup, readiness, and liveness probes with distinct purposes;
- graceful termination, disruption budgets, and topology spread/anti-affinity where availability requires it;
- namespace-scoped service accounts and workload identity; no static cloud credentials in Kubernetes Secrets;
- default-deny network policies where supported, explicit ingress/egress, and private control-plane access where practical;
- pinned image digests, signed/scanned images, and policy checks before deployment;
- separate cluster provisioning from application release and use GitOps for continuous reconciliation when appropriate.

These are reusable defaults, not unconditional settings: modules must allow intentional, documented exceptions where a workload requires them.

## Implementation status

This document describes the target contract. Provider templates and CI adapters are not considered production-ready until their configuration validates, their security controls are tested, and a disposable environment has completed a plan/apply/smoke-test/destroy lifecycle.
