# Google Cloud Landing Zone 设计

## 1. 定位

Google Cloud 在 OpenLZKit 中按 Organization、Folders、Projects、Cloud Identity/IAM、Organization Policy、Shared VPC、Cloud Logging 和 Security Command Center 的原生模型实现。当前仓库已具备基础模块和 live stack；后续深化应围绕 project factory、Org Policy、WIF、Shared VPC service project 和 SCC 导出。

## 2. 核心资源层级

```text
Organization
├── Folder: platform
│   ├── Project: audit-logs
│   ├── Project: shared-vpc-host
│   └── Project: cicd
├── Folder: dev
│   └── Project: dev-app
├── Folder: staging
│   └── Project: staging-app
└── Folder: prod
    └── Project: prod-app
```

## 3. 身份与权限

- 人类身份：Cloud IAM、Google Groups、Workforce Identity Federation。
- 机器身份：Service Account、Workload Identity Federation。
- CI/CD 推荐 OIDC/WIF，避免长期 service account key。
- 权限矩阵应区分 organization-level、folder-level、project-level 权限。

## 4. 网络设计

推荐采用 Shared VPC：

- Host Project 承载共享 VPC、子网、防火墙和路由。
- Service Project 承载业务 workload。
- 大型跨区域网络可后续映射到 Network Connectivity Center。
- 环境之间使用独立 folder/project/CIDR 边界。

## 5. 安全治理

- Organization Policy 用于限制外部 IP、服务账号密钥、区域、共享资源等。
- Cloud Audit Logs 和 Logging Sink 用于集中审计。
- Security Command Center 用于运行时发现和导出；Organization Policy 与 plan-time Conftest 互补。
- 禁止 service account key creation 是默认安全基线，CI/CD 使用 Workload Identity Federation。

## 6. OpenLZKit 输出物

- [`multi-cloud/gcp/docs/account-model.md`](../../multi-cloud/gcp/docs/account-model.md)：组织、Folder 和 Project 模型。
- [`multi-cloud/gcp/docs/identity-model.md`](../../multi-cloud/gcp/docs/identity-model.md)：Cloud Identity、IAM、WIF 和 service account。
- [`multi-cloud/gcp/docs/network-model.md`](../../multi-cloud/gcp/docs/network-model.md)：Shared VPC、NCC、NAT 和 Private Google Access。
- [`multi-cloud/gcp/docs/security-baseline.md`](../../multi-cloud/gcp/docs/security-baseline.md)：Org Policy、SCC 和审计基线。
- [`multi-cloud/gcp/docs/operations-runbook.md`](../../multi-cloud/gcp/docs/operations-runbook.md)：项目接入、权限、网络和 drift 运维。
- `multi-cloud/gcp/modules/*` 和 `multi-cloud/gcp/live/<NN-layer>/*`：可 validate 的 Terraform/OpenTofu HCL。

## 7. 实施边界

- `00-bootstrap` 可以创建 GCS state bucket 和 WIF 基础，但真实 apply 需要 seed project 和组织级权限。
- Project factory 默认不创建真实业务 project，必须显式传入 billing account 和 labels。
- Shared VPC 接入先在 nonprod 验证，sandbox 不接入 prod host project。
- Org Policy 从 folder 层逐步推广到 organization 层。

## 8. 常见误区

- 把 project 当作普通资源随意销毁，忽视 project id 全局唯一和删除恢复窗口。
- 给 service account 下载 key 作为 CI/CD 凭证。
- 只创建 Shared VPC host，忘记 service project association 和 subnet IAM。
- 只配置 Admin Activity logs，忽视关键数据访问日志和 sink writer 权限。
