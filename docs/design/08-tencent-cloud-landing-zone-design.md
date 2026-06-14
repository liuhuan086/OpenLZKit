# 腾讯云 Landing Zone 设计说明

## 1. 定位

腾讯云是 OpenLZKit 面向中国大陆多云场景的重要云厂商。它的设计目标不是复制 AWS OU 或 Azure Management Group，而是使用腾讯云组织、CAM、CCN、CloudAudit、CLS、CSIP 和分账标签构建原生 Landing Zone。

当前腾讯云目录已经从早期占位推进到基础 HCL + 企业级功能点路线图：

- `00-bootstrap`：COS remote state、CloudAudit 初始审计。
- `10-org` / `15-departments`：组织节点、成员账号、部门边界。
- `20-identity` / `24-cross-account-access` / `25-sso`：CAM 策略、角色、跨账号访问和人员访问。
- `30-network` / `35-connectivity`：VPC 基线和 CCN hub-spoke。
- `40-security` / `45-compliance` / `50-logging`：管控策略、合规检测、CloudAudit + CLS。
- `55-delegation` / `60-finops` / `70-workload-onboarding`：委派、预算/分账标签和业务接入。

---

## 2. 核心组成

| 能力域 | 腾讯云相关能力 | OpenLZKit 输出 |
|---|---|---|
| 组织与账号 | Tencent Cloud Organization、成员账号 | `modules/org`、`account-factory`、`department` |
| 身份与权限 | CAM、用户组、角色、策略、STS | `modules/identity`、`identity-groups`、`cross-account-access` |
| 网络 | VPC、子网、安全组、NAT、CCN | `modules/network`、`connectivity` |
| 安全护栏 | 组织管控策略 | `modules/control-policies` |
| 日志审计 | CloudAudit、CLS | `modules/logging` |
| 运行时合规 | CSIP / 风险中心 | `modules/compliance` |
| 成本 | 标签、预算、费用中心能力 | `modules/finops` |

---

## 3. 推荐账号结构

```text
management account
├── security
│   └── audit-log-account
├── infrastructure
│   └── connectivity-account
├── workloads
│   ├── prod-app-account
│   └── dev-app-account
└── sandbox
    └── sandbox-account
```

---

## 4. CAM 设计

腾讯云使用 CAM 做权限管理。OpenLZKit 中不要把 CAM 与 AWS IAM 或阿里云 RAM 强行等价，只能抽象为 `identity_provider` 和 `role_binding`。

推荐输出：

- CAM 用户组矩阵。
- CAM 角色矩阵。
- 成员账号访问路径说明。
- 机器身份权限边界说明。

---

## 5. 网络设计

腾讯云多 VPC、多地域互联可以用 CCN 做 Hub-Spoke 或全网互联设计。

`modules/connectivity` 使用 `tencentcloud_ccn_attachment_v2` 挂载 VPC。默认 `attachments = {}`，避免计划阶段误接入生产网络；真实接入必须显式声明 VPC、地域和 owner。

---

## 6. 实施注意事项

- 组织成员账号创建涉及实名、计费和联系人信息，默认不自动创建真实账号。
- 管控策略先挂 sandbox 节点验证，再推广到 nonprod/prod/root。
- CCN 是强互联能力，sandbox 不应接入生产路由域。
- CAM root account 不做日常操作；自动化使用 STS 临时凭证。
- CloudAudit 和 CLS 是上线前硬门禁，不能等业务上线后再补。

## 7. 后续深化

- 增加管控策略 Rego 单测，覆盖公开安全组、禁用审计、缺标签等场景。
- 增加 CSIP finding 到 CLS/SIEM 的示例。
- 增加 CCN route table 分域示例，明确 prod/nonprod/sandbox 路由隔离。
