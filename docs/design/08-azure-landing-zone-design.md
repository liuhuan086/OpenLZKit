# Azure Landing Zone 设计

## 1. 定位

Azure 在 OpenLZKit 中作为第四朵云保留。它不是 MVP 前三阶段的主实现对象，但必须保留目录、schema、provider adapter、概念映射和文档生成能力。

## 2. 核心资源层级

```text
Tenant
└── Root Management Group
    ├── Platform Management Group
    │   ├── Management Subscription
    │   ├── Connectivity Subscription
    │   └── Identity Subscription
    └── Landing Zones Management Group
        ├── Dev Subscription
        ├── Staging Subscription
        └── Prod Subscription
```

## 3. 身份与权限

- 人类身份：Entra ID 用户、组、PIM、RBAC。
- 机器身份：Managed Identity、Federated Credential、OIDC。
- Break-glass：独立高权限账号，强 MFA，强审计。
- 角色矩阵：Platform Admin、Security Auditor、Network Admin、Workload Operator、ReadOnly Auditor。

## 4. 网络设计

推荐采用 Hub-Spoke：

- Hub VNet / Connectivity Subscription 承载防火墙、网关、DNS、出口控制。
- Spoke VNet 按业务或环境拆分。
- 大型组织可考虑 Virtual WAN。
- 每个环境独立 CIDR，禁止 prod 与 sandbox 直接互通。

## 5. 安全治理

- Azure Policy 用于强制标签、区域限制、公共 IP 管控、加密要求。
- Activity Log、Diagnostic Settings、Log Analytics 用于集中审计。
- Defender for Cloud 可作为后续安全增强项。

## 6. OpenLZKit 输出物

- `azure-management-group-matrix.md`
- `azure-subscription-matrix.md`
- `azure-role-matrix.md`
- `azure-network-matrix.md`
- `azure-policy-baseline.md`
- `multi-cloud/azure/modules/*` 模板占位
- `multi-cloud/azure/live/<NN-layer>/*` root module 占位（`00-bootstrap` … `70-workload-onboarding`）

## 7. MVP 边界

MVP 阶段不要求完整创建 Azure Landing Zone，但必须保证：

1. `cloud: azure` 是合法枚举值。
2. 文档生成器能识别 Azure subscription / management group。
3. IaC 生成器可以生成 plan-ready skeleton。
4. 测试用例覆盖 Azure 的 subscription 与 policy 映射。
