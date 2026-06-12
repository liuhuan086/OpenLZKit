# AWS Account Model

## 目标

账号是 AWS Landing Zone 的主要隔离边界。本域解决企业常见的多账号管理问题：平台团队统一创建安全、网络、共享服务和业务账号；业务部门按 OU 管理自己的环境；后续 SCP、Tag Policy、SSO、跨账号角色、日志和成本治理都可以稳定附着到 OU 或账号。

## 云原生服务

- AWS Organizations：管理组织 root、OU 和成员账号。
- Control Tower / AFT：生产环境建议作为账号售卖的托管入口；本仓库模块保持兼容，不强制替代官方能力。
- IAM Identity Center / STS：后续功能点用于人员和机器跨账号访问。
- AWS Budgets / Cost Explorer / Tag Policy：FinOps 与标签治理能力。

## 推荐 OU 基线

| OU key | 用途 |
|---|---|
| `security` | 安全、审计、合规账号父 OU |
| `security/log-archive` | 组织级日志归档账号 |
| `security/security-tooling` | Security Hub、GuardDuty、Config 等委派管理账号 |
| `infrastructure/network` | Transit Gateway、DNS、共享网络账号 |
| `infrastructure/shared-services` | 镜像、CI/CD、共享平台服务账号 |
| `workloads/prod` | 生产业务账号 |
| `workloads/nonprod` | 开发、测试、预发账号 |
| `workloads/sandbox` | 低权限实验账号 |

OU key 是 Terraform、策略附件、账号售卖和文档之间的稳定契约；OU 显示名称可以调整，但 key 不应随意变化。

## 模块边界

### `modules/org`

职责：

- 读取现有 AWS Organizations root。
- 创建一层或两层 OU。
- 输出稳定的 `ou_ids`，供账号售卖和策略附件使用。
- 给 OU 合并公共标签和 OU 专属标签。

不负责：

- 启用 AWS Organizations 或 Control Tower。
- 创建成员账号。
- 管理 SCP、SSO、网络、日志、安全服务或 FinOps 控制。

### `modules/account-factory`

职责：

- 用标准输入合同创建 AWS Organizations member account。
- 强制账号包含治理标签：`owner`、`cost_center`、`env`、`project`、`managed_by`、`data_classification`。
- 默认 `accounts = {}`，避免误创建真实账号。
- 输出账号 id 和 arn，供后续身份、日志、合规、网络模块消费。

不负责：

- 创建 OU。
- 在新账号里部署基线资源。
- 替代生产级 Control Tower Account Factory 或 AFT 流程。

## 输入与输出

`modules/org` 主要输入：

- `name_prefix`：OU 名称前缀。
- `organizational_units`：OU 树，支持一层 child OU。
- `tags`：所有 OU 的公共标签。

`modules/org` 输出：

- `root_id`
- `ou_ids`

`modules/account-factory` 主要输入：

- `ou_ids`：通常来自 `module.org.ou_ids`。
- `accounts`：待创建账号 map；生产中应来自审核后的账号请求。
- `common_tags` 和 `required_tag_keys`：治理标签约束。

`modules/account-factory` 输出：

- `account_ids`
- `account_arns`

## live 栈

`live/10-org` 是 FP-1 的部署入口：

- 创建标准 OU 基线。
- 通过 `var.accounts` 显式售卖账号。
- 默认不创建任何账号，避免文档示例或验证命令触发真实资源。

生产建议把 `var.accounts` 接入受控流程：代码评审、预算确认、业务 owner、成本中心、安全分级、关闭策略、唯一 email 校验。

## 测试

静态验证：

```bash
terraform -chdir=multi-cloud/aws/examples/basic fmt -check -recursive
terraform -chdir=multi-cloud/aws/examples/basic init -backend=false
terraform -chdir=multi-cloud/aws/examples/basic validate

terraform -chdir=multi-cloud/aws/examples/account-factory fmt -check -recursive
terraform -chdir=multi-cloud/aws/examples/account-factory init -backend=false
terraform -chdir=multi-cloud/aws/examples/account-factory validate

terraform -chdir=multi-cloud/aws/live/10-org fmt -check -recursive
terraform -chdir=multi-cloud/aws/live/10-org init -backend=false
terraform -chdir=multi-cloud/aws/live/10-org validate
```

集成验证：

- 只在 sandbox management account 中执行 `plan`/`apply`。
- 首次账号售卖使用一条低风险账号请求，确认 OU、标签、role name 和 billing access 符合预期。
- 不要在个人长期 access key 会话中执行组织级 apply。

## 回滚

- OU：只有空 OU 可以安全删除；移动或删除 OU 前先确认无账号和策略附件。
- 账号：`close_on_deletion` 默认为 `false`。关闭账号是高风险操作，应通过组织级变更流程批准。
- 输入错误：优先修正 `accounts` 或 `organizational_units` 后重新 plan，不直接手工改 state。

## 常见故障

| 现象 | 排查 |
|---|---|
| `ou_key must exist` | 检查账号请求中的 `ou_key` 是否存在于 `module.org.ou_ids`。 |
| 缺少必填标签 | 补齐 `owner`、`cost_center`、`env`、`project`、`managed_by`、`data_classification`。 |
| Organizations API 权限不足 | 使用 management account 或具备 Organizations 权限的委派执行身份。 |
| 账号 email 已被使用 | 每个 AWS account email 必须全局唯一；使用企业受控邮箱分配流程。 |
| 删除账号无效果 | 默认不关闭账号；需要显式设置 `close_on_deletion = true` 并完成审批。 |
