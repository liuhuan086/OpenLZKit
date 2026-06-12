# GCP tests

Static checks run locally without a project; `plan`/integration checks require a
sandbox project/organization with the appropriate IAM.

## Static (no project) — CI gate

```bash
# format
terraform fmt -check -recursive

# validate every module and live stack (backend disabled)
terraform -chdir=live/00-bootstrap init -backend=false && terraform -chdir=live/00-bootstrap validate
terraform -chdir=live/10-org      init -backend=false && terraform -chdir=live/10-org      validate
```

## Plan / integration (sandbox project) — manual

```bash
# short-lived credentials via Workload Identity Federation / gcloud auth
terraform -chdir=live/10-org plan -var project_id=<seed-project> -var org_id=<org-number>
```

## Coverage

| Target | fmt | validate | plan | notes |
|---|:--:|:--:|:--:|---|
| `live/00-bootstrap` | ✅ | ✅ | proj | local state → migrate to GCS; WIF CI identity |
| `modules/org` + `live/10-org` | ✅ | ✅ | proj | folder hierarchy |
| `modules/project-factory` | ✅ | ✅ | proj | project vending (off by default) |

See the repository-wide cases in [tests/TEST_CASES.md](../../../tests/TEST_CASES.md).
