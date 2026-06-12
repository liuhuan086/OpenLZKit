# Google Cloud Landing Zone 设计

## 1. 定位

Google Cloud 在 OpenLZKit 中作为第五朵云保留。它不是 MVP 前三阶段的主实现对象，但必须保留目录、schema、provider adapter、概念映射和文档生成能力。

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
- Security Command Center 可作为后续安全增强项。

## 6. OpenLZKit 输出物

- `gcp-folder-project-matrix.md`
- `gcp-iam-matrix.md`
- `gcp-network-matrix.md`
- `gcp-org-policy-baseline.md`
- `multi-cloud/gcp/modules/*` 模板占位
- `multi-cloud/gcp/live/<NN-layer>/*` root module 占位（`00-bootstrap` … `70-workload-onboarding`）

## 7. MVP 边界

MVP 阶段不要求完整创建 Google Cloud Foundation，但必须保证：

1. `cloud: gcp` 是合法枚举值。
2. 文档生成器能识别 organization / folder / project。
3. IaC 生成器可以生成 plan-ready skeleton。
4. 测试用例覆盖 GCP 的 project、Shared VPC 和 Organization Policy 映射。
