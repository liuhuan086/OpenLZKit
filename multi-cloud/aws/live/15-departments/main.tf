module "departments" {
  source = "../../modules/department"

  name_prefix  = "lz-"
  parent_ou_id = var.workloads_parent_ou_id
  departments  = var.departments
}
