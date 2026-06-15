# Expected AWS OU Tree

```text
management account
├── security
│   ├── log-archive
│   └── security-tooling
├── infrastructure
│   ├── network
│   └── shared-services
├── workloads
│   ├── dev
│   │   └── app-dev-payments
│   └── prod
│       └── app-prod-payments
└── sandbox
```

## Review Points

- Management account does not run workloads.
- Log archive and security tooling are isolated from workload accounts.
- Dev and prod are separate accounts under separate workload OUs.
- Sandbox is outside prod connectivity and policy promotion paths.
