# 跨账号、跨服务访问原理与标准方案

## 1. 为什么会有跨账号访问

Landing Zone 中通常会把不同职责拆到不同账号/订阅/项目，例如：

- 日志在安全账号。
- 网络在网络账号。
- 应用在业务账号。
- CI/CD 在自动化账号或 GitHub Actions。
- 镜像仓库在共享服务账号。

这时就需要跨账号、跨服务访问。

## 2. AWS 跨账号访问

### 2.1 核心机制

AWS 常用 IAM Role + STS AssumeRole。

原理：

1. 目标账号创建一个 Role。
2. Role 的 trust policy 信任来源账号、身份或 OIDC provider。
3. 来源身份调用 STS AssumeRole。
4. AWS 返回临时凭证。
5. 来源身份用临时凭证访问目标账号资源。

### 2.2 示例场景

```text
GitHub Actions -> OIDC -> AWS IAM Role -> Terraform apply -> workload account
```

### 2.3 最佳实践

- 不使用 root 用户。
- 不使用长期 AK/SK。
- trust policy 限制 repo、branch、environment。
- 权限策略限制到具体资源和动作。
- CloudTrail 记录 AssumeRole 和后续操作。

## 3. Azure 跨订阅访问

### 3.1 核心机制

Azure 常见方式：

- Microsoft Entra ID 统一身份。
- Service Principal / Managed Identity。
- Azure RBAC 在 subscription/resource group/resource scope 授权。
- GitHub Actions 可通过 OIDC federated credential 换取访问令牌。

### 3.2 示例场景

```text
GitHub Actions -> OIDC -> Entra App Federated Credential -> Azure Login -> Subscription RBAC -> Terraform apply
```

### 3.3 最佳实践

- 不存储 client secret。
- 使用 federated credential。
- 角色绑定尽量在 subscription/resource group，而不是 tenant root。
- 生产环境使用审批和环境保护规则。

## 4. GCP 跨项目访问

### 4.1 核心机制

GCP 常见方式：

- Workload Identity Federation。
- Service Account impersonation。
- IAM binding 绑定到 project/folder/org。
- Shared VPC 允许 service project 使用 host project 网络。

### 4.2 示例场景

```text
GitHub Actions -> OIDC -> Workload Identity Pool -> Service Account Impersonation -> GCP Project
```

### 4.3 最佳实践

- 不下载 service account key。
- 使用 Workload Identity Federation。
- 把 workload identity pool 放在专用项目中管理。
- service account 权限最小化。

## 5. 跨服务访问

### 5.1 典型例子

- 应用访问对象存储。
- EKS/AKS/GKE Pod 访问云数据库。
- Lambda/Function 访问消息队列。
- CI/CD 访问镜像仓库。

### 5.2 标准思路

不要把密钥写到环境变量里，而是使用 workload identity：

| 平台 | 推荐方式 |
|---|---|
| AWS EKS | IRSA / Pod Identity |
| Azure AKS | Workload Identity / Managed Identity |
| GCP GKE | Workload Identity Federation for GKE |
| CI/CD | OIDC/WIF |

## 6. 多云访问的统一抽象

在 OpenLZKit 中可以抽象成：

```yaml
access_bindings:
  - name: cicd-to-prod
    source:
      type: oidc
      provider: github
      subject: repo:org/repo:environment:prod
    target:
      cloud: aws
      account: app-prod
      role: cicd-deployer
    permissions:
      - terraform.apply
    conditions:
      branch: main
      approval_required: true
```

## 7. 常见错误

| 错误 | 风险 | 修正 |
|---|---|---|
| CI 保存 AK/SK | 泄露后长期有效 | OIDC/WIF 短期凭证 |
| trust policy 太宽 | 任意 repo 可假冒 | 限制 subject/audience |
| service account key 下载 | 密钥难轮换 | 使用 impersonation |
| 生产 owner 长期存在 | 越权风险 | JIT/PIM + 审计 |
| 跨账号访问无日志 | 事故难追踪 | 开启审计日志集中化 |
