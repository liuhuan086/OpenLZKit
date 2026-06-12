# 网络设计

## 1. 目标

建立可扩展、可隔离、可审计的多云网络基础。

## 2. 推荐拓扑

### 单云内部

推荐 Hub-Spoke：

```text
Hub Network
├── shared firewall / egress
├── DNS
├── VPN / Direct Connect / ExpressRoute / Interconnect
└── Spoke Networks
    ├── dev
    ├── test
    └── prod
```

### 多云之间

推荐通过中心网络层互联，而不是业务 VPC/VNet/VPC Network 之间随意互联。

```text
AWS Transit Gateway / Cloud WAN
        |
    On-prem / SD-WAN
        |
Azure Virtual WAN / Hub VNet
        |
GCP Cloud VPN / Interconnect / NCC
```

## 3. CIDR 规划

示例：

| 环境 | CIDR 示例 |
|---|---|
| shared | 10.0.0.0/16 |
| dev | 10.10.0.0/16 |
| test | 10.20.0.0/16 |
| prod | 10.30.0.0/16 |
| sandbox | 10.90.0.0/16 |

原则：

- 不同环境不重叠。
- 多云之间不重叠。
- 为未来扩容预留空间。
- 不要直接使用公司办公网段常见范围而不登记，例如 192.168.0.0/16。

## 4. 网络安全边界

- prod 不直接接受 sandbox 访问。
- 公网入口必须经过 WAF/Load Balancer/API Gateway。
- 出口流量尽量集中。
- 管理入口使用 VPN/ZTNA/Bastion，不直接暴露 SSH/RDP。
- DNS 和证书统一管理。

## 5. OpenLZKit 中的网络建模

```yaml
network:
  strategy: hub-spoke
  cidr_blocks:
    shared: 10.0.0.0/16
    dev: 10.10.0.0/16
    prod: 10.30.0.0/16
  connectivity:
    - from: prod
      to: shared
      type: private
    - from: sandbox
      to: prod
      type: denied
```

## 6. 校验规则

- CIDR 重叠报错。
- sandbox -> prod 直连报错。
- prod 公网入口没有 reason 报 warning 或 error。
- 没有 egress 策略报 warning。

## 7. 多云互联建议（优先级）

MVP 不建议一开始做五云全互联。优先让每朵云内部 Landing Zone 成熟后，再做跨云互联，且必须经过集中网络层。

跨云互联优先级：

1. 站点到站点 VPN。
2. 专线 / ExpressRoute / Direct Connect / 等价能力。
3. 第三方 SD-WAN / SASE。
4. 跨云服务网格或应用层互通。
