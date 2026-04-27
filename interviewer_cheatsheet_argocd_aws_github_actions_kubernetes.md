# Interviewer Cheat Sheet: Argo CD, AWS Costing, GitHub Actions, and Kubernetes

Use this as a practical interview guide. Each question includes the kind of answer a strong candidate should give.

##  “Tell me about yourself.”

I’m a senior DevOps and platform engineer with experience across AWS, Kubernetes/EKS, Terraform, ArgoCD, GitOps, and observability.

I’m comfortable owning a platform end to end: designing AWS infrastructure, managing it as code, deploying workloads, building pipelines, monitoring production, responding to incidents, improving security, and reducing cloud cost.

My style is practical and ownership-focused. I try to fix the system, not just the ticket. If I see repeated incidents, manual toil, poor visibility, weak IAM, or cloud waste, I aim to improve the platform so teams can move faster and safer.

### The winning message:
I understand the technical stack, I know how to operate it in production, I communicate clearly, and I improve the system over time.


---

## 1. Argo CD Interview Questions and Answers

### Q1. What is Argo CD?

**Answer:**
Argo CD is a GitOps continuous delivery tool for Kubernetes. It watches a Git repository and keeps the live Kubernetes cluster state aligned with the desired state defined in Git.

A strong answer should mention:

- Git is the source of truth.
- Argo CD continuously compares desired state and live state.
- It can automatically or manually sync changes.
- It supports Helm, Kustomize, plain YAML, Jsonnet, and plugins.

---

### Q2. What does GitOps mean?

**Answer:**
GitOps is an operating model where infrastructure and application configuration are stored declaratively in Git. Changes are made through pull requests, reviewed, merged, and then automatically applied to the environment.

Key points:

- Git provides audit history.
- Rollbacks are usually done by reverting Git commits.
- Access control moves from direct cluster access to Git permissions.
- The cluster should converge toward the desired state in Git.

---

### Q3. What is the difference between `Sync`, `Refresh`, and `Hard Refresh` in Argo CD?

**Answer:**

- **Refresh** checks Git and the cluster to compare desired and live state.
- **Sync** applies the desired state from Git to the cluster.
- **Hard Refresh** clears cached manifest data and forces Argo CD to regenerate manifests from source.

A strong candidate should know that refresh does not necessarily apply changes; sync does.

---

### Q4. What are `OutOfSync`, `Synced`, `Healthy`, and `Degraded` states?

**Answer:**

- **Synced:** Live cluster state matches Git.
- **OutOfSync:** Live cluster state differs from Git.
- **Healthy:** Resources are running as expected.
- **Degraded:** One or more resources are failing or unhealthy.

Important distinction:

- Sync status is about configuration drift.
- Health status is about runtime condition.

An app can be `Synced` but `Degraded` if the desired config was applied but the workload is failing.

---

### Q5. What is an Argo CD Application?

**Answer:**
An Argo CD `Application` is a custom resource that defines:

- The Git repository source.
- The path, chart, or manifest location.
- The destination cluster and namespace.
- Sync policy and options.

Example fields:

```yaml
spec:
  source:
    repoURL: https://github.com/example/platform.git
    path: apps/payments
    targetRevision: main
  destination:
    server: https://kubernetes.default.svc
    namespace: payments
```

---

### Q6. What is the difference between manual sync and automated sync?

**Answer:**

- **Manual sync:** An operator approves and triggers deployment.
- **Automated sync:** Argo CD automatically applies changes when Git changes.

Automated sync can also include:

```yaml
syncPolicy:
  automated:
    prune: true
    selfHeal: true
```

- `prune: true` removes resources that no longer exist in Git.
- `selfHeal: true` reverts manual cluster changes back to Git state.

---

### Q7. What is pruning in Argo CD?

**Answer:**
Pruning means deleting Kubernetes resources from the cluster when they have been removed from Git.

Important warning:

Pruning is powerful but risky. A bad Git change can delete production resources if guardrails are weak.

Good controls include:

- Pull request review.
- Sync windows.
- Resource exclusions.
- AppProject restrictions.
- Manual approval for production.

---

### Q8. What is self-healing in Argo CD?

**Answer:**
Self-healing means Argo CD detects manual changes made directly in the cluster and reverts them back to the desired state in Git.

Example:

If someone manually changes a deployment replica count from `3` to `1`, Argo CD can change it back to `3` if Git says `3`.

---

### Q9. How do you manage secrets with Argo CD?

**Answer:**
Secrets should not be stored as plain text in Git.

Common approaches:

- External Secrets Operator with AWS Secrets Manager, Parameter Store, Vault, or GCP Secret Manager.
- Sealed Secrets.
- SOPS with KMS, age, or PGP.
- Argo CD Vault Plugin.

A strong answer should explain secret rotation, RBAC, encryption, and avoiding secret exposure in logs or rendered manifests.

---

### Q10. How would you promote an application from dev to staging to production with Argo CD?

**Answer:**
Common promotion models include:

- Separate Git branches per environment.
- Separate folders per environment.
- Helm values files per environment.
- Kustomize overlays per environment.
- Image tag promotion through pull requests.

Example structure:

```text
environments/
  dev/
  staging/
  prod/
```

A mature answer should mention that production changes should be reviewed, auditable, and reversible.

---

