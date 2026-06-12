# Alibaba Cloud Cross-account Access Model

## 1. 解决的企业问题

企业 Landing Zone 需要让安全、审计、CI/CD、网络和共享服务账号访问其他成员账号，
但不能靠长期 AccessKey 或人工 RAM 用户扩散权限。跨账号访问模型把访问路径标准化为
临时 STS AssumeRole 和受控 Resource Share。

## 2. 使用的云原生服务

- **RAM Role + STS AssumeRole**：源账号主体临时进入目标账号角色。
- **RAM role policy attachment**：给目标角色附加最小权限。
- **Resource Share**：把共享网络、镜像、资源目录支持的共享资源授权给目标账号。

## 3. Terraform 模块边界

由 [`modules/cross-account-access`](../modules/cross-account-access) 实现：

- **负责**：创建目标账号跨账号 RAM 角色、系统策略绑定、可选 trust condition、Resource Share。
- **不负责**：创建账号、创建自定义 RAM policy、创建共享资源本身、CloudSSO 分配。

## 4. 标准场景

| 场景 | 源账号 | 目标账号 | 权限建议 |
|---|---|---|---|
| 安全审计 | security-tooling | all workload accounts | `SecurityAudit` / read-only |
| CI/CD 部署 | automation | workload account | workload-scoped deploy policy |
| 日志归档 | log-archive | workload account | read/write audit destination only |
| 网络共享 | network | workload account | Resource Share + least share permission |

## 5. 输入、输出与依赖

- 输入：`access_roles`、`resource_shares`、`common_tags`、`name_prefix`。
- 输出：`role_names`、`role_arns`、`resource_share_ids`。
- 依赖：目标账号已存在；源主体 ARN 已明确；共享资源已存在；调用方具备 RAM 与 Resource Share 权限。

## 6. 测试

静态检查（无需云账号）：`fmt` + `init -backend=false` + `validate`，见
[../tests/README.md](../tests/README.md)。`plan` 需 sandbox 目标账号凭证。

## 7. 回滚

- 先下线使用该角色的自动化任务或访问分配。
- 删除 Resource Share 或移除 target。
- 删除 RAM role policy attachment，再删除 RAM role。

## 8. 常见故障排查

| 现象 | 可能原因 | 处理 |
|---|---|---|
| AssumeRole 被拒绝 | `trusted_principals` 不匹配或 Condition 不满足 | 对齐源主体 ARN、ExternalId、SourceIp 等条件 |
| 权限不足 | 只附加了 read-only 策略 | 明确需要的最小写权限，优先自定义策略 |
| 资源共享失败 | target 不在允许范围或资源 ARN 不支持共享 | 检查 Resource Share 支持矩阵与 `allow_external_targets` |
| 审计无法追踪 | 使用长期 AK 而非 STS | 改用 RAM role + STS/OIDC |
