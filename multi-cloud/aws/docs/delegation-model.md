# AWS Delegation Model

## 目标

委派管理把 Organizations 管理账号从日常安全、合规、网络和访问分析操作中解耦出来，把服务管理权委派给专用成员账号。资源共享治理则通过 AWS RAM 统一控制哪些 OU、账号或外部主体可以访问共享网络、License、AMI、Subnet 等资源。

## 云原生服务

- AWS Organizations Delegated Administrator：把 Config、Security Hub、GuardDuty、Firewall Manager、IAM Access Analyzer 等服务委派给专用账号。
- AWS RAM sharing with Organizations：允许在组织内共享资源。
- AWS RAM Resource Share：定义共享集合。
- AWS RAM Principal/Resource/Permission Association：显式绑定共享目标、资源和权限。

## 模块边界

由 [`modules/delegation`](../modules/delegation) 实现：

- **负责**：注册 Organizations delegated administrator、启用 RAM 组织共享、创建 RAM resource share、关联 principal、resource 和 permission。
- **不负责**：配置服务内具体规则、创建被共享资源、创建跨账号 IAM role、配置 Transit Gateway route table。

下游协作：

- `modules/compliance` 配置 Config、Security Hub、GuardDuty 的运行时能力。
- `modules/connectivity` 创建 TGW 和网络共享候选资源。
- `modules/cross-account-access` 创建机器访问 STS/OIDC 角色。

## 推荐委派基线

| key | service principal | 推荐账号 |
|---|---|---|
| `config` | `config.amazonaws.com` | security/compliance account |
| `security_hub` | `securityhub.amazonaws.com` | security tooling account |
| `guardduty` | `guardduty.amazonaws.com` | security tooling account |
| `access_analyzer` | `access-analyzer.amazonaws.com` | security tooling account |
| `fms` | `fms.amazonaws.com` | network/security account |

## 输入、输出与依赖

主要输入：

- `enable_ram_sharing_with_organization`
- `delegated_administrators`
- `resource_shares`

主要输出：

- `delegated_administrator_ids`
- `ram_resource_share_arns`
- `ram_sharing_with_organization_enabled`

依赖：

- 在 Organizations management account 或具备组织权限的执行身份中运行。
- 目标 delegated admin account 是组织成员账号。
- RAM 共享资源已存在，且资源类型支持 RAM。
- `service_principal` 必须是精确 AWS 服务主体，不允许通配。

## 测试

静态检查：

```bash
terraform -chdir=multi-cloud/aws/examples/delegation fmt -check -recursive
terraform -chdir=multi-cloud/aws/examples/delegation init -backend=false
terraform -chdir=multi-cloud/aws/examples/delegation validate

terraform -chdir=multi-cloud/aws/live/55-delegation fmt -check -recursive
terraform -chdir=multi-cloud/aws/live/55-delegation init -backend=false
terraform -chdir=multi-cloud/aws/live/55-delegation validate
```

集成验证：

- 先在 sandbox 组织或 sandbox OU 上启用 RAM 组织共享。
- 委派一个测试安全账号为 GuardDuty 或 Config admin。
- 创建一个只共享给 sandbox OU 的 RAM share。
- 确认非目标账号不可见共享资源。

## 回滚

- 先删除 RAM principal/resource/permission association。
- 删除 RAM resource share。
- 移除 delegated administrator。
- 最后按需关闭 RAM sharing with Organizations。

## 常见故障

| 现象 | 排查 |
|---|---|
| delegated admin 注册失败 | 确认 service principal 拼写正确，目标账号是组织成员账号。 |
| RAM 共享不可见 | 检查组织共享是否启用、principal 是否为正确 OU/account ARN。 |
| permission association 失败 | 检查 permission ARN 是否适用于该资源类型。 |
| 外部账号无法接收共享 | 检查 `allow_external_principals` 和目标账号接受流程。 |