### Q11. How do you troubleshoot an Argo CD app stuck in `Progressing`?

**Answer:**
Check:

1. Argo CD application health details.
2. Kubernetes deployment rollout status.
3. Pod events.
4. Image pull errors.
5. Readiness and liveness probes.
6. Resource limits and scheduling issues.
7. CRDs or hooks that may be blocking sync.

Useful commands:

```bash
argocd app get <app-name>
kubectl describe deploy <deployment> -n <namespace>
kubectl get events -n <namespace> --sort-by=.lastTimestamp
kubectl logs -n <namespace> deploy/<deployment>
```

---

### Q12. What are Argo CD sync waves and hooks?

**Answer:**
Sync waves and hooks control deployment order.

- **Sync waves** order resources by annotation.
- **Hooks** run jobs or actions before, during, or after sync.

Example:

```yaml
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "1"
```

Common use cases:

- Apply CRDs before custom resources.
- Run database migrations before deployment.
- Run smoke tests after deployment.

---

### Q13. What is an Argo CD AppProject?

**Answer:**
An `AppProject` defines boundaries for applications.

It can restrict:

- Which Git repositories are allowed.
- Which clusters are allowed.
- Which namespaces are allowed.
- Which Kubernetes resource types can be deployed.

This is important for multi-team and production environments.

---

### Q14. What is the App of Apps pattern?

**Answer:**
The App of Apps pattern uses one parent Argo CD application to manage multiple child applications.

Benefits:

- Bootstrap many apps from one entry point.
- Manage environments declaratively.
- Useful for platform-level cluster setup.

Risk:

A bad parent app change can impact many child apps.

---

### Q15. What causes Argo CD drift?

**Answer:**
Common causes:

- Manual `kubectl` changes.
- Mutating admission webhooks.
- Controllers modifying fields.
- Defaulted Kubernetes fields.
- Helm chart rendering differences.
- Image tags like `latest`.
- Differences ignored or not ignored in Argo CD diff settings.

Good candidates should mention `ignoreDifferences` for expected controller-managed fields.

---

## 2. AWS Costing Interview Questions and Answers

### Q1. What are the main AWS cost drivers?

**Answer:**
Common AWS cost drivers include:

- EC2 compute.
- EBS volumes and snapshots.
- NAT Gateway data processing.
- Data transfer between AZs, regions, and the internet.
- RDS and database storage.
- S3 storage, requests, and retrieval.
- Load balancers.
- CloudWatch logs and metrics.
- Managed Kubernetes node groups and EKS control plane.

Strong candidates should know that network and observability costs are often overlooked.

---

### Q2. How would you reduce AWS costs without hurting reliability?

**Answer:**
Start with visibility, then optimize safely.

Steps:

1. Use Cost Explorer, CUR, tags, and budgets.
2. Find idle or underused resources.
3. Right-size EC2, RDS, and EBS.
4. Use Savings Plans or Reserved Instances for steady workloads.
5. Use Spot for fault-tolerant workloads.
6. Reduce NAT Gateway and cross-AZ traffic.
7. Apply S3 lifecycle policies.
8. Tune CloudWatch log retention.
9. Remove orphaned load balancers, volumes, snapshots, and Elastic IPs.
10. Validate changes with service owners before deleting resources.

---

### Q3. What is the difference between Reserved Instances and Savings Plans?

**Answer:**

- **Reserved Instances:** Commitment to a specific instance family, region, operating system, and tenancy depending on type.
- **Savings Plans:** Commitment to a dollar-per-hour spend level. More flexible than Reserved Instances.

Common answer:

Use Savings Plans for flexible compute savings. Use Reserved Instances where specific long-term capacity and service coverage make sense.

---

### Q4. What are common hidden AWS costs?

**Answer:**

- NAT Gateway hourly and per-GB charges.
- Cross-AZ data transfer.
- Inter-region data transfer.
- CloudWatch log ingestion and retention.
- EBS snapshots.
- Idle load balancers.
- Unattached EBS volumes.
- Elastic IPs not attached to running instances.
- S3 request and retrieval charges.
- VPC endpoints and PrivateLink.

---

### Q5. How do tags help with AWS cost management?

**Answer:**
Tags help allocate costs by team, application, environment, owner, or cost center.

Example tags:

```text
Environment = prod
Application = payments
Owner = platform-team
CostCenter = finance-123
```

Strong answer:

Tags must be enforced through policy, automation, and reporting. Optional tagging usually becomes unreliable.

---

### Q6. How would you investigate a sudden AWS bill increase?

**Answer:**

1. Check Cost Explorer by service, region, linked account, usage type, and tag.
2. Compare current spend against the previous period.
3. Check recent deployments and infrastructure changes.
4. Review high-cardinality services like CloudWatch, NAT Gateway, EC2, S3, and data transfer.
5. Look for runaway logs, new traffic patterns, scaling events, or backup growth.
6. Contact the owning team with evidence.
7. Put temporary guardrails in place if spend is actively growing.

---

### Q7. How do you reduce NAT Gateway costs?

**Answer:**

Options include:

- Use VPC endpoints for S3, DynamoDB, ECR, CloudWatch, STS, and other AWS services.
- Keep traffic inside the VPC where possible.
- Avoid routing high-volume internal traffic through NAT.
- Place workloads in public subnets only when appropriate and secure.
- Reduce unnecessary package downloads from private subnets.
- Cache dependencies.

