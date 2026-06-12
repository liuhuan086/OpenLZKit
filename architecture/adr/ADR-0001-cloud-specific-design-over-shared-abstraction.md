# ADR-0001: Use Cloud-Specific Landing Zone Designs Instead of a Universal Multi-Cloud Abstraction

## Status

Accepted

## Context

OpenLZKit supports Alibaba Cloud, AWS, Tencent Cloud, Azure and Google Cloud. These clouds have different governance primitives: accounts, subscriptions, projects, folders, OUs, management groups, roles, policies, networks and logging services.

## Decision

OpenLZKit will not create a single universal Terraform abstraction for all clouds. Each cloud will have its own directory, modules and design documents. The project will share standards for documentation, testing, CI/CD, naming, tags and contribution workflow.

## Consequences

Positive:

- Preserves cloud-native best practices.
- Easier to explain in interviews and enterprise reviews.
- Avoids leaky abstractions.

Negative:

- More directories and documents to maintain.
- Some duplicated concepts across clouds.

The tradeoff is acceptable because Landing Zone is governance-heavy and must respect native provider capabilities.
