locals {
  # Chart values set by the module itself; callers must not override them
  module_managed_values = ["humanitec.org", "humanitec.privateKey"]

  agent_private_key = coalesce(one(tls_private_key.agent[*].private_key_pem_pkcs8), var.agent_private_key)
  # A public key is not secret, so it is exposed without the sensitive marking of the variable
  agent_public_key = coalesce(one(tls_private_key.agent[*].public_key_pem), nonsensitive(var.agent_public_key))

  agent_id          = coalesce(var.agent_id, one([for s in random_string.agent_id_suffix : "humanitec-agent-${s.result}"]))
  agent_description = coalesce(var.agent_description, local.agent_id)
}

# Random suffix for the Agent ID used only if no agent_id is passed in
resource "random_string" "agent_id_suffix" {
  count = var.agent_id == null ? 1 : 0

  length  = 8
  upper   = false
  special = false
}

# Convenience key used only if no agent_private_key is passed in. Not recommended for production use.
resource "tls_private_key" "agent" {
  # An empty or blank agent_private_key counts as not passed in
  count = nonsensitive(try(trimspace(var.agent_private_key), "") == "") ? 1 : 0

  algorithm = "RSA"
  rsa_bits  = 4096
}

# Helm chart installation on target cluster
resource "helm_release" "humanitec_agent" {
  name             = var.helm_release_name
  namespace        = var.helm_release_namespace
  create_namespace = var.helm_release_create_namespace

  repository = var.helm_release_repository
  chart      = var.helm_release_chart
  version    = var.helm_release_version

  repository_ca_file   = var.helm_release_repository_ca_file
  repository_cert_file = var.helm_release_repository_cert_file
  repository_key_file  = var.helm_release_repository_key_file
  repository_username  = var.helm_release_repository_username
  repository_password  = var.helm_release_repository_password
  pass_credentials     = var.helm_release_pass_credentials
  devel                = var.helm_release_devel
  verify               = var.helm_release_verify
  keyring              = var.helm_release_keyring

  description                = var.helm_release_description
  atomic                     = var.helm_release_atomic
  cleanup_on_fail            = var.helm_release_cleanup_on_fail
  dependency_update          = var.helm_release_dependency_update
  disable_crd_hooks          = var.helm_release_disable_crd_hooks
  disable_openapi_validation = var.helm_release_disable_openapi_validation
  disable_webhooks           = var.helm_release_disable_webhooks
  force_update               = var.helm_release_force_update
  lint                       = var.helm_release_lint
  max_history                = var.helm_release_max_history
  postrender                 = var.helm_release_postrender
  recreate_pods              = var.helm_release_recreate_pods
  render_subchart_notes      = var.helm_release_render_subchart_notes
  replace                    = var.helm_release_replace
  reset_values               = var.helm_release_reset_values
  reuse_values               = var.helm_release_reuse_values
  skip_crds                  = var.helm_release_skip_crds
  take_ownership             = var.helm_release_take_ownership
  timeout                    = var.helm_release_timeout
  upgrade_install            = var.helm_release_upgrade_install
  wait                       = var.helm_release_wait
  wait_for_jobs              = var.helm_release_wait_for_jobs

  values = var.helm_release_values

  set = concat([
    {
      name  = "humanitec.org"
      value = var.humanitec_org_id
    }
  ], var.helm_release_set)
  set_list = var.helm_release_set_list
  set_sensitive = concat([
    {
      name  = "humanitec.privateKey"
      value = local.agent_private_key
    }
  ], coalesce(var.helm_release_set_sensitive, []))
  set_wo          = var.helm_release_set_wo
  set_wo_revision = var.helm_release_set_wo_revision
}

# Orchestrator Resource Definition for the Agent
resource "humanitec_resource_definition" "agent" {
  id   = local.agent_id
  name = local.agent_description
  type = "agent"

  driver_type = "humanitec/agent"
  driver_inputs = {
    values_string = jsonencode({
      id = local.agent_id
    })
  }
}

# Agent registration in the Orchestrator
resource "humanitec_agent" "agent" {
  id          = local.agent_id
  description = local.agent_description
  public_keys = [
    {
      key = local.agent_public_key
    }
  ]
}