Be careful: replacing NAT with NAT instances can reduce cost but adds operational responsibility.

---

### Q8. How do you control Kubernetes costs on AWS?

**Answer:**

- Right-size node groups.
- Use Cluster Autoscaler or Karpenter.
- Use requests and limits properly.
- Use Spot for suitable workloads.
- Bin-pack workloads efficiently.
- Clean up unused namespaces, PVCs, and load balancers.
- Watch EBS volume growth.
- Avoid over-provisioned requests.
- Review idle dev and test clusters.
- Use cost tools such as Kubecost or OpenCost.

---

### Q9. What is AWS Cost and Usage Report?

**Answer:**
The AWS Cost and Usage Report, often called CUR, is a detailed billing dataset that can be delivered to S3. It gives line-item cost and usage details that can be queried with Athena or loaded into reporting tools.

A strong answer should say CUR is better than simple billing dashboards for deep analysis.

---

### Q10. What is the difference between cost optimization and cost cutting?

**Answer:**

- **Cost cutting** removes spend, sometimes blindly.
- **Cost optimization** improves value per dollar while preserving reliability, performance, security, and delivery speed.

A senior answer should include risk management and stakeholder alignment.

---

## 3. GitHub Actions Interview Questions and Answers

### Q1. What is GitHub Actions?

**Answer:**
GitHub Actions is a CI/CD and automation platform built into GitHub. It runs workflows triggered by events such as pull requests, pushes, releases, schedules, or manual dispatches.

---

### Q2. What are workflows, jobs, steps, and actions?

**Answer:**

- **Workflow:** The full automation file in `.github/workflows`.
- **Job:** A group of steps that runs on a runner.
- **Step:** An individual command or action.
- **Action:** A reusable unit of automation.

Example:

```yaml
name: CI
on: [push]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm test
```

---

### Q3. What is the difference between GitHub-hosted and self-hosted runners?

**Answer:**

- **GitHub-hosted runners:** Managed by GitHub. Easy to use, ephemeral, less operational burden.
- **Self-hosted runners:** Managed by your team. More control, access to private networks, custom tooling, and potentially lower cost at scale.

Risks with self-hosted runners:

- Secret exposure.
- Persistence between jobs if not cleaned.
- Network access risk.
- Patching and scaling responsibility.

---

### Q4. How do you secure GitHub Actions secrets?

**Answer:**

- Store secrets in GitHub encrypted secrets or external secret managers.
- Use environment protection rules.
- Avoid printing secrets in logs.
- Use least-privilege tokens.
- Prefer OpenID Connect to cloud providers instead of long-lived static credentials.
- Restrict workflows from forks.
- Pin third-party actions.

---

### Q5. What is GitHub Actions OIDC and why is it useful?

**Answer:**
OIDC lets GitHub Actions request short-lived cloud credentials from providers like AWS without storing long-lived AWS keys in GitHub.

Benefits:

- No static cloud keys in GitHub.
- Short-lived credentials.
- Conditions can restrict access by repo, branch, workflow, or environment.

---

### Q6. How would you deploy to AWS from GitHub Actions securely?

**Answer:**

Recommended approach:

1. Configure GitHub OIDC provider in AWS IAM.
2. Create an IAM role with least privilege.
3. Restrict the trust policy to the expected repo, branch, or environment.
4. Use `aws-actions/configure-aws-credentials`.
5. Deploy using IaC or application deployment commands.

Example:

```yaml
permissions:
  id-token: write
  contents: read

steps:
  - uses: actions/checkout@v4
  - uses: aws-actions/configure-aws-credentials@v4
    with:
      role-to-assume: arn:aws:iam::123456789012:role/github-deploy-role
      aws-region: eu-west-1
```

---

### Q7. How do you speed up GitHub Actions workflows?

**Answer:**

- Use dependency caching.
- Split jobs and run them in parallel.
- Use matrix builds carefully.
- Avoid unnecessary workflow triggers.
- Use path filters.
- Use smaller Docker images.
- Avoid repeated package downloads.
- Reuse workflows.
- Use self-hosted runners for heavier workloads.

---

### Q8. What is a matrix strategy?

**Answer:**
A matrix strategy runs the same job across multiple combinations, such as operating systems, language versions, or regions.

Example:

```yaml
strategy:
  matrix:
    node-version: [18, 20, 22]
```

Useful for testing compatibility.

---

### Q9. How do you prevent multiple deployments from racing each other?

**Answer:**
Use concurrency groups.

Example:

```yaml
concurrency:
  group: production-deploy
  cancel-in-progress: false
```

This prevents overlapping production deployments.

---

### Q10. How do you protect production deployments?

**Answer:**

- Use GitHub environments.
- Require approvals.
- Restrict deployment branches.
- Use OIDC with environment-specific IAM roles.
- Use deployment locks or concurrency.
- Use canary or blue-green deployment patterns.
- Require tests and security scans before deployment.

---

### Q11. What can go wrong with GitHub Actions in production pipelines?

**Answer:**

- Secrets leaked in logs.
- Over-permissive `GITHUB_TOKEN`.
- Unpinned third-party actions.
- Race conditions between deployments.
- Flaky tests blocking releases.
- Missing rollback path.
- Self-hosted runner compromise.
- Pull request workflows from forks accessing sensitive context.

