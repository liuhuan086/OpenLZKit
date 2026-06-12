# Alibaba Cloud Delegation Model

## 1. 解决的企业问题

管理账号不应承载日常审计、合规、身份和网络运营工作。企业 Landing Zone 需要把
服务管理能力委派给专用成员账号，同时通过 Resource Share 共享网络、镜像或其他
基础设施资源，而不是给业务账号直接授予平台账号权限。

## 2. 使用的云原生服务

- **Resource Directory delegated administrator**：把指定服务的管理权委派给成员账号。
- **CloudSSO delegated account**：把 CloudSSO 管理委派给身份账号。
- **Resource Share**：把共享资源授权给目标账号或组织内目标。

## 3. Terraform 模块边界

由 [`modules/delegation`](../modules/delegation) 实现：

- **负责**：delegated administrator、CloudSSO delegate account、Resource Share。
- **不负责**：创建成员账号、创建共享资源本身、创建跨账号 RAM role。

## 4. 推荐委派模型

| 委派对象 | 推荐账号 | 目的 |
|---|---|---|
| Cloud Config | security/compliance account | 运行时合规聚合 |
| Resource Sharing | network/shared-services account | 共享网络与基础设施资源 |
| CloudSSO | identity account | 人员访问管理 |

## 5. 输入、输出与依赖

- 输入：`delegated_administrators`、`cloud_sso_delegate_account_id`、`resource_shares`。
- 输出：`delegated_administrator_ids`、`cloud_sso_delegate_account_id`、`resource_share_ids`。
- 依赖：Resource Directory 已启用；成员账号已存在；共享资源已存在。

## 6. 测试

静态检查（无需云账号）：`fmt` + `init -backend=false` + `validate`，见
[../tests/README.md](../tests/README.md)。`plan` 需 sandbox 管理账号凭证。

## 7. 回滚

- 先迁移依赖该委派账号的服务配置。
- 删除 Resource Share 或移除 target。
- 取消 CloudSSO delegated account。
- 删除 Resource Directory delegated administrator。

## 8. 常见故障排查

| 现象 | 可能原因 | 处理 |
|---|---|---|
| 委派失败 | service principal 不正确或服务不支持委派 | 使用对应云服务官方 service principal |
| 共享失败 | resource ARN/target 不支持 Resource Share | 检查资源共享支持矩阵与目标账号 |
| 外部账号收到共享 | `allow_external_targets` 被打开 | 默认为 false，仅审批后开启 |
| 管理账号仍在日常操作 | 下游 live stack 未迁移到委派账号 | 将合规/身份/网络 stack 的执行身份切到专用账号 |
