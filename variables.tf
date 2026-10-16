variable "humanitec_org_id" {
  description = "Humanitec Organization ID"
  type        = string
  nullable    = false
}
variable "agent_private_key" {
  description = "Private key for the Humanitec Agent authentication. Must be a multiline string starting with -----BEGIN PRIVATE KEY----- and having a final line break. Both or neither of `agent_public_key` and `agent_private_key` must be set. If not set, a convenience key pair will be generated using a `tls_private_key` resource and stored in the Terraform state, but this is not recommended for production use."
  type        = string
  sensitive   = true
  nullable    = true
  default     = null
  validation {
    condition     = (try(trimspace(var.agent_private_key), "") != "") == (try(trimspace(var.agent_public_key), "") != "")
    error_message = "Either both or neither of agent_private_key and agent_public_key must be set to a non-empty value. Leave both unset to generate a convenience key."
  }
}
variable "agent_public_key" {
  description = "Public key for the Humanitec Agent authentication. Must be a multiline string starting with -----BEGIN PUBLIC KEY----- and having a final line break. Both or neither of `agent_public_key` and `agent_private_key` must be set. If not set, a convenience key pair will be generated using a `tls_private_key` resource and stored in the Terraform state, but this is not recommended for production use."
  type        = string
  nullable    = true
  default     = null
}
variable "agent_id" {
  description = "ID for this agent. Must be 2–63 chars, only lowercase letters, digits and single hyphens, no leading/trailing hyphen. Will be used as the ID for both the Resource Definition and the Agent registration. If not set, an ID with a random suffix will be generated"
  type        = string
  nullable    = true
  default     = null

  validation {
    condition     = var.agent_id == null ? true : length(var.agent_id) >= 2 && length(var.agent_id) <= 63
    error_message = "agent_id must be between 2 and 63 characters long"
  }
  validation {
    condition     = var.agent_id == null || can(regex("^[a-z0-9](?:-?[a-z0-9]+)+$", var.agent_id))
    error_message = "agent_id must only contain lowercase letters, digits, and single hyphens, and must not start or end with a hyphen"
  }
}
variable "agent_description" {
  description = "Description for this agent. Will be used as the name of the Resource Definition and description in the Agent registration. If not set, will be set to the value of `agent_id`"
  type        = string
  nullable    = true
  default     = null
}
variable "helm_release_namespace" {
  description = "Kubernetes namespace where to install the Agent"
  type        = string
  nullable    = true
  default     = "humanitec-agent"
}
variable "helm_release_create_namespace" {
  description = "Choose whether to create the Kubernetes namespace"
  type        = bool
  default     = true
}
variable "helm_release_name" {
  type        = string
  description = "Name of the Helm release for the Agent"
  nullable    = true
  default     = "humanitec-agent"
}
variable "helm_release_version" {
  type        = string
  description = "Chart version to use for the Agent installation in the format `X.Y.Z`. If this is not specified, the latest version is installed."
  nullable    = true
  default     = null
}
variable "helm_release_repository" {
  description = "Repository where to locate the requested chart. If is a URL the chart is installed without installing the repository."
  type        = string
  nullable    = true
  default     = "oci://ghcr.io/humanitec/charts"
}
variable "helm_release_chart" {
  description = "Chart name to be installed. A path may be used."
  type        = string
  nullable    = false
  default     = "humanitec-agent"
}