---

### Q12. What does `permissions` do in a workflow?

**Answer:**
`permissions` controls what the `GITHUB_TOKEN` can do.

Example:

```yaml
permissions:
  contents: read
  pull-requests: write
  id-token: write
```

A strong answer should mention least privilege. Avoid giving broad write permissions by default.

---

## 4. Kubernetes Interview Questions and Answers

### Q1. What is Kubernetes?

**Answer:**
Kubernetes is a container orchestration platform. It schedules, runs, scales, and manages containerized applications across a cluster of nodes.

Core features:

- Scheduling.
- Service discovery.
- Scaling.
- Self-healing.
- Rolling updates.
- Configuration and secret management.

---

### Q2. What is the difference between a Pod, Deployment, ReplicaSet, and StatefulSet?

**Answer:**

- **Pod:** Smallest deployable unit. Usually contains one main container.
- **ReplicaSet:** Keeps a desired number of pod replicas running.
- **Deployment:** Manages ReplicaSets and rolling updates for stateless apps.
- **StatefulSet:** Manages stateful apps with stable network identity and persistent storage.

---

### Q3. What happens when you create a Deployment?

**Answer:**

1. The API server receives the request.
2. The deployment controller creates a ReplicaSet.
3. The ReplicaSet creates Pods.
4. The scheduler assigns Pods to nodes.
5. Kubelet pulls images and starts containers.
6. Controllers monitor and reconcile desired state.

---

### Q4. What is the Kubernetes control plane?

**Answer:**
The control plane manages the cluster.

Main components:

- **API server:** Front door to the cluster.
- **etcd:** Stores cluster state.
- **Scheduler:** Assigns pods to nodes.
- **Controller manager:** Runs controllers that reconcile state.
- **Cloud controller manager:** Integrates with cloud provider APIs.

---

### Q5. What is the difference between a Service and an Ingress?

**Answer:**

- **Service:** Provides stable networking for pods inside the cluster.
- **Ingress:** Provides HTTP/HTTPS routing from outside the cluster to services.

Common service types:

- `ClusterIP`: Internal only.
- `NodePort`: Exposes service on each node port.
- `LoadBalancer`: Creates an external load balancer through the cloud provider.

---

### Q6. What is a readiness probe?

**Answer:**
A readiness probe tells Kubernetes whether a pod is ready to receive traffic.

If readiness fails, the pod stays running but is removed from service endpoints.

Use case:

Do not send traffic to a pod until it has loaded config, connected to dependencies, or warmed up.

---

### Q7. What is a liveness probe?

**Answer:**
A liveness probe tells Kubernetes whether a container should be restarted.

If liveness fails, kubelet restarts the container.

Important warning:

A bad liveness probe can cause restart loops and make an outage worse.

---

### Q8. What is a startup probe?

**Answer:**
A startup probe gives slow-starting applications extra time to initialize before liveness checks begin.

Useful for:

- JVM apps.
- Large containers.
- Apps with long migrations.
- Legacy services with slow startup.

---

### Q9. What are resource requests and limits?

**Answer:**

- **Requests:** Minimum resources Kubernetes uses for scheduling.
- **Limits:** Maximum resources a container can use.

CPU behavior:

- CPU above limit is throttled.

Memory behavior:

- Memory above limit can cause OOM kill.

Senior answer:

Bad requests cause poor bin-packing. Bad limits can create instability.

---

### Q10. What is an OOMKilled pod?

**Answer:**
An `OOMKilled` pod means the container exceeded its memory limit or the node ran out of memory and the process was killed.

Troubleshooting:

```bash
kubectl describe pod <pod> -n <namespace>
kubectl top pod -n <namespace>
kubectl logs <pod> -n <namespace> --previous
```

---

### Q11. What is a CrashLoopBackOff?

**Answer:**
`CrashLoopBackOff` means a container keeps starting, crashing, and being restarted with increasing delay.

Common causes:

- Bad config.
- Missing secret or config map.
- Application bug.
- Failed dependency.
- Bad command or entrypoint.
- Permission issue.
- Liveness probe too aggressive.

---

### Q12. How do you troubleshoot a pod stuck in Pending?

**Answer:**
Check scheduling constraints.

Useful commands:

```bash
kubectl describe pod <pod> -n <namespace>
kubectl get nodes
kubectl describe node <node>
kubectl get events -n <namespace> --sort-by=.lastTimestamp
```

Common causes:

- Not enough CPU or memory.
- Node selector mismatch.
- Taints without tolerations.
- PVC not bound.
- Image pull secret issues.
- Pod anti-affinity too strict.

---

### Q13. How do you troubleshoot `ImagePullBackOff`?

**Answer:**
Common causes:

- Wrong image name or tag.
- Image does not exist.
- Registry authentication failure.
- Network issue to registry.
- Rate limiting.

Commands:

```bash
kubectl describe pod <pod> -n <namespace>
kubectl get secret -n <namespace>
```

---

### Q14. What is a ConfigMap?

**Answer:**
A ConfigMap stores non-sensitive configuration data.

Examples:

- Environment variables.
- Config files.
- Feature flags.

Do not use ConfigMaps for passwords, tokens, or private keys.

---

### Q15. What is a Secret?

**Answer:**
A Secret stores sensitive data such as passwords, tokens, and certificates.

