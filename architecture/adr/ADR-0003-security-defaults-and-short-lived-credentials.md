# ADR-0003: 要求安全默认值和短期凭证

## 状态

Accepted（已接受）

## 背景

Landing Zone 代码经常会被复制到真实企业环境中。不安全的示例很容易变成生产默认值。长期 Access Key、过宽管理员权限、默认公网入口、缺失日志、共享 state、可选标签等问题，一旦业务接入后再修正，代价会很高。

支持的云各自提供不同的原生身份机制：

- AWS：IAM Identity Center、IAM Role、STS、OIDC。
- 阿里云：RAM Role、CloudSSO、STS、OIDC。
- 腾讯云：CAM Role、STS、SSO 或身份提供商联合。
- Azure：Microsoft Entra ID、Managed Identity、Federated Identity Credential。
- Google Cloud：Cloud Identity Group、Service Account、Workload Identity Federation。

## 决策

OpenLZKit 默认采用安全的 Landing Zone 行为：

- 人员访问使用组、SSO、联合身份或等价云原生身份。
- 自动化使用 OIDC/WIF/STS/联合身份和短期凭证。
- 长期 Access Key 和 Client Secret 不作为默认示例。
- 日志和审计链路是基线能力，不是后补选项。
- 高风险操作必须显式 opt-in，并在文档中说明安全注意事项。
- 模块和示例必须包含必要治理标签或 labels。
- Break-glass 作为应急流程记录，必须包含 MFA、告警和复盘。

## 影响

正向影响：

- 降低 demo 代码变成不安全生产实践的概率。
- 对齐企业合规预期。
- CI/CD 身份可审计、可撤销。
- 默认值保守，安全评审更直接。

负向影响：

- 初次配置比静态 Access Key 更繁琐。
- Sandbox 用户需要配置 OIDC/WIF 或等价联合身份才能测试真实流程。
- 部分 provider 或云服务在 Terraform apply 前仍需要手工前置条件。

## 评审规则

以下变更属于必须要求修改的问题：

- 添加真实凭证、个人标识、真实租户/账号 ID 或长期 secret。
- 授予过宽管理员权限，但没有 scope、reason 和 expiration。
- 默认关闭审计或日志。
- 默认开放高风险公网入口。
- 移除必需 tags/labels 且没有明确替代方案。
