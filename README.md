# OpenLZKit: Enterprise Multi-Cloud Landing Zone Blueprint

OpenLZKit helps platform teams design, validate and explain enterprise Landing Zones across AWS, Alibaba Cloud, Tencent Cloud, Azure and Google Cloud.

它提供：

- 云原生 Landing Zone blueprint，而不是错误的“万能多云抽象”。
- Terraform/OpenTofu modules 与按层拆分的 live stacks。
- 多账号 / 订阅 / 项目治理、身份、网络、安全、日志、FinOps 和 workload onboarding 模式。
- Policy-as-code guardrails、CI/CD 静态验证和可审计交付清单。
- 面向简历、面试、开源展示和后续企业落地的文档优先工程资产。

OpenLZKit 是一个面向真实企业场景的多云 Landing Zone 开源项目模板。它的目标不是把五朵云“强行抽象成一种云”，而是为阿里云、AWS、腾讯云、Azure、Google Cloud 分别设计符合各自原生最佳实践的 Landing Zone，然后在统一仓库中沉淀共同的治理方法、文档标准、测试流程和交付物。

> **AI 助手 / 开发者请先读 [AGENTS.md](AGENTS.md)**：它是本仓库的统一入口，指明必读顺序（CLAUDE.md、prompts.md、prd.md 等）和工作准则。

## 30 秒看懂项目

```text
Business / Platform Request
        ↓
Account / Subscription / Project Factory
        ↓
Identity + Network + Security + Logging + FinOps
        ↓
Policy-as-Code + CI Static Validation
        ↓
Sandbox Evidence + Operational Runbooks
        ↓
Workload Onboarding Handoff
```

当前优先级：先把 AWS 做成第一条可信、可验证、可演示的样板路径，再把同一套验证和证据方法推广到阿里云、Azure、GCP 与腾讯云。见 [docs/demo/aws-sandbox-apply-report.md](docs/demo/aws-sandbox-apply-report.md)、[examples/demo](examples/demo) 与 [docs/compliance/control-mapping.md](docs/compliance/control-mapping.md)。

## 项目目标

1. **实际项目经验**：完整覆盖企业云上治理的核心能力，包括账号/订阅/项目结构、身份权限、网络、安全基线、日志审计、成本治理、CI/CD、合规检查和工作负载接入。
2. **开源可展示**：仓库结构、README、PRD、架构文档、测试用例、Issue 模板和贡献指南均按照开源项目标准组织。
3. **简历亮点**：体现 Platform Engineering、Cloud Governance、Terraform/OpenTofu、Security Guardrails、FinOps、多云治理和 AI-assisted engineering 能力。
4. **商业化潜力**：后续可扩展为企业 Landing Zone 评估、定制部署、合规审计、培训课程、模板订阅或托管平台。

## 核心设计原则

- **每朵云独立设计**：AWS 不复制 Azure 的管理组模型，GCP 不硬套 AWS OU，阿里云和腾讯云也保留各自的资源目录、组织和权限体系。
- **共享的是标准，不共享错误抽象**：统一目录、命名、测试、文档、CI/CD 和交付标准；不做一个“万能 multi-cloud module”来屏蔽云厂商差异。
- **Terraform/OpenTofu HCL 为主**：Landing Zone 的核心实现是声明式基础设施代码。Python 不是 MVP 必需项。
- **可选工具层后置**：如果后续需要生成报告、渲染架构图、批量生成账号申请、做成本分析或做 SaaS 化控制台，可以在 `tools/` 中引入 Python/Go/Node，但不进入核心 IaC 层。
- **安全默认开启**：默认使用最小权限、短期凭证、集中审计、状态隔离、强制标签、策略即代码和代码评审。

## 仓库结构

```text
OpenLZKit/
├── README.md
├── AGENTS.md
├── CLAUDE.md
├── LICENSE
├── CONTRIBUTING.md
├── SECURITY.md
├── CODE_OF_CONDUCT.md
├── .gitignore
├── prd.md
├── prompts.md
├── docs/
│   ├── README.md       # 文档索引
│   ├── learning/       # 概念入门（00-what-is-landing-zone … 05-multi-cloud-strategy）
│   ├── design/         # 深入设计（00-enterprise-principles、身份/网络/安全/IaC-CICD/仓库与 state、各云设计、日志、FinOps）
│   ├── runbooks/       # 运维手册与常见问题处置
│   ├── demo/           # sandbox apply 报告模板与演示说明
│   ├── compliance/     # 控制目标、云原生实现、Rego 与证据映射
│   ├── testing-strategy.md
│   ├── outputs-and-acceptance.md
│   ├── releases.md
│   └── references.md
├── architecture/
│   ├── adr/
│   └── diagrams/
├── multi-cloud/
│   ├── alicloud/
│   ├── aws/
│   ├── tencentcloud/
│   ├── azure/
│   └── gcp/
├── examples/
│   └── demo/           # 无云账号可阅读的业务接入 Demo
├── request/            # 账号/订阅/项目售卖请求样例
├── tests/
│   └── TEST_CASES.md
└── .github/
    └── workflows/
        └── terraform-checks.yml
```