Important note:

Kubernetes Secrets are base64-encoded by default, not automatically strongly encrypted unless encryption at rest is configured.

---

### Q16. What is a DaemonSet?

**Answer:**
A DaemonSet ensures a copy of a pod runs on selected nodes, often every node.

Common uses:

- Log agents.
- Monitoring agents.
- CNI plugins.
- Security agents.
- Node-level proxies.

---

### Q17. What is a Job and CronJob?

**Answer:**

- **Job:** Runs a task to completion.
- **CronJob:** Runs Jobs on a schedule.

Use cases:

- Backups.
- Reports.
- Data imports.
- Batch processing.

---

### Q18. What is a PersistentVolume and PersistentVolumeClaim?

**Answer:**

- **PersistentVolume:** Cluster storage resource.
- **PersistentVolumeClaim:** User request for storage.

PVCs let pods request storage without needing to know the exact backend implementation.

---

### Q19. What is RBAC in Kubernetes?

**Answer:**
RBAC controls who can do what in the cluster.

Main objects:

- Role.
- ClusterRole.
- RoleBinding.
- ClusterRoleBinding.
- ServiceAccount.

Good answer:

Use least privilege. Avoid giving broad `cluster-admin` permissions.

---

### Q20. What is a NetworkPolicy?

**Answer:**
A NetworkPolicy controls pod-to-pod and pod-to-external network traffic.

Important:

NetworkPolicies only work if the CNI plugin supports them.

Use cases:

- Restrict database access.
- Isolate namespaces.
- Limit blast radius after compromise.

---

## 5. Cross-Topic Scenario Questions

### Q1. A GitHub Actions workflow deploys a change, Argo CD says `Synced`, but users report errors. What do you check?

**Answer:**

1. Confirm what changed in Git.
2. Check Argo CD health, not just sync status.
3. Check Kubernetes rollout and pods.
4. Check logs, metrics, and events.
5. Check readiness probes and service endpoints.
6. Confirm image tag and digest.
7. Check config maps and secrets.
8. Validate ingress, service, DNS, and external dependencies.
9. Roll back by reverting Git or deploying a previous known-good version.

Key insight:

`Synced` does not mean the app is working. It only means the live manifests match Git.

---

### Q2. AWS cost increased after moving workloads to Kubernetes. Why?

**Answer:**
Possible causes:

- Over-provisioned node groups.
- High pod resource requests.
- Too many load balancers.
- Unused PVCs and EBS volumes.
- Cross-AZ traffic between pods and databases.
- NAT Gateway data processing.
- Increased CloudWatch logs.
- Multiple non-production clusters running 24/7.
- Inefficient autoscaling.

---

### Q3. A production deployment should be safe and auditable. What design would you propose?

**Answer:**

- GitHub pull request required for every change.
- CI runs tests, security scans, and image builds.
- Image is tagged immutably with commit SHA.
- GitOps repo is updated by automation or reviewed PR.
- Argo CD deploys from Git.
- Production has manual approval or sync window.
- Rollback is done by reverting Git.
- Monitoring validates rollout health.
- Cloud costs are tagged by app, team, and environment.

---

## Appendix: Top 10 Troubleshooting Production Issues

### 1. Pods are in `CrashLoopBackOff`

**Symptoms:**

- Pods restart repeatedly.
- Deployment never becomes healthy.
- Argo CD may show `Degraded`.

**Likely causes:**

- Bad config.
- Missing secret.
- Application bug.
- Wrong command or entrypoint.
- Dependency unavailable.
- Liveness probe too aggressive.

**Commands:**

```bash
kubectl get pods -n <namespace>
kubectl describe pod <pod> -n <namespace>
kubectl logs <pod> -n <namespace>
kubectl logs <pod> -n <namespace> --previous
```

**Good fix approach:**

- Read previous logs first.
- Check recent deploy diff.
- Validate env vars, config maps, and secrets.
- Roll back quickly if customer impact is high.

---

### 2. Pods are stuck in `Pending`

**Symptoms:**

- Pods are created but not scheduled.
- No containers start.

**Likely causes:**

- Not enough CPU or memory.
- Taints and tolerations mismatch.
- Node selector or affinity mismatch.
- PVC not bound.
- Cluster autoscaler not scaling.

**Commands:**

```bash
kubectl describe pod <pod> -n <namespace>
kubectl get nodes
kubectl get events -n <namespace> --sort-by=.lastTimestamp
```

**Good fix approach:**

- Read scheduler events.
- Compare requested resources with available node capacity.
- Check autoscaler logs.
- Relax constraints only if safe.

---

### 3. `ImagePullBackOff` or `ErrImagePull`

**Symptoms:**

- Pod cannot pull container image.

**Likely causes:**

- Wrong image tag.
- Image not pushed.
- Registry credentials missing.
- Registry outage.
- Network or DNS issue.

**Commands:**

```bash
kubectl describe pod <pod> -n <namespace>
kubectl get secret -n <namespace>
```

**Good fix approach:**

- Confirm exact image name and tag.
- Prefer immutable image digests or commit SHA tags.
- Check GitHub Actions image build and push logs.

---

### 4. Service returns 503 or no endpoints

**Symptoms:**

- Ingress or load balancer returns 503.
- Service has no ready endpoints.

**Likely causes:**

