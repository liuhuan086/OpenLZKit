# 多账号、多云、多角色如何管理

## 1. 核心思想

不要按“人”直接授权，要按“角色 + 范围 + 环境 + 时效”授权。

错误方式：

```text
张三是管理员，所以给所有账号 Administrator。
```

正确方式：

```text
张三属于 Platform Team。
他可以在 dev/test 执行平台维护。
生产环境只能通过 JIT/PIM 临时提权。
所有操作进入审计日志。
```

## 2. 权限模型

推荐四维模型：

```text
Principal = 谁
Role = 能做什么
Scope = 在哪里做
Condition = 什么条件下做
```

示例：

```text
Principal: github-actions:repo/openlzkit
Role: cicd-deployer
Scope: aws/dev-account, azure/dev-subscription, gcp/dev-project
Condition: branch == main && environment == dev && token == OIDC
```

## 3. 账号和角色分层

### 管理平面账号

- identity/account-management
- security/logging
- network/shared-services
- cicd/automation

### 工作负载账号

- app-dev
- app-test
- app-prod
- data-dev
- data-prod

### 沙箱账号

- sandbox-personal
- sandbox-team

## 4. 标准角色

| 角色 | 权限范围 | 适用对象 | 备注 |
|---|---|---|---|
| platform-admin | 平台资源管理 | 平台团队 | 生产建议 JIT |
| security-auditor | 安全日志只读 | 安全团队 | 不应有修改权限 |
| network-admin | 网络资源管理 | 网络团队 | 不能直接管理业务数据 |
| app-developer | 应用资源管理 | 研发团队 | 限定到 dev/test 或指定 prod 资源 |
| cicd-planner | IaC plan | CI/CD | 只读 + plan |
| cicd-deployer | IaC apply | CI/CD | 限定仓库、分支、环境 |
| break-glass-admin | 紧急管理 | 少数负责人 | MFA、审批、强审计 |
| finance-viewer | 成本只读 | 财务/负责人 | 只读 billing/cost |

## 5. 跨云角色映射

| 统一角色 | 阿里云 | AWS | 腾讯云 | Azure | GCP |
|---|---|---|---|---|---|
| platform-admin | RAM Role / CloudSSO 权限集 | IAM Role / Permission Set | CAM Role / 用户组策略 | Azure RBAC custom role | IAM custom role |
| security-auditor | ActionTrail/SLS/Config 只读角色 | SecurityAudit / ReadOnlyAccess | CloudAudit/CLS 只读角色 | Security Reader | Security Reviewer / Viewer |
| network-admin | VPC/CEN/TR scoped role | VPC/TransitGateway scoped role | VPC/CCN scoped role | Network Contributor | Compute Network Admin |
| app-developer | workload account scoped role | workload account role | workload account scoped role | RG/subscription scoped contributor | project scoped editor/custom |
| cicd-deployer | OIDC/Federation + RAM Role | AssumeRole / OIDC role | OIDC/Federation + CAM Role | Federated credential + RBAC | WIF + service account impersonation |

## 6. 多角色管理原则

### 6.1 权限不要跨层乱给

- 平台团队管理平台资源。
- 应用团队管理应用资源。
- 安全团队默认只读审计，不直接变更业务资源。
- 网络团队管理网络，但不拥有业务账号所有权。

### 6.2 生产权限必须更严格

生产环境至少要求：

- MFA 或 JIT/PIM。
- 审批流程。
- 操作审计。
- 只在有限时间内有效。
- 禁止永久 owner/admin。

### 6.3 CI/CD 不要用人类账号

CI/CD 必须使用机器身份，并且最好使用 OIDC/WIF 换取短期凭证。

### 6.4 Break-glass 账号要少而强审计

Break-glass 不是日常管理员，而是事故时使用的紧急通道。

要求：

- 独立账号或角色。
- MFA。
- 使用后自动告警。
- 定期演练。
- 定期轮换。

## 7. 权限矩阵示例

| Principal | Role | 阿里云 Scope | AWS Scope | 腾讯云 Scope | Azure Scope | GCP Scope | Condition |
|---|---|---|---|---|---|---|---|
| platform-team | platform-admin | Infrastructure 资源夹 | Infrastructure OU | Infrastructure 组织节点 | Platform MG | Common Folder | JIT for prod |
| security-team | security-auditor | Security 资源夹 | Security OU | Security 组织节点 | Management Sub | logging-project | read-only |
| app-team-a | app-developer | app-a dev/prod 账号 | app-a dev/prod accounts | app-a dev/prod 账号 | app-a subscriptions | app-a projects | prod via PR |
| github-actions | cicd-deployer | workload accounts | workload accounts | workload accounts | workload subs | workload projects | OIDC + main branch |

## 8. 在项目中的实现方式

可选的 `tools/` 生成器层（规划中）以 `blueprint.yaml` 声明意图，再生成各云 IaC；未启用时直接在 `multi-cloud/<cloud>/` 对应模块中实现同样的角色模型。`blueprint.yaml` 示例：

```yaml
roles:
  - name: cicd-deployer
    type: machine
    permissions: deploy
    auth: oidc
    scopes:
      - cloud: aws
        account: app-dev
      - cloud: azure
        subscription: app-dev
      - cloud: gcp
        project: app-dev
    conditions:
      branch: main
      environment: dev
```

生成输出：

- role-matrix.md
- provider-specific IAM/RBAC templates
- OPA policy warnings
