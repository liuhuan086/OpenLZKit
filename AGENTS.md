# AGENTS.md — OpenLZKit 统一入口

> 这是 OpenLZKit 仓库面向 **AI 助手和开发者** 的统一入口文件（遵循 agents.md 约定）。
> 无论你是人还是 Agent，开始任何工作前请先读完本文件，再按下面的“必读顺序”加载对应规范，然后再动手。

## 这是什么项目

OpenLZKit 是一个**文档优先 + IaC 优先**的企业级多云 Landing Zone Blueprint，覆盖阿里云、AWS、腾讯云、Azure、Google Cloud。
核心理念是**每朵云按各自原生最佳实践独立设计**，共享的是治理标准（目录、命名、测试、文档、CI/CD），而不是一个屏蔽云厂商差异的“万能抽象”。

详见 [README.md](README.md) 和 [prd.md](prd.md)。

## 必读顺序（开始工作前）

按顺序阅读，各文件职责不重叠：

1. **[CLAUDE.md](CLAUDE.md)** — 通用行为准则：先想后写、最小改动、外科手术式修改、目标驱动验证。**所有改动都受其约束。**
2. **[prompts.md](prompts.md)** — 项目专属 Prompt 库：总角色、模块生成、设计文档、测试用例、PR Review 的标准提示词。生成代码/文档/测试/评审时**必须**引用对应章节。
3. **[prd.md](prd.md)** — 产品需求、范围（In/Out of Scope）、用户故事、版本规划（MVP / V1 / V2）。判断“该不该做”时看这里。
4. **[README.md](README.md)** — 项目目标、设计原则、仓库结构、路线图。
5. **[docs/](docs/README.md)** — 治理方法论，从 [docs/README.md](docs/README.md) 索引进入。每个主题只有一个权威位置：
   - [docs/learning/](docs/learning/) — 概念入门（什么是 Landing Zone、0→1、角色管理、跨账号访问、云能力映射、多云策略）。
   - [docs/design/](docs/design/) — 深入设计（企业原则、身份/网络/安全/IaC-CICD/仓库与 state、各云设计、日志、FinOps）。
   - [docs/runbooks/](docs/runbooks/) — 运维手册与常见问题处置。
   - 跨切面：[testing-strategy](docs/testing-strategy.md)、[outputs-and-acceptance](docs/outputs-and-acceptance.md)、[references](docs/references.md)。
   实现某个领域前先读对应文档。
6. **`multi-cloud/<cloud>/docs/`** — 动某朵云之前，先读该云的 `design.md`、各能力域 model 文档与 `enterprise-scenarios.md`（企业深化路线图）。
7. **[architecture/adr/](architecture/adr/)** — 关键设计决策。改动若涉及架构取舍，先看是否已有 ADR，必要时新增。

> 优先级：`prompts.md` 的项目规则 > `CLAUDE.md` 的通用规则。两者冲突时以 `prompts.md` 为准；`CLAUDE.md` 补充未覆盖的通用工程纪律。

## 仓库地图

```text
OpenLZKit/
├── AGENTS.md           # 本文件：统一入口
├── CLAUDE.md           # AI/开发者通用行为准则
├── prompts.md          # 项目专属标准 Prompt
├── prd.md              # 产品需求文档
├── README.md           # 项目总览
├── CONTRIBUTING.md / SECURITY.md / CODE_OF_CONDUCT.md / LICENSE
├── docs/               # 跨云治理方法论（见 docs/README.md 索引）
│   ├── learning/       # 概念入门
│   ├── design/         # 深入设计（含各云设计、日志、FinOps）
│   ├── runbooks/       # 运维手册与常见问题
│   ├── testing-strategy.md / outputs-and-acceptance.md / references.md
├── architecture/
│   ├── adr/            # 架构决策记录
│   └── diagrams/       # 架构图（规划中）
├── multi-cloud/        # 五朵云各自独立的 Landing Zone（aws / alicloud / tencentcloud / azure / gcp）
│   └── <cloud>/        # README + docs + modules + live + policies + examples + tests
├── tests/              # 跨云测试用例（TEST_CASES.md）
└── .github/workflows/  # CI 检查（terraform fmt / validate / conftest policy）
```

每朵云目录内部结构一致（工程组织统一），但**资源模型各自独立**。详见 [README.md](README.md) 的“云目录设计”。

## 工作准则（硬性约束）

这些规则来自 `prompts.md` 和 `CLAUDE.md`，在此汇总为不可违反的红线：

1. **不提交任何敏感信息**：真实密钥、账号/订阅/租户 ID、Access Key、个人信息一律禁止。占位用明显的假值（如 `123456789012`、`example.com`）。
2. **核心实现用 Terraform/OpenTofu HCL**；Python/Go/Node 等工具层后置，仅在 `tools/` 引入，不进核心 IaC 层。
3. **每朵云独立设计**，绝不把一朵云的资源模型硬套到另一朵云；能力差异要**写清楚**而不是隐藏。
4. **安全默认开启**：最小权限、短期凭证（OIDC/Federation）、集中审计、状态隔离、强制标签、策略即代码。任何高风险默认值必须显式说明并尽量默认关闭。
5. **每个模块必须配套**：README、变量说明、输出说明、`examples/`、测试用例、安全注意事项。
6. **外科手术式改动**：只改与任务直接相关的内容，不顺手“优化”无关代码、注释或格式；发现无关死代码先提出、不擅自删。
7. **目标驱动**：先定义可验证的成功标准（fmt / validate / policy / 文档齐全），再循环到通过。

## 提交前自检（对应 CI 与 PR Review）

参考 [prompts.md](prompts.md) 第 5 节的 PR Review 清单：

- [ ] 符合当前云的原生最佳实践，未破坏目录结构与模块边界
- [ ] 无硬编码账号、区域、密钥或个人信息
- [ ] 无权限过大、默认公网暴露、日志未开启等风险
- [ ] README、变量说明、输出说明、测试已同步更新
- [ ] 通过 `terraform fmt` / `validate` / `conftest`（CI 三个 job）
- [ ] 不破坏 state 兼容性
- [ ] 重大设计决策已记录 ADR

## 当前状态

- **阿里云、AWS**：MVP 七域 + 企业级深化（FP-1~FP-8：账号工厂、组织护栏、业务部门、跨账号访问、SSO、网络互联、集中合规、委派与共享）均已落地，全部通过 `terraform fmt + validate`，并配 Conftest 策略用例（见各云 `docs/enterprise-scenarios.md`）。
- **腾讯云、Azure、GCP**：设计文档与目录骨架就位，HCL 待实现。
- CI（[.github/workflows/terraform-checks.yml](.github/workflows/terraform-checks.yml)）对全仓库执行 `fmt`、`validate`、`conftest policy` 三道门禁。

继续实现时严格沿用上述标准与各云 `enterprise-scenarios.md` 的功能点节奏。