- Readiness probe failing.
- Label selector mismatch.
- Pods not running.
- Target port mismatch.

**Commands:**

```bash
kubectl get svc -n <namespace>
kubectl describe svc <service> -n <namespace>
kubectl get endpoints <service> -n <namespace>
kubectl get pods -n <namespace> --show-labels
```

**Good fix approach:**

- Match service selector to pod labels.
- Check readiness probe.
- Confirm container port and service target port.

---

### 5. Deployment rollout is stuck

**Symptoms:**

- New ReplicaSet does not become available.
- Old pods may still serve traffic.

**Likely causes:**

- Readiness failure.
- Insufficient resources.
- PodDisruptionBudget constraints.
- Bad image or config.
- Application startup too slow.

**Commands:**

```bash
kubectl rollout status deploy/<deployment> -n <namespace>
kubectl describe deploy <deployment> -n <namespace>
kubectl get rs -n <namespace>
kubectl get events -n <namespace> --sort-by=.lastTimestamp
```

**Good fix approach:**

- Check new ReplicaSet pods.
- Compare current and previous revision.
- Roll back if the new version is broken.

---

### 6. Argo CD app is `OutOfSync`

**Symptoms:**

- Argo CD reports drift between Git and cluster.

**Likely causes:**

- Manual cluster changes.
- Controller-mutated fields.
- Missing prune.
- Helm or Kustomize rendering differences.
- Failed sync.

**Commands:**

```bash
argocd app get <app-name>
argocd app diff <app-name>
argocd app history <app-name>
```

**Good fix approach:**

- Identify whether drift is expected or dangerous.
- Revert manual changes through Git.
- Use `ignoreDifferences` only for fields that are safely controller-managed.

---

### 7. Argo CD sync fails

**Symptoms:**

- Sync operation errors.
- Resources are not applied.

**Likely causes:**

- Invalid manifest.
- Missing CRD.
- RBAC denied.
- Namespace missing.
- Admission webhook rejection.
- Immutable field change.

**Commands:**

```bash
argocd app get <app-name>
argocd app sync <app-name>
kubectl get events -A --sort-by=.lastTimestamp
```

**Good fix approach:**

- Read the exact sync error.
- Validate manifests locally.
- Confirm CRDs are installed before custom resources.
- For immutable field errors, recreate only when safe.

---

### 8. Production cost spike

**Symptoms:**

- AWS spend suddenly increases.
- Budget alerts fire.

**Likely causes:**

- NAT Gateway traffic increase.
- CloudWatch log storm.
- Cross-AZ or inter-region traffic.
- Runaway autoscaling.
- Unused resources left running.
- Backup or snapshot growth.

**Commands and checks:**

```text
AWS Cost Explorer: Group by Service, Usage Type, Region, Linked Account, Tag
CloudWatch Logs: Check ingestion volume and retention
EC2/EBS: Check unattached volumes and old snapshots
Kubernetes: Check node count, PVCs, and load balancers
```

**Good fix approach:**

- Identify the service and usage type first.
- Stop active runaway spend.
- Avoid deleting unknown production resources without owner confirmation.

---

### 9. GitHub Actions deployment failed

**Symptoms:**

- Workflow red.
- Image not pushed.
- Deployment did not happen.

**Likely causes:**

- Broken tests.
- Secret or OIDC permission issue.
- Expired token.
- Bad workflow syntax.
- Registry unavailable.
- AWS IAM trust policy mismatch.

**Checks:**

```text
Workflow logs
Changed workflow YAML
OIDC role trust policy
Repository and environment secrets
Cloud provider audit logs
Container registry logs
```

**Good fix approach:**

- Find the first failing step.
- Confirm whether the failure is build, test, auth, deploy, or post-deploy validation.
- Avoid rerunning blindly if the workflow has side effects.

---

### 10. Application latency or error rate increased after deployment

**Symptoms:**

- Higher 5xx responses.
- Increased p95 or p99 latency.
- Customer complaints.
- Autoscaling may increase replicas.

**Likely causes:**

- Bad application release.
- Dependency latency.
- CPU throttling.
- Memory pressure or garbage collection.
- Database connection pool exhaustion.
- Cross-AZ network path change.
- Misconfigured readiness probe.

**Commands and checks:**

```bash
kubectl top pods -n <namespace>
kubectl describe pod <pod> -n <namespace>
kubectl logs deploy/<deployment> -n <namespace>
kubectl rollout history deploy/<deployment> -n <namespace>
```

**Good fix approach:**

- Compare metrics before and after deployment.
- Check saturation: CPU, memory, database, network, queue depth.
- Roll back first if customer impact is severe.
- Investigate root cause after stabilizing service.

---

## Final Interview Evaluation Signals

### Strong Candidate Signals

- Explains tradeoffs, not just commands.
- Knows the difference between desired state and runtime health.
- Understands cloud cost drivers beyond EC2.
- Uses least privilege for CI/CD and Kubernetes RBAC.
- Thinks in rollback, observability, and blast-radius control.
- Troubleshoots from symptoms to evidence.

### Weak Candidate Signals

- Says `Synced` means healthy.
- Stores cloud keys directly in GitHub secrets without mentioning OIDC.
- Ignores NAT Gateway, logs, and data transfer costs.
- Uses `latest` tags in production.
- Gives everyone `cluster-admin`.
- Deletes resources during cost incidents without checking ownership.
- Reruns failed deployments without understanding side effects.

