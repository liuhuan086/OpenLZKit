# 网络拓扑图

OpenLZKit 使用各云原生网络模式，而不是强行抽象成单一网络模型。

## Hub-Spoke 与 Transit 模式

适用于 AWS Transit Gateway、阿里云 CEN/TR、腾讯云 CCN 和 Azure Hub-Spoke/Virtual WAN。

```mermaid
flowchart TD
  hub["互联 Hub<br/>TGW / CEN-TR / CCN / Azure Hub"]
  shared["共享服务<br/>DNS、Endpoint、构建系统"]
  prod["生产网络"]
  nonprod["非生产网络"]
  sandbox["Sandbox 网络"]
  onprem["本地 IDC / 合作方网络"]
  inspection["检查 / 防火墙路径"]

  hub --> shared
  hub --> prod
  hub --> nonprod
  hub --> onprem
  prod --> inspection
  nonprod --> inspection
  sandbox -. "默认隔离" .- hub
```

## Google Cloud Shared VPC 模式

```mermaid
flowchart LR
  host["Shared VPC host project<br/>网络团队管理"]
  prodSvc["生产 service project"]
  nonprodSvc["非生产 service project"]
  sandboxSvc["Sandbox project"]
  subnets["已批准共享子网"]

  host --> subnets
  subnets --> prodSvc
  subnets --> nonprodSvc
  sandboxSvc -. "不接入生产 host" .- host
```

## 评审问题

- CIDR 是否不重叠？
- Sandbox 是否默认与生产隔离？
- 路由表关联和传播是否显式声明？
- DNS 是否和 Private Endpoint / Private Service Access 一起设计？
- 受监管环境是否启用 Flow Logs 或等价网络日志？
