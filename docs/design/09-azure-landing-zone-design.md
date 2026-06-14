# Azure Landing Zone 设计

## 1. 定位

Azure 在 OpenLZKit 中按 Azure Landing Zone 原生模型实现：Management Groups、Subscriptions、Microsoft Entra ID、RBAC、Azure Policy、Hub-Spoke/Virtual WAN、Log Analytics 和 Defender for Cloud。当前仓库已具备基础模块与 live stack，不再只是 skeleton；后续应围绕企业级 subscription vending、policy initiative、诊断日志和跨租户委派继续深化。

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
- Defender for Cloud 承载运行时安全态势和建议；生产环境应把关键建议纳入例外/整改流程。
- Policy exemption 必须记录 owner、reason、expiry date 和补偿控制，避免永久豁免。

## 6. OpenLZKit 输出物

- [`multi-cloud/azure/docs/account-model.md`](../../multi-cloud/azure/docs/account-model.md)：管理组和订阅模型。
- [`multi-cloud/azure/docs/identity-model.md`](../../multi-cloud/azure/docs/identity-model.md)：Entra、RBAC、托管身份和 OIDC。
- [`multi-cloud/azure/docs/network-model.md`](../../multi-cloud/azure/docs/network-model.md)：Hub-Spoke、VNet、Private DNS 和 Private Endpoint。
- [`multi-cloud/azure/docs/security-baseline.md`](../../multi-cloud/azure/docs/security-baseline.md)：Azure Policy、Defender 和例外机制。
- [`multi-cloud/azure/docs/operations-runbook.md`](../../multi-cloud/azure/docs/operations-runbook.md)：订阅接入、权限、网络和 drift 运维。
- `multi-cloud/azure/modules/*` 和 `multi-cloud/azure/live/<NN-layer>/*`：可 validate 的 Terraform/OpenTofu HCL。

## 7. 实施边界

- `00-bootstrap` 可以创建 state 存储和 OIDC 基础，但真实 apply 需要企业订阅和 Entra 权限。
- 订阅售卖默认不购买真实订阅；生产需要接入企业计费、审批和配额流程。
- Policy 先在 sandbox 管理组验证，再推广到 `LandingZones` 和 root。
- 生产 apply 身份与 plan 身份分离，apply 必须走环境审批。

## 8. 常见误区

- 把所有业务放在一个订阅，导致配额、账单、权限和日志边界混乱。
- 在资源组层做所有治理，绕开管理组继承。
- 用 client secret 做 CI/CD 默认凭证，而不是 OIDC/federated credential。
- Private Endpoint 上线但没有同步 Private DNS，导致业务解析失败。