---

## Quick Command Reference

```bash
# Kubernetes basics
kubectl get pods -A
kubectl describe pod <pod> -n <namespace>
kubectl logs <pod> -n <namespace>
kubectl logs <pod> -n <namespace> --previous
kubectl get events -n <namespace> --sort-by=.lastTimestamp
kubectl rollout status deploy/<deployment> -n <namespace>
kubectl rollout history deploy/<deployment> -n <namespace>
kubectl top pods -n <namespace>
kubectl top nodes

# Argo CD basics
argocd app list
argocd app get <app-name>
argocd app diff <app-name>
argocd app sync <app-name>
argocd app history <app-name>

# AWS cost investigation checklist
# Use Cost Explorer grouped by:
# - Service
# - Usage Type
# - Region
# - Account
# - Tag

# GitHub Actions checks
# Review workflow logs, OIDC trust policy, environment approvals, and deployment history.
```



## Docker Interview Answer

I use Docker to create repeatable application runtime environments. I care about small images, clear Dockerfiles, pinned base images, non-root users where possible, health checks, and fast rebuilds.

In CI/CD, I build the image, tag it with the commit SHA, scan it, push it to a registry such as ECR, then deploy that immutable image through Kubernetes or GitOps.

## Kubernetes Interview Answer

When troubleshooting Kubernetes, I start from the workload and move outward. I check pod status, events, logs, image pulls, probes, resource pressure, service selectors, endpoints, ingress, DNS, and then cloud-specific items such as IAM, security groups, and load balancer target health.

I try to identify whether the issue is application, scheduling, networking, configuration, permissions, or platform capacity.

## EKS Interview Answer

In EKS, I look at both Kubernetes and AWS layers. For a workload problem, I check pods, events, logs, services, endpoints, ingress, and DNS. Then I check AWS-specific pieces such as IRSA, security groups, subnet routing, load balancer target groups, ECR permissions, and CloudWatch/controller logs.

The main thing is to isolate whether the failure is application, cluster, networking, IAM, or AWS integration.

## Terraform Interview Answer

I treat Terraform as production code. I use remote state with locking, clear module boundaries, provider pinning, pull request reviews, plan output in CI, and separate state per environment.

For risky changes, I break them into smaller applies and avoid manual console changes. If drift exists, I either bring the change back into code or import the resource cleanly.

### How do you manage multiple environments?

I usually use reusable modules and thin environment layers for dev, staging, and production. Each environment has separate state. Shared modules are versioned. Promotion happens through pull requests by changing module versions or variables, not by manually copying infrastructure.

### What do you do if state is wrong?

First I avoid making it worse. I inspect the current state, compare it with real cloud resources, and decide whether to import, move, remove, or recreate state entries. For production, I take a backup of state before any state operation.

## ArgoCD Interview Answer

With ArgoCD, I want the cluster state to match Git. If someone changes production manually, ArgoCD detects drift. Depending on policy, it can either alert or self-heal.

For production, I prefer controlled sync with approvals, clear promotion flow, and rollback through Git by reverting the commit or changing the Helm chart version.

### Manual Change Question

#### Question:
What happens if someone changes a Kubernetes resource manually?

#### Answer:
ArgoCD marks the app as out of sync because the live state differs from Git. If self-heal is enabled, ArgoCD can revert the manual change. If not, it reports drift so the team can decide whether the manual change should be codified or rolled back.

## GitHub Actions Interview Answer

A typical CI/CD flow I would build runs tests and linting on pull requests, builds and scans the container image, pushes it to ECR after merge, runs Terraform plan for infrastructure changes, requires approval for production applies, and updates the GitOps repo or Helm values so ArgoCD deploys the new image.

For AWS access, I prefer GitHub OIDC into AWS instead of long-lived static access keys.

## Prometheus and Grafana

I avoid dashboards that just look busy. I focus on service health, SLOs, error rate, latency, saturation, Kubernetes capacity, and actionable alerts.

A good alert should tell the engineer what is broken, how bad it is, who owns it, and where to start.

## EKS Example Cost Answers

For EKS cost optimisation, I look at node utilisation, pod requests vs actual usage, idle workloads, autoscaling behaviour, storage, NAT gateway traffic, and logging volume.

Common wins are rightsizing requests, using Karpenter or Cluster Autoscaler, using Spot for suitable workloads, cleaning unused EBS volumes and load balancers, and reducing noisy logs.

I usually split savings into quick cleanup and structural optimisation. Quick cleanup includes idle resources, old snapshots, unused EBS volumes, and log retention. Structural optimisation includes right-sizing, Savings Plans, autoscaling, better tagging, and chargeback/showback.

## Incident Interview Answer

During an incident, my first priority is service restoration and clear communication. I confirm impact, assign roles, start a timeline, check recent changes, and look for the fastest safe mitigation such as rollback, scaling, disabling a bad path, or routing around the issue.

After recovery, I focus on root cause, prevention, alert quality, runbook updates, and reducing the chance of repeat incidents.

### A. First 10 Minutes

1. Confirm the incident.
2. Check user impact.
3. Identify affected services.
4. Open an incident channel.
5. Assign incident lead.
6. Start timeline notes.
7. Stabilise before deep root cause.
8. Roll back if the change is likely the cause.
9. Communicate clearly.
10. Preserve evidence.

