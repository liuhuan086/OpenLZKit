# live/50-logging (GCP)

Central audit: a hardened log-archive bucket in the logging project and an
aggregated folder sink (`include_children`) routing Cloud Audit Logs from the
org root folder to it.

## State

```bash
terraform init -backend-config="bucket=my-lz-tfstate"
```

## Workflow

```bash
terraform validate
terraform plan \
  -var logging_project_id=<logging-project> \
  -var log_bucket_name=my-lz-log-archive \
  -var org_folder_id=folders/<root-folder-id>
# apply after PR review + approval
```
