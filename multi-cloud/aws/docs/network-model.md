# AWS Network Model

## 目标

AWS Landing Zone 网络模型分为两层：`30-network` 承载未来 VPC baseline，`35-connectivity` 承载跨账号、跨 VPC 的 Transit Gateway hub-spoke 互联。FP-6 聚焦互联层：网络账号集中创建 Transit Gateway、显式路由表、VPC attachment、传播规则、黑洞路由和 AWS RAM 共享。

## 云原生服务

- Transit Gateway：企业 hub-spoke 私网互联骨干。
- Transit Gateway route table：按 shared、prod、nonprod、sandbox 等网络域隔离传播与路由。
- Transit Gateway VPC attachment：把 VPC 接入 TGW。
- AWS RAM：把 TGW 或其他网络资源共享给业务账号。

## 模块边界

由 [`modules/connectivity`](../modules/connectivity) 实现：

- **负责**：创建或消费 TGW、创建 TGW route table、VPC attachment、route table association、route table propagation、显式 TGW route、AWS RAM share。
- **不负责**：创建 VPC/subnet、防火墙、检查 VPC、NAT、DNS、endpoint 或跨账号 attachment 接受流程。

下游协作：

- 后续 `modules/network` 创建 VPC baseline 和 subnet。
- `modules/cross-account-access` 创建网络自动化角色。
- `modules/delegation` 启用组织级 RAM 共享和网络服务委派。

## 推荐网络域

| route table key | 用途 | 默认传播 |
|---|---|---|
| `shared` | shared services、DNS、endpoint、平台服务 | 接收 prod/nonprod，按需接收 network inspection |
| `prod` | 生产业务 VPC | 只传播到 shared 或 inspection，不传播到 sandbox |
| `nonprod` | 开发、测试、预发 VPC | 传播到 shared，默认不进 prod |
| `sandbox` | 实验环境 VPC | 默认不传播到 prod/nonprod，可加黑洞路由 |

设计原则：TGW 默认路由表关联和传播关闭；每个 attachment 明确关联一个 route table；传播目标必须显式声明。

## 输入、输出与依赖

主要输入：

- `create_transit_gateway`、`transit_gateway_id`、`transit_gateway_arn`
- `transit_gateway`
- `route_tables`
- `vpc_attachments`
- `routes`
- `ram_shares`

主要输出：

- `transit_gateway_id`
- `transit_gateway_arn`
- `route_table_ids`
- `vpc_attachment_ids`
- `ram_resource_share_arns`

依赖：

- VPC 和 attachment subnet 已存在。
- 网络账号具备 EC2 TGW 和 RAM 权限。
- 跨账号共享需目标账号或组织启用 RAM 接收/共享流程。

## 测试

静态检查：

```bash
terraform -chdir=multi-cloud/aws/examples/connectivity fmt -check -recursive
terraform -chdir=multi-cloud/aws/examples/connectivity init -backend=false
terraform -chdir=multi-cloud/aws/examples/connectivity validate

terraform -chdir=multi-cloud/aws/live/35-connectivity fmt -check -recursive
terraform -chdir=multi-cloud/aws/live/35-connectivity init -backend=false
terraform -chdir=multi-cloud/aws/live/35-connectivity validate
```

集成验证：

- 在 sandbox 网络账号创建 TGW 和四张路由表。
- 接入 shared、prod、sandbox 三个测试 VPC。
- 确认 sandbox 不传播到 prod，且 sandbox 到 prod CIDR 的黑洞路由存在。
- 通过 RAM 只共享给 sandbox 业务账号，再逐步推广。

## 回滚

- 先移除业务 VPC 路由表里指向 TGW 的路由。
- 删除 TGW route 和 propagation。
- 删除 route table association，再删除 VPC attachment。
- 移除 RAM principal/resource association，再删除 resource share。
- 最后删除 TGW route table 和 TGW。

## 常见故障

| 现象 | 排查 |
|---|---|
| Attachment 无法创建 | 检查 subnet 是否来自同一 VPC 且覆盖目标 AZ，调用方是否有 EC2 权限。 |
| 路由不通 | 检查 association、propagation、TGW route 和 VPC route table 是否同时存在。 |
| sandbox 可达 prod | 检查 sandbox 是否传播到了 prod route table，是否缺少黑洞路由。 |
| RAM 共享不可见 | 检查 principal、组织共享设置、目标账号是否接受共享。 |