## Core Message

I can own an AWS/EKS platform end to end. I understand infrastructure, CI/CD, GitOps, observability, security, cost, and incident response. I do not just close tickets; I improve the platform.

## Strongest Phrases

- I treat infrastructure as production code.
- I prefer GitOps because it gives clear desired state and drift detection.
- I use short-lived credentials and least privilege access.
- I troubleshoot from workload outward, then into the AWS layer.
- I focus monitoring on user impact and actionable alerts.
- I look for repeatable patterns, not one-off fixes.
- I measure improvements with reliability, cost, speed, or risk reduction.

# My Questions

## Best questions to ask first

1. Platform ownership
“What would you expect this person to own in the first 3 to 6 months?”
This shows you are thinking beyond tickets.

2. Current platform state
“How mature is the current AWS/EKS platform? Is the work more greenfield, improvement of an existing platform, or operational support?”
This helps you understand whether they need a builder, fixer, or operator.

3. Biggest pain points
“What are the biggest reliability, delivery, security, or cost challenges the team is dealing with right now?”
This is one of the best senior-level questions.

4. Success criteria
“What would make you say after 6 months that hiring me was the right decision?”
This gets them to define success clearly.

5. Team expectations
“How much autonomy would this role have to make platform improvements or recommend changes?”
This tests whether they truly want a senior engineer or just another pair of hands.

AWS / EKS questions
6. EKS operating model
“How are your EKS clusters currently managed — Terraform, eksctl, manual setup, or another pattern?”

7. Cluster maturity
“Do you have standard patterns for ingress, autoscaling, secrets, observability, and workload IAM, or is part of the role to help define those?”

8. Upgrade process
“How do you currently handle EKS and Kubernetes version upgrades?”

9. Autoscaling
“Are you using Cluster Autoscaler, Karpenter, managed node groups, Fargate, or a mix?”

10. Multi-account setup
“How is AWS account structure organised across dev, staging, production, shared services, and client environments?”

Terraform questions

11. Terraform workflow
“What does your Terraform workflow look like today — local applies, CI/CD plans, approval gates, remote state, and locking?”

12. Module maturity
“Do you have mature internal Terraform modules, or would this role help standardise and improve them?”

13. Drift
“How do you currently detect and handle infrastructure drift?”

ArgoCD / GitOps questions

14. GitOps maturity
“How far along are you with GitOps? Is ArgoCD already standardised across environments?”

15. Deployment flow
“How does code move from pull request to production today?”

16. Rollback
“What is the normal rollback process for applications and infrastructure changes?”

GitHub Actions / CI/CD questions

17. CI/CD ownership
“Who owns CI/CD pipelines today — platform, application teams, or a shared model?”

18. Production approvals
“How are production deployments approved and audited?”

19. AWS credentials
“Are GitHub Actions using OIDC into AWS, or are there still static credentials that need to be migrated?”
This is a sharp senior question.

Monitoring / incident response questions

20. Observability
“What observability stack are you using today, and how confident are you in the current alert quality?”

21. Incidents
“What does incident response look like? Do you have runbooks, ownership, severity levels, and post-incident reviews?”

22. Alert fatigue
“Is alert noise or lack of useful alerts currently a problem?”

23. SLOs
“Do teams work with SLOs or error budgets, or is monitoring mostly infrastructure-level today?”

Security questions

24. IAM maturity
“How mature is your IAM model today? Are you using least privilege, cross-account roles, and workload identity patterns like IRSA?”

25. GuardDuty / WAF
“Are GuardDuty, Security Hub, WAF, and CloudTrail findings actively triaged, or is there work to operationalise them?”

26. Secrets
“How are secrets managed across CI/CD, Kubernetes, and AWS workloads?”

Cost optimisation questions

27. Cost visibility
“How visible is cloud spend today across teams, environments, and clients?”

28. Cost ownership
“Is cost optimisation an active part of the role, or more of an occasional improvement area?”

29. Current waste
“Are there known cost pain points around EKS nodes, NAT gateways, logging, storage, or idle environments?”

Team and working style questions

30. Team structure
“How is the platform team structured, and how does it interact with application teams?”

31. Senior expectations
“Where do you most need senior judgement from this role: architecture, incident response, delivery, mentoring, client communication, or platform standards?”

32. Decision-making
“How are technical decisions usually made and documented?”

33. Client-facing work
“How much direct client or stakeholder interaction is expected?”

34. Delivery pressure
“What usually causes the most delivery pressure for the team: incidents, project deadlines, client requests, technical debt, or unclear ownership?”

Culture and risk questions

35. Technical debt
“What areas of the platform have the most technical debt today?”

36. Improvement appetite
“Is the team in a place where it can invest in platform improvements, or is most work reactive right now?”

37. On-call
“Is there an on-call expectation? If so, how is it structured and how often are engineers paged?”

38. Documentation
“How good is the current documentation and runbook coverage?”

## Best final question
Ask this near the end:
“Based on what we’ve discussed, is there anything about my experience that you’d like me to clarify or go deeper on?”
This gives you a chance to fix doubts before the interview ends.

## Strong closing question
“What are the most important problems you’d want the successful candidate to help solve first?”
This leaves them picturing you already doing the job.

