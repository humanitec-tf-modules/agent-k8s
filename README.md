> [!NOTE]
> 🚧 The content of this repository is currently being curated. Please do not use before the first release has been cut.

# Humanitec Agent on Kubernetes

This repository contains OpenTofu/Terraform modules for provisioning the [Humanitec Agent](https://developer.humanitec.com/platform-orchestrator/docs/integration-and-extensions/humanitec-agent/overview/) on a Kubernetes cluster using Helm.

TODO: link to https://developer.humanitec.com/platform-orchestrator/docs/integration-and-extensions/humanitec-agent/helm-chart-values/ for Helm Chart values

Minimal usage example: generate Agent ID and key pair

```hcl
module "agent_aks" {
  source = "github.com/humanitec-tf-modules/agent-k8s?ref=vX.Y.Z"
  providers = {
    humanitec = humanitec
    helm      = helm
  }

  humanitec_org_id     = "my-org"
  helm_release_version = "1.2.3"
}
```

Usage example with Helm Chart value:

```hcl
module "agent_aks" {
  source = "github.com/humanitec-tf-modules/agent-k8s?ref=vX.Y.Z"

  providers = {
    humanitec = humanitec
    helm      = helm
  }

  humanitec_org_id     = "my-org"
  agent_id             = "my-agent"
  agent_private_key    = "-----BEGIN PRIVATE KEY----- ..."
  agent_public_key     = "-----BEGIN PRIVATE KEY----- ..."
  helm_release_version = "1.2.3"
  # Setting Helm Chart values
  helm_release_values = [
    yamlencode({
      replicas = 2
      resources = {
        limits = {
          cpu    = "300m"
          memory = "312Mi"
        }
      }
    })
  ]
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 3.0 |
| <a name="requirement_humanitec"></a> [humanitec](#requirement\_humanitec) | ~> 1.9 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.humanitec_agent](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [humanitec_agent.agent](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/agent) | resource |
| [humanitec_resource_definition.agent](https://registry.terraform.io/providers/humanitec/humanitec/latest/docs/resources/resource_definition) | resource |
| [random_string.agent_id_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [tls_private_key.agent](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_agent_description"></a> [agent\_description](#input\_agent\_description) | Description for this agent. Will be used as the name of the Resource Definition and description in the Agent registration. If not set, will be set to the value of `agent_id` | `string` | `null` | no |
| <a name="input_agent_id"></a> [agent\_id](#input\_agent\_id) | ID for this agent. Must be unique in the Humanitec Organization. Will be used as the ID for both the Resource Definition and the Agent registration. If not set, an ID with a random suffix will be generated | `string` | `null` | no |
| <a name="input_agent_private_key"></a> [agent\_private\_key](#input\_agent\_private\_key) | Private key for the Humanitec Agent authentication. Must be a multiline string starting with -----BEGIN PRIVATE KEY----- and having a final line break. Both or neither of `agent_public_key` and `agent_private_key` must be set. If not set, a convenience key pair will be generated using a `tls_private_key` resource and stored in the Terraform state, but this is not recommended for production use. | `string` | `null` | no |
| <a name="input_agent_public_key"></a> [agent\_public\_key](#input\_agent\_public\_key) | Public key for the Humanitec Agent authentication. Must be a multiline string starting with -----BEGIN PUBLIC KEY----- and having a final line break. Both or neither of `agent_public_key` and `agent_private_key` must be set. If not set, a convenience key pair will be generated using a `tls_private_key` resource and stored in the Terraform state, but this is not recommended for production use. | `string` | `null` | no |
| <a name="input_helm_release_atomic"></a> [helm\_release\_atomic](#input\_helm\_release\_atomic) | If set, installation process purges chart on fail. The wait flag will be set automatically if atomic is used. Defaults to `false`. | `bool` | `null` | no |
| <a name="input_helm_release_chart"></a> [helm\_release\_chart](#input\_helm\_release\_chart) | Chart name to be installed. A path may be used. | `string` | `"humanitec-agent"` | no |
| <a name="input_helm_release_cleanup_on_fail"></a> [helm\_release\_cleanup\_on\_fail](#input\_helm\_release\_cleanup\_on\_fail) | Allow deletion of new resources created in this upgrade when upgrade fails. Defaults to `false`. | `bool` | `null` | no |
| <a name="input_helm_release_create_namespace"></a> [helm\_release\_create\_namespace](#input\_helm\_release\_create\_namespace) | Choose whether to create the Kubernetes namespace | `bool` | `true` | no |
| <a name="input_helm_release_dependency_update"></a> [helm\_release\_dependency\_update](#input\_helm\_release\_dependency\_update) | Run helm dependency update before installing the chart. Defaults to `false`. | `bool` | `null` | no |
| <a name="input_helm_release_description"></a> [helm\_release\_description](#input\_helm\_release\_description) | Add a custom description | `string` | `null` | no |
| <a name="input_helm_release_devel"></a> [helm\_release\_devel](#input\_helm\_release\_devel) | Use chart development versions, too. Equivalent to version '>0.0.0-0'. If `version` is set, this is ignored | `bool` | `null` | no |
| <a name="input_helm_release_disable_crd_hooks"></a> [helm\_release\_disable\_crd\_hooks](#input\_helm\_release\_disable\_crd\_hooks) | Prevent CRD hooks from, running, but run other hooks.  See helm install --no-crd-hook | `bool` | `null` | no |
| <a name="input_helm_release_disable_openapi_validation"></a> [helm\_release\_disable\_openapi\_validation](#input\_helm\_release\_disable\_openapi\_validation) | If set, the installation process will not validate rendered templates against the Kubernetes OpenAPI Schema. Defaults to `false`. | `bool` | `null` | no |
| <a name="input_helm_release_disable_webhooks"></a> [helm\_release\_disable\_webhooks](#input\_helm\_release\_disable\_webhooks) | Prevent hooks from running.Defaults to `false`. | `bool` | `null` | no |
| <a name="input_helm_release_force_update"></a> [helm\_release\_force\_update](#input\_helm\_release\_force\_update) | Force resource update through delete/recreate if needed. Defaults to `false`. | `bool` | `null` | no |
| <a name="input_helm_release_keyring"></a> [helm\_release\_keyring](#input\_helm\_release\_keyring) | Location of public keys used for verification. Used only if `verify` is true. Defaults to `/.gnupg/pubring.gpg` in the location set by `home`. | `string` | `null` | no |
| <a name="input_helm_release_lint"></a> [helm\_release\_lint](#input\_helm\_release\_lint) | Run helm lint when planning. Defaults to `false`. | `bool` | `null` | no |
| <a name="input_helm_release_max_history"></a> [helm\_release\_max\_history](#input\_helm\_release\_max\_history) | Limit the maximum number of revisions saved per release. Use 0 for no limit. Defaults to 0 (no limit). | `number` | `null` | no |
| <a name="input_helm_release_name"></a> [helm\_release\_name](#input\_helm\_release\_name) | Name of the Helm release for the Agent | `string` | `"humanitec-agent"` | no |
| <a name="input_helm_release_namespace"></a> [helm\_release\_namespace](#input\_helm\_release\_namespace) | Kubernetes namespace where to install the Agent | `string` | `"humanitec-agent"` | no |
| <a name="input_helm_release_pass_credentials"></a> [helm\_release\_pass\_credentials](#input\_helm\_release\_pass\_credentials) | Pass credentials to all domains. Defaults to `false`. | `bool` | `null` | no |
| <a name="input_helm_release_postrender"></a> [helm\_release\_postrender](#input\_helm\_release\_postrender) | Postrender command configuration. | <pre>object({<br/>    binary_path = string<br/>    args        = optional(list(string))<br/>  })</pre> | `null` | no |
| <a name="input_helm_release_recreate_pods"></a> [helm\_release\_recreate\_pods](#input\_helm\_release\_recreate\_pods) | Perform pods restart during upgrade/rollback. Defaults to `false`. | `bool` | `null` | no |
| <a name="input_helm_release_render_subchart_notes"></a> [helm\_release\_render\_subchart\_notes](#input\_helm\_release\_render\_subchart\_notes) | If set, render subchart notes along with the parent. Defaults to `true`. | `bool` | `null` | no |
| <a name="input_helm_release_replace"></a> [helm\_release\_replace](#input\_helm\_release\_replace) | Re-use the given name, even if that name is already used. This is unsafe in production. Defaults to `false`. | `bool` | `null` | no |
| <a name="input_helm_release_repository"></a> [helm\_release\_repository](#input\_helm\_release\_repository) | Repository where to locate the requested chart. If is a URL the chart is installed without installing the repository. | `string` | `"oci://ghcr.io/humanitec/charts"` | no |
| <a name="input_helm_release_repository_ca_file"></a> [helm\_release\_repository\_ca\_file](#input\_helm\_release\_repository\_ca\_file) | The Repositories CA File | `string` | `null` | no |
| <a name="input_helm_release_repository_cert_file"></a> [helm\_release\_repository\_cert\_file](#input\_helm\_release\_repository\_cert\_file) | The repositories cert file | `string` | `null` | no |
| <a name="input_helm_release_repository_key_file"></a> [helm\_release\_repository\_key\_file](#input\_helm\_release\_repository\_key\_file) | The repositories cert key file | `string` | `null` | no |
| <a name="input_helm_release_repository_password"></a> [helm\_release\_repository\_password](#input\_helm\_release\_repository\_password) | Password for HTTP basic authentication | `string` | `null` | no |
| <a name="input_helm_release_repository_username"></a> [helm\_release\_repository\_username](#input\_helm\_release\_repository\_username) | Username for HTTP basic authentication | `string` | `null` | no |
| <a name="input_helm_release_reset_values"></a> [helm\_release\_reset\_values](#input\_helm\_release\_reset\_values) | When upgrading, reset the values to the ones built into the chart. Defaults to `false`. | `bool` | `null` | no |
| <a name="input_helm_release_reuse_values"></a> [helm\_release\_reuse\_values](#input\_helm\_release\_reuse\_values) | When upgrading, reuse the last release's values and merge in any overrides. If 'reset\_values' is specified, this is ignored. Defaults to `false`. | `bool` | `null` | no |
| <a name="input_helm_release_set"></a> [helm\_release\_set](#input\_helm\_release\_set) | Custom values to be merged with the values. | <pre>list(object({<br/>    name  = string<br/>    value = optional(string)<br/>    type  = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_helm_release_set_list"></a> [helm\_release\_set\_list](#input\_helm\_release\_set\_list) | Custom list values to be merged with the values. | <pre>list(object({<br/>    name  = string<br/>    value = list(string)<br/>  }))</pre> | `null` | no |
| <a name="input_helm_release_set_sensitive"></a> [helm\_release\_set\_sensitive](#input\_helm\_release\_set\_sensitive) | Custom sensitive values to be merged with the values. | <pre>list(object({<br/>    name  = string<br/>    value = string<br/>    type  = optional(string)<br/>  }))</pre> | `null` | no |
| <a name="input_helm_release_set_wo"></a> [helm\_release\_set\_wo](#input\_helm\_release\_set\_wo) | Custom values to be merged with the values. This is the same as "set" but write-only. | <pre>list(object({<br/>    name  = string<br/>    value = string<br/>    type  = optional(string)<br/>  }))</pre> | `null` | no |
| <a name="input_helm_release_set_wo_revision"></a> [helm\_release\_set\_wo\_revision](#input\_helm\_release\_set\_wo\_revision) | The current revision of the write-only "set\_wo" attribute. Incrementing this integer value will cause Terraform to update the write-only value. | `number` | `null` | no |
| <a name="input_helm_release_skip_crds"></a> [helm\_release\_skip\_crds](#input\_helm\_release\_skip\_crds) | If set, no CRDs will be installed. By default, CRDs are installed if not already present. Defaults to `false`. | `bool` | `null` | no |
| <a name="input_helm_release_take_ownership"></a> [helm\_release\_take\_ownership](#input\_helm\_release\_take\_ownership) | If set, allows Helm to adopt existing resources not marked as managed by the release. Defaults to `false`. | `bool` | `null` | no |
| <a name="input_helm_release_timeout"></a> [helm\_release\_timeout](#input\_helm\_release\_timeout) | Time in seconds to wait for any individual kubernetes operation. Defaults to 300 seconds. | `number` | `null` | no |
| <a name="input_helm_release_upgrade_install"></a> [helm\_release\_upgrade\_install](#input\_helm\_release\_upgrade\_install) | If true, the provider will install the release at the specified version even if a release not controlled by the provider is present: this is equivalent to running 'helm upgrade --install' with the Helm CLI. WARNING: this may not be suitable for production use -- see the 'Upgrade Mode' note in the provider documentation. Defaults to `false`. | `bool` | `null` | no |
| <a name="input_helm_release_values"></a> [helm\_release\_values](#input\_helm\_release\_values) | List of values in raw yaml format to pass to helm. | `list(string)` | `null` | no |
| <a name="input_helm_release_verify"></a> [helm\_release\_verify](#input\_helm\_release\_verify) | Verify the package before installing it.Defaults to `false`. | `bool` | `null` | no |
| <a name="input_helm_release_version"></a> [helm\_release\_version](#input\_helm\_release\_version) | Chart version to use for the Agent installation in the format `X.Y.Z`. If this is not specified, the latest version is installed. | `string` | n/a | yes |
| <a name="input_helm_release_wait"></a> [helm\_release\_wait](#input\_helm\_release\_wait) | Will wait until all resources are in a ready state before marking the release as successful. Defaults to `true`. | `bool` | `null` | no |
| <a name="input_helm_release_wait_for_jobs"></a> [helm\_release\_wait\_for\_jobs](#input\_helm\_release\_wait\_for\_jobs) | If wait is enabled, will wait until all Jobs have been completed before marking the release as successful. Defaults to `false`. | `bool` | `null` | no |
| <a name="input_humanitec_org_id"></a> [humanitec\_org\_id](#input\_humanitec\_org\_id) | Humanitec Organization ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_agent_id"></a> [agent\_id](#output\_agent\_id) | id of the Agent |
| <a name="output_agent_private_key"></a> [agent\_private\_key](#output\_agent\_private\_key) | Private key of the Agent in PEM format. |
| <a name="output_agent_public_key"></a> [agent\_public\_key](#output\_agent\_public\_key) | Public key of the Agent in PEM format. |
| <a name="output_helm_release_chart"></a> [helm\_release\_chart](#output\_helm\_release\_chart) | Chart name used for the Agent Helm chart |
| <a name="output_helm_release_name"></a> [helm\_release\_name](#output\_helm\_release\_name) | Name of the Helm release for the Agent |
| <a name="output_helm_release_namespace"></a> [helm\_release\_namespace](#output\_helm\_release\_namespace) | Kubernetes namespace where the Agent is installed |
| <a name="output_helm_release_repository"></a> [helm\_release\_repository](#output\_helm\_release\_repository) | Repository used for the Agent Helm chart |
| <a name="output_helm_release_version"></a> [helm\_release\_version](#output\_helm\_release\_version) | Chart version used for the Agent installation |
| <a name="output_resource_definition_id"></a> [resource\_definition\_id](#output\_resource\_definition\_id) | ID of the Resource Definition created for Agent. Use it to attach matching criteria as required in your setup. |
<!-- END_TF_DOCS -->
