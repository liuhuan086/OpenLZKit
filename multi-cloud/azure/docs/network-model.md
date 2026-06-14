# Azure Network Model

## 目标

Azure 网络模型以 Connectivity 订阅为中心，按企业规模选择 Hub-Spoke 或 Virtual WAN。应用订阅不直接暴露公网管理入口；共享 DNS、出入口、检查设备、私有端点和跨本地连接集中治理。网络设计必须先定 CIDR、路由域、DNS 和环境隔离，再创建 VNet。

## 云原生服务

- Virtual Network / Subnet：应用与平台网络边界。
- Network Security Group：子网或网卡级访问控制。
- Route Table / User Defined Route：导向防火墙、NVA 或 Virtual WAN hub。
- Azure Firewall / NAT Gateway：受控出入口。
- Private DNS Zone / Private Endpoint：云服务私网访问。
- VNet Peering / Virtual WAN：Hub-Spoke 或大规模互联。
- Network Watcher / NSG Flow Logs：网络排障与审计。

## 模块边界

- [`modules/network`](../modules/network)：VNet、子网、NSG、路由表、NAT、Private DNS 基线。
- [`modules/connectivity`](../modules/connectivity)：VNet peering、hub/spoke 接入、共享网络互联。

不负责：

- 企业专线、VPN 或 ExpressRoute circuit 的运营合同。
- 应用层负载均衡和服务网格。
- 复杂 NVA HA 方案，需单独设计。

## 推荐网络域

| 域 | 典型位置 | 默认策略 |
|---|---|---|
| `connectivity` | 平台连接订阅 | Hub、Firewall、DNS、ExpressRoute/VPN。 |
| `management` | 管理订阅 | Bastion、监控、自动化入口。 |
| `prod` | 生产应用订阅 | 只接入 hub，不与 sandbox peering。 |
| `nonprod` | 开发/测试订阅 | 接入 shared services，默认不进 prod。 |
| `sandbox` | sandbox 管理组/订阅 | 可独立出网，禁止访问 prod。 |

## 输入、输出与依赖

主要输入：

- `vnets`
- `subnets`
- `network_security_groups`
- `route_tables`
- `peerings`
- `private_dns_zones`
- `flow_logs`

主要输出：

- `vnet_ids`
- `subnet_ids`
- `nsg_ids`
- `route_table_ids`
- `private_dns_zone_ids`

依赖：

- IPAM 已分配非重叠 CIDR。
- 连接订阅和应用订阅之间已有最小 RBAC。
- 如使用 Private Endpoint，需要目标 PaaS 服务和 DNS zone 链接策略。

## 测试

```bash
terraform -chdir=multi-cloud/azure/live/30-network init -backend=false
terraform -chdir=multi-cloud/azure/live/30-network validate
terraform -chdir=multi-cloud/azure/live/35-connectivity init -backend=false
terraform -chdir=multi-cloud/azure/live/35-connectivity validate
```

集成测试：创建 hub + 一个 nonprod spoke，确认 UDR 指向防火墙或 hub，NSG 默认拒绝高危入站，Private DNS zone 能被 spoke 解析。

## 回滚

- 先撤销应用路由和 Private Endpoint 依赖。
- 删除 peering，再删除 spoke VNet。
- 删除 NSG/route table association 后再删资源。
- 最后删除 hub 资源；生产 hub 不应和测试 spoke 一起销毁。

## 常见故障

| 现象 | 排查 |
|---|---|
| Peering 创建失败 | 检查两个 VNet CIDR 是否重叠、权限是否跨订阅可用。 |
| Private Endpoint 无法解析 | 检查 Private DNS zone link 和 A 记录。 |
| 出网不通 | 检查 UDR、Azure Firewall/NAT Gateway、NSG 出站规则。 |
| Prod/Sandbox 串通 | 检查是否误建 peering、是否存在过宽 hub route propagation。 |
