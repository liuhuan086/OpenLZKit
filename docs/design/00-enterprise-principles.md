# 企业级设计原则

## 1. 云原生优先，而不是强行多云抽象

多云项目最容易犯的错是做一个统一抽象层，把 AWS Account、Azure Subscription、GCP Project、阿里云账号、腾讯云账号都包装成同一个概念。短期看起来统一，长期会损失云厂商原生能力，也会让权限、网络、安全策略变得含糊。

OpenLZKit 采用“统一标准 + 独立实现”：

- 统一：文档、目录、测试、CI/CD、命名、标签、交付物。
- 独立：组织结构、权限模型、网络模型、安全服务、日志服务。

## 2. HCL 为核心实现语言

Landing Zone 是基础设施声明，Terraform/OpenTofu HCL 是核心。Python 不进入 MVP 核心路径。

Python/Go/Node 只在以下场景作为可选工具：

- 自动生成 Markdown 报告。
- 渲染架构图。
- 批量生成 tfvars。
- 做成本数据分析。
- 做后续 Web 控制台或 API。

## 3. State 隔离

不同云、不同阶段、不同环境必须拆分 Terraform state。不要把五朵云和所有环境放进一个 state。

五朵云统一的 14 层拆分（权威定义见 [05-repository-and-state-design](05-repository-and-state-design.md)）：

- `00-bootstrap`
- `10-org`
- `15-departments`
- `20-identity`
- `24-cross-account-access`
- `25-sso`
- `30-network`
- `35-connectivity`
- `40-security`
- `45-compliance`
- `50-logging`
- `55-delegation`
- `60-finops`
- `70-workload-onboarding`

## 4. 安全默认值

- 禁止提交密钥。
- 禁止默认公网开放。
- 默认开启日志审计。
- 默认强制标签。
- 默认最小权限。
- 默认使用短期凭证或联邦身份。

## 5. 变更必须可审计

所有变更应经过：

1. Issue / RFC。
2. PR。
3. Terraform plan。
4. Policy check。
5. Code review。
6. Apply approval。
7. Drift detection。

## 6. 文档即交付物

Landing Zone 项目的文档不是附属品，而是企业交付核心。每个模块必须能回答：

- 为什么需要它？
- 它创建什么？
- 它不负责什么？
- 谁可以改？
- 如何测试？
- 如何回滚？
- 出问题如何排查？
