# Tencent Cloud Network Model

## 目标

腾讯云网络模型以 VPC 为账号内隔离边界，以 CCN（云联网）承载跨 VPC、跨账号、跨地域互联。生产、非生产和 sandbox 默认隔离；只有经审批的 VPC 接入 hub CCN。公网入口通过 CLB、NAT Gateway、防火墙和安全组集中控制。

## 云原生服务

- VPC / Subnet：账号内网络边界。
- Security Group / Network ACL：访问控制。
- NAT Gateway / EIP：受控出网。
- CCN：多 VPC、多账号和混合云互联。
- CCN Route Table：路由域隔离和传播控制。
- Private DNS / TDMQ/PrivateLink 类私网接入能力：按服务选择。
- Flow Logs / CLS：网络流量审计。

## 模块边界

- [`modules/network`](../modules/network)：VPC、子网、安全组、NAT 和基础路由。
- [`modules/connectivity`](../modules/connectivity)：CCN、`tencentcloud_ccn_attachment_v2` 和 VPC 挂载。
- [`modules/delegation`](../modules/delegation)：组织共享和跨账号网络委派。

不负责：

- 专线物理链路、IDC 侧路由和运营商交付。
- 应用层 CLB/WAF 完整配置。
- 生产级流量检查设备 HA 方案。

## 推荐网络域

| 域 | 默认策略 |
|---|---|
| `shared` | 接入日志、制品库、DNS、公共服务。 |
| `prod` | 只与 shared 或检查域互通，不与 sandbox 互通。 |
| `nonprod` | 可与 shared 互通，生产访问需审批。 |
| `sandbox` | 默认不挂载到 prod CCN。 |

## 输入、输出与依赖

主要输入：

- `vpcs`
- `subnets`
- `security_groups`
- `route_tables`
- `ccn_name`
- `attachments`

主要输出：

- `vpc_ids`
- `subnet_ids`
- `security_group_ids`
- `ccn_id`
- `attachment_ids`

依赖：

- IPAM 已规划不重叠 CIDR。
- 跨账号挂载需要目标账号授权。
- CCN 路由表和带宽策略需提前定义。

## 测试

```bash
terraform -chdir=multi-cloud/tencentcloud/live/30-network init -backend=false
terraform -chdir=multi-cloud/tencentcloud/live/30-network validate
terraform -chdir=multi-cloud/tencentcloud/live/35-connectivity init -backend=false
terraform -chdir=multi-cloud/tencentcloud/live/35-connectivity validate
```

集成测试：创建 shared 和 nonprod VPC 并挂载 CCN，确认路由可达；sandbox VPC 不挂载或路由不可达 prod CIDR。

## 回滚

- 先删除业务路由和安全组放行。
- 从 CCN 移除 VPC attachment。
- 删除 route table association，再删除 VPC/subnet。
- 跨账号网络回滚要通知目标账号 owner。

## 常见故障

| 现象 | 排查 |
|---|---|
| CCN 挂载失败 | 检查实例地域、VPC id、跨账号授权和 CCN 配额。 |
| 路由不通 | 检查 CCN route table、VPC 路由表、安全组和网络 ACL。 |
| Sandbox 可达 Prod | 检查是否误挂载同一 CCN 或缺少路由域隔离。 |
| 出网异常 | 检查 NAT Gateway、EIP、默认路由和安全组 egress。 |
