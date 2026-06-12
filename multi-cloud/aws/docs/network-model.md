# AWS Network Model

## 目标

AWS Landing Zone 网络模型分为两层：`30-network` 承载账号内 VPC baseline，`35-connectivity` 承载跨账号、跨 VPC 的 Transit Gateway hub-spoke 互联。`30-network` 第一版覆盖 VPC、subnet、route table、IGW/NAT、VPC endpoint、安全组和 Flow Logs；`35-connectivity` 负责 TGW、传播和跨账号共享。

## 云原生服务

- VPC / Subnet / Route Table：账号内网络边界和路由基线。
- Internet Gateway / NAT Gateway：受控公网出入口。
- VPC Endpoint：优先私网访问 AWS 服务。
- Security Group：最小网络访问边界。
- VPC Flow Logs：网络流量审计。
- Transit Gateway / AWS RAM：跨账号互联与共享，由 `modules/connectivity` 承载。

## 模块边界

由 [`modules/network`](../modules/network) 和 [`modules/connectivity`](../modules/connectivity) 分层实现。

`modules/network` 负责：

- 创建 VPC、subnet、route table 和 subnet association。
- 可选创建 Internet Gateway、NAT Gateway、VPC Endpoint。
- 创建 baseline security groups。
- 创建 VPC Flow Logs 到已有 S3/CloudWatch/Kinesis destination。

`modules/connectivity` 负责：

- 创建或消费 TGW、TGW route table、VPC attachment、association、propagation、显式 route、RAM share。

不负责：

- 创建 Network Firewall、inspection appliance、DNS resolver rules 或跨账号 attachment acceptor。

下游协作：

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

`modules/network` 主要输入：

- `vpc`
- `subnets`
- `route_tables`
- `nat_gateways`
- `vpc_endpoints`
- `security_groups`
- `flow_logs`

`modules/connectivity` 主要输入：

- `create_transit_gateway`、`transit_gateway_id`、`transit_gateway_arn`
- `transit_gateway`
- `route_tables`
- `vpc_attachments`
- `routes`
- `ram_shares`

主要输出：

- `vpc_id`
- `subnet_ids`
- `route_table_ids`
- `security_group_ids`
- `transit_gateway_id`
- `transit_gateway_arn`
- `vpc_attachment_ids`
- `ram_resource_share_arns`

依赖：

- `30-network` 需要已规划 CIDR、AZ、flow log destination 和 endpoint 策略。
- `35-connectivity` 需要 VPC 和 attachment subnet 已存在。
- 网络账号具备 EC2 TGW 和 RAM 权限。
- 跨账号共享需目标账号或组织启用 RAM 接收/共享流程。

## 测试

静态检查：

```bash
terraform -chdir=multi-cloud/aws/examples/connectivity fmt -check -recursive
terraform -chdir=multi-cloud/aws/examples/connectivity init -backend=false
terraform -chdir=multi-cloud/aws/examples/connectivity validate

terraform -chdir=multi-cloud/aws/examples/network fmt -check -recursive
terraform -chdir=multi-cloud/aws/examples/network init -backend=false
terraform -chdir=multi-cloud/aws/examples/network validate

terraform -chdir=multi-cloud/aws/live/30-network fmt -check -recursive
terraform -chdir=multi-cloud/aws/live/30-network init -backend=false
terraform -chdir=multi-cloud/aws/live/30-network validate

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