## 云目录设计

每朵云目录都遵循同一种工程组织方式，但内部资源模型独立：

```text
multi-cloud/<cloud>/
├── README.md
├── docs/
│   ├── design.md
│   ├── account-model.md
│   ├── identity-model.md
│   ├── network-model.md
│   ├── security-baseline.md
│   └── operations-runbook.md
├── modules/                # 云原生实现模块（按云扩展，如 org、identity、network、
│                           # security、logging、finops、workload-onboarding、
│                           # account-factory/identity-center/connectivity 等）
├── live/                   # 统一 14 层（五朵云一致）
│   ├── 00-bootstrap/       # 远程 state、CI/CD 身份、初始审计
│   ├── 10-org/             # 组织层级与账号/项目/订阅售卖
│   ├── 15-departments/     # 业务部门边界
│   ├── 20-identity/        # 基础角色与权限边界
│   ├── 24-cross-account-access/  # 自动化与安全跨账号访问
│   ├── 25-sso/             # 人员访问组与分配
│   ├── 30-network/         # VPC/VNet/网络基线
│   ├── 35-connectivity/    # 互联（TGW、CEN/TR、CCN、Peering、Shared VPC）
│   ├── 40-security/        # 预防性护栏
│   ├── 45-compliance/      # 运行时合规检测
│   ├── 50-logging/         # 审计与日志归档
│   ├── 55-delegation/      # 委派管理与共享
│   ├── 60-finops/          # 标签、预算、成本责任
│   └── 70-workload-onboarding/  # 团队交付与工作负载基线
├── policies/
├── examples/
└── tests/
```

## 推荐路线图

### MVP

- 完成所有文档、目录、测试策略和 CI 检查。
- 五朵云均提供 `README.md`、设计文档、模块 README、live stack 和测试说明。
- AWS 与阿里云提供更完整的策略即代码样例，作为后续扩展其他云策略测试的参考。
- 输出无云账号也能阅读的 Demo Mode，说明业务申请、预期 OU/账号/网络/控制和 policy-as-code 检查。

### V1

- 先完成 AWS sandbox apply / rollback / evidence path，把 `00-bootstrap` 到 `70-workload-onboarding` 的真实验证状态写入报告。
- 强化 provider-specific policy-as-code、控制映射和真实云账号验证，再推广到第二朵云。
- 引入 terraform-docs 生成变量/输出文档，并继续扩展 OPA/Conftest、TFLint、Checkov/tfsec。
- 输出跨云治理矩阵和对外 Demo 文档。

### V2

- 增加 Account/Subscription/Project Vending Machine。
- 增加成本治理报告、合规报告、架构图生成和 Web 控制台。
- 支持企业定制包、培训包、审计包和咨询交付包。

## Release 路线

| 版本 | 目标 | 验收重点 |
|---|---|---|
| `v0.1.0` | Documentation + Static Validation Release | README、Demo Mode、控制映射、静态门禁和 runbook 齐备 |
| `v0.2.0` | AWS Verified Sandbox Release | AWS sandbox apply 报告、sanitized evidence、rollback 演练 |
| `v0.3.0` | Alibaba Cloud Verified Sandbox Release | 第二朵云复用同一证据链方法 |
| `v0.4.0` | Policy-as-Code Compliance Mapping Release | 跨云控制矩阵与更多 provider-specific Rego |
| `v1.0.0` | Multi-cloud Governance Blueprint Release | 多云静态治理完整，至少两朵云完成 verified path |

## 适合写进简历的描述

> 设计并开源 OpenLZKit 多云 Landing Zone 项目，基于 Terraform/OpenTofu 为 AWS、阿里云、腾讯云、Azure、GCP 设计企业级云治理基线，覆盖多账号/订阅/项目结构、身份权限、网络隔离、安全 Guardrails、日志审计、FinOps、CI/CD、策略即代码和工作负载接入，沉淀 PRD、架构文档、测试用例和 AI-assisted 开发规范。