# Optional attributes of the helm_release resource.
# Descriptions taken from https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release
# A value of null leaves the attribute unset so the provider default applies.
variable "helm_release_atomic" {
  description = "If set, installation process purges chart on fail. The wait flag will be set automatically if atomic is used. Defaults to `false`."
  type        = bool
  default     = null
}
variable "helm_release_cleanup_on_fail" {
  description = "Allow deletion of new resources created in this upgrade when upgrade fails. Defaults to `false`."
  type        = bool
  default     = null
}
variable "helm_release_dependency_update" {
  description = "Run helm dependency update before installing the chart. Defaults to `false`."
  type        = bool
  default     = null
}
variable "helm_release_description" {
  description = "Add a custom description"
  type        = string
  default     = null
}
variable "helm_release_devel" {
  description = "Use chart development versions, too. Equivalent to version '>0.0.0-0'. If `version` is set, this is ignored"
  type        = bool
  default     = null
}
variable "helm_release_disable_crd_hooks" {
  description = "Prevent CRD hooks from, running, but run other hooks.  See helm install --no-crd-hook"
  type        = bool
  default     = null
}
variable "helm_release_disable_openapi_validation" {
  description = "If set, the installation process will not validate rendered templates against the Kubernetes OpenAPI Schema. Defaults to `false`."
  type        = bool
  default     = null
}
variable "helm_release_disable_webhooks" {
  description = "Prevent hooks from running.Defaults to `false`."
  type        = bool
  default     = null
}
variable "helm_release_force_update" {
  description = "Force resource update through delete/recreate if needed. Defaults to `false`."
  type        = bool
  default     = null
}
variable "helm_release_keyring" {
  description = "Location of public keys used for verification. Used only if `verify` is true. Defaults to `/.gnupg/pubring.gpg` in the location set by `home`."
  type        = string
  default     = null
}
variable "helm_release_lint" {
  description = "Run helm lint when planning. Defaults to `false`."
  type        = bool
  default     = null
}
variable "helm_release_max_history" {
  description = "Limit the maximum number of revisions saved per release. Use 0 for no limit. Defaults to 0 (no limit)."
  type        = number
  default     = null
}
variable "helm_release_pass_credentials" {
  description = "Pass credentials to all domains. Defaults to `false`."
  type        = bool
  default     = null
}
variable "helm_release_postrender" {
  description = "Postrender command configuration."
  type = object({
    binary_path = string
    args        = optional(list(string))
  })
  default = null
}
variable "helm_release_recreate_pods" {
  description = "Perform pods restart during upgrade/rollback. Defaults to `false`."
  type        = bool
  default     = null
}
variable "helm_release_render_subchart_notes" {
  description = "If set, render subchart notes along with the parent. Defaults to `true`."
  type        = bool
  default     = null
}
variable "helm_release_replace" {
  description = "Re-use the given name, even if that name is already used. This is unsafe in production. Defaults to `false`."
  type        = bool
  default     = null
}
variable "helm_release_repository_ca_file" {
  description = "The Repositories CA File"
  type        = string
  default     = null
}
variable "helm_release_repository_cert_file" {
  description = "The repositories cert file"
  type        = string
  default     = null
}
variable "helm_release_repository_key_file" {
  description = "The repositories cert key file"
  type        = string
  default     = null
}
variable "helm_release_repository_password" {
  description = "Password for HTTP basic authentication"
  type        = string
  sensitive   = true
  default     = null
}
variable "helm_release_repository_username" {
  description = "Username for HTTP basic authentication"
  type        = string
  default     = null
}
variable "helm_release_reset_values" {
  description = "When upgrading, reset the values to the ones built into the chart. Defaults to `false`."
  type        = bool
  default     = null
}
variable "helm_release_reuse_values" {
  description = "When upgrading, reuse the last release's values and merge in any overrides. If 'reset_values' is specified, this is ignored. Defaults to `false`."
  type        = bool
  default     = null
}
variable "helm_release_set" {
  description = "Custom values to be merged with the values."
  type = list(object({
    name  = string
    value = optional(string)
    type  = optional(string)
  }))
  nullable = false
  default  = []
  validation {
    condition     = alltrue([for s in var.helm_release_set : !contains(local.module_managed_values, s.name)])
    error_message = "The values ${join(", ", local.module_managed_values)} are set by the module and cannot be overridden."
  }
}
variable "helm_release_set_wo" {
  description = "Custom values to be merged with the values. This is the same as \"set\" but write-only."
  type = list(object({
    name  = string
    value = string
    type  = optional(string)
  }))
  ephemeral = true
  default   = null
  validation {
    condition     = alltrue([for s in coalesce(var.helm_release_set_wo, []) : !contains(local.module_managed_values, s.name)])
    error_message = "The values ${join(", ", local.module_managed_values)} are set by the module and cannot be overridden."
  }
}
variable "helm_release_set_wo_revision" {
  description = "The current revision of the write-only \"set_wo\" attribute. Incrementing this integer value will cause Terraform to update the write-only value."
  type        = number
  default     = null
}
variable "helm_release_set_list" {
  description = "Custom list values to be merged with the values."
  type = list(object({
    name  = string
    value = list(string)
  }))
  default = null
  validation {
    condition     = alltrue([for s in coalesce(var.helm_release_set_list, []) : !contains(local.module_managed_values, s.name)])
    error_message = "The values ${join(", ", local.module_managed_values)} are set by the module and cannot be overridden."
  }
}
variable "helm_release_set_sensitive" {
  description = "Custom sensitive values to be merged with the values."
  type = list(object({
    name  = string
    value = string
    type  = optional(string)
  }))
  sensitive = true
  default   = null
  validation {
    condition     = alltrue([for s in coalesce(var.helm_release_set_sensitive, []) : !contains(local.module_managed_values, s.name)])
    error_message = "The values ${join(", ", local.module_managed_values)} are set by the module and cannot be overridden."
  }
}
variable "helm_release_skip_crds" {
  description = "If set, no CRDs will be installed. By default, CRDs are installed if not already present. Defaults to `false`."
  type        = bool
  default     = null
}
variable "helm_release_take_ownership" {
  description = "If set, allows Helm to adopt existing resources not marked as managed by the release. Defaults to `false`."
  type        = bool
  default     = null
}
variable "helm_release_timeout" {
  description = "Time in seconds to wait for any individual kubernetes operation. Defaults to 300 seconds."
  type        = number
  default     = null
}
variable "helm_release_upgrade_install" {
  description = "If true, the provider will install the release at the specified version even if a release not controlled by the provider is present: this is equivalent to running 'helm upgrade --install' with the Helm CLI. WARNING: this may not be suitable for production use -- see the 'Upgrade Mode' note in the provider documentation. Defaults to `false`."
  type        = bool
  default     = null
}
variable "helm_release_values" {
  description = "List of values in raw yaml format to pass to helm."
  type        = list(string)
  default     = null
}
variable "helm_release_verify" {
  description = "Verify the package before installing it.Defaults to `false`."
  type        = bool
  default     = null
}
variable "helm_release_wait" {
  description = "Will wait until all resources are in a ready state before marking the release as successful. Defaults to `true`."
  type        = bool
  default     = null
}
variable "helm_release_wait_for_jobs" {
  description = "If wait is enabled, will wait until all Jobs have been completed before marking the release as successful. Defaults to `false`."
  type        = bool
  default     = null
}
