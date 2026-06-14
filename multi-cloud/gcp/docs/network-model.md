# Google Cloud Network Model

## 目标

GCP 网络模型优先使用 Shared VPC：网络 project 作为 host project，业务 project 作为 service project 接入指定子网。跨 VPC、跨区域和混合云互联可使用 VPC Peering、Cloud VPN、Cloud Interconnect 或 Network Connectivity Center。默认网络必须删除或禁止，prod/nonprod/sandbox 路由域分离。

## 云原生服务

- VPC Network / Subnetwork：自定义网络和区域子网。
- Firewall Rules：东西向和南北向访问控制。
- Shared VPC：host/service project 模型。
- Cloud Router / Cloud NAT：动态路由和受控出网。
- Private Service Connect / Private Google Access：私网访问 Google/PaaS 服务。
- Network Connectivity Center：大规模 hub/spoke 互联。
- VPC Flow Logs：网络审计和排障。

## 模块边界

- [`modules/network`](../modules/network)：VPC、子网、防火墙、NAT、日志。
- [`modules/connectivity`](../modules/connectivity)：Shared VPC host/service、NCC hub/spoke、跨项目接入。
- [`modules/delegation`](../modules/delegation)：Folder/子网级网络委派。

不负责：

- 专线供应商、Cloud Interconnect 物理连接。
- 应用负载均衡和服务网格。
- 跨云路由策略的生产级自动收敛。

## 推荐网络域

| 域 | 位置 | 默认策略 |
|---|---|---|
| `network-host-prod` | network project | 生产 Shared VPC host，只服务 prod project。 |
| `network-host-nonprod` | network project | 非生产 Shared VPC host。 |
| `shared-services` | platform project | DNS、代理、镜像、制品库。 |
| `sandbox` | 独立 project | 不接入 prod Shared VPC。 |

## 输入、输出与依赖

主要输入：

- `project_id`
- `networks`
- `subnets`
- `firewall_rules`
- `shared_vpc_host_projects`
- `shared_vpc_service_projects`
- `ncc_hubs`
- `ncc_spokes`

主要输出：

- `network_ids`
- `subnet_ids`
- `shared_vpc_service_project_ids`
- `ncc_hub_ids`

依赖：

- IPAM 已规划非重叠 CIDR。
- host 和 service project 已存在。
- 执行身份具备 Compute Network Admin、Shared VPC Admin 或对应最小权限。

## 测试

```bash
terraform -chdir=multi-cloud/gcp/live/30-network init -backend=false
terraform -chdir=multi-cloud/gcp/live/30-network validate
terraform -chdir=multi-cloud/gcp/live/35-connectivity init -backend=false
terraform -chdir=multi-cloud/gcp/live/35-connectivity validate
```

集成测试：创建 nonprod host project 和一个 service project，验证 service project 只能使用授权子网，sandbox project 不可接入 prod host。

## 回滚

- 先从 service project 移除业务资源对共享子网的依赖。
- 移除 Shared VPC service project 关联。
- 删除 NCC spoke、peering 或 route。
- 最后删除 subnet 和 VPC。

## 常见故障

| 现象 | 排查 |
|---|---|
| Service project 不能用子网 | 检查 Shared VPC association 和 subnet IAM。 |
| 默认网络被创建 | 用 Org Policy 禁止自动创建 default network。 |
| 出网失败 | 检查 Cloud NAT、routes、防火墙 egress 和 Private Google Access。 |
| Flow Logs 缺失 | 检查 subnet flow logs 开关和采样配置。 |
