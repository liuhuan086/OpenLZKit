# IaC 与 CI/CD 设计

## 1. IaC 原则

- 组织级资源和业务级资源分离。
- state 按云、环境、模块拆分。
- provider alias 显式表达目标账号/订阅/项目。
- plan 和 apply 分离。
- 生产 apply 必须审批。
- 所有变更通过 PR。

## 2. 目录约定

沿用仓库统一的 `multi-cloud/<cloud>/` 布局（详见 [05-repository-and-state-design.md](05-repository-and-state-design.md) 与根 [README.md](../../README.md)）：

```text
multi-cloud/<cloud>/
├── modules/   # 可复用模块：org/identity/network/security/logging/finops/workload-onboarding
├── live/      # 可执行 root module，按 00-bootstrap … 70-workload-onboarding 分层
├── policies/  # 策略即代码
├── examples/  # 示例
└── tests/     # 测试
```

- state backend 与 CI/CD 角色由各云的 `live/00-bootstrap` 承载。
- 环境（dev/staging/prod）通过独立账号/订阅/项目 + 独立 state 表达，不作为目录层级。

## 3. State 设计

### 3.1 为什么 state 要拆分

Landing Zone 权限高、影响大，不应该所有资源共用一个 state。

推荐按层拆：

- org state
- identity state
- network state
- security state
- workload state

### 3.2 State 权限

- plan 角色可读 state。
- apply 角色可写 state。
- state backend 启用加密、锁、版本控制。

## 4. CI/CD 流程

```mermaid
flowchart LR
    A[Pull Request] --> B[Lint]
    B --> C[Schema Validate]
    C --> D[Generate Docs]
    D --> E[Policy Check]
    E --> F[OpenTofu Plan]
    F --> G[Plan Policy Check]
    G --> H[Human Approval]
    H --> I[Apply]
```

## 5. GitHub Actions 权限建议

```yaml
permissions:
  id-token: write
  contents: read
  pull-requests: write
```

原因：

- `id-token: write` 用于 OIDC。
- `contents: read` 读取仓库。
- `pull-requests: write` 可选，用于回写 plan summary。

## 6. 分支策略

| 分支 | 行为 |
|---|---|
| feature/* | validate + docs + policy |
| main | validate + plan |
| release/* | validate + plan + approval + apply |

## 7. 环境保护

- dev 可自动 apply。
- test 需要团队审批。
- prod 需要平台负责人 + 安全负责人审批。

## 8. 本项目 MVP 建议

先只实现到 plan/report，不实现真实 apply。

原因：

- 成本低。
- 安全风险低。
- 对简历足够有价值。
- 面试时可以解释“生产 apply 要走审批和受控环境”。
