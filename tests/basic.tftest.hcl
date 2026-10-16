# See https://developer.hashicorp.com/terraform/language/tests for more on how to write tests.
# See https://developer.hashicorp.com/terraform/language/tests/mocking for information on mocking providers.

# Mock the providers so that tests run without a Kubernetes cluster
mock_provider "helm" {}
mock_provider "humanitec" {}
mock_provider "random" {}
mock_provider "tls" {}

variables {
  humanitec_org_id     = "my-org"
  helm_release_version = "1.2.3"
  agent_private_key    = "-----BEGIN PRIVATE KEY-----\nabc\n-----END PRIVATE KEY-----\n"
  agent_public_key     = "-----BEGIN PUBLIC KEY-----\nabc\n-----END PUBLIC KEY-----\n"
}

run "installs_chart_with_defaults" {
  command = plan

  assert {
    condition     = helm_release.humanitec_agent.repository == "oci://ghcr.io/humanitec/charts"
    error_message = "Default repository must be the public Humanitec chart repository"
  }
  assert {
    condition     = helm_release.humanitec_agent.chart == "humanitec-agent"
    error_message = "Default chart must be humanitec-agent"
  }
  assert {
    condition     = helm_release.humanitec_agent.version == "1.2.3"
    error_message = "Chart version must be taken from helm_release_version"
  }
  assert {
    condition     = helm_release.humanitec_agent.name == "humanitec-agent"
    error_message = "Default release name must be humanitec-agent"
  }
  assert {
    condition     = helm_release.humanitec_agent.namespace == "humanitec-agent"
    error_message = "Default namespace must be humanitec-agent"
  }
  assert {
    condition     = helm_release.humanitec_agent.create_namespace == true
    error_message = "Namespace must be created by default"
  }
  assert {
    condition     = one([for s in helm_release.humanitec_agent.set : s.value if s.name == "humanitec.org"]) == "my-org"
    error_message = "humanitec.org must be set to humanitec_org_id"
  }
  assert {
    condition     = one([for s in helm_release.humanitec_agent.set_sensitive : s.value if s.name == "humanitec.privateKey"]) == var.agent_private_key
    error_message = "humanitec.privateKey must be set to agent_private_key via set_sensitive"
  }
  assert {
    condition     = length([for s in helm_release.humanitec_agent.set : s if s.name == "humanitec.privateKey"]) == 0
    error_message = "humanitec.privateKey must not be passed via set"
  }
  assert {
    condition     = length(tls_private_key.agent) == 0
    error_message = "No convenience key must be generated when agent_private_key is passed in"
  }
  assert {
    condition     = output.agent_public_key == var.agent_public_key
    error_message = "agent_public_key output must be set to agent_public_key when the keys are passed in"
  }
  assert {
    condition     = output.agent_private_key == var.agent_private_key
    error_message = "agent_private_key output must be set to agent_private_key when the keys are passed in"
  }
}

run "generates_convenience_key_without_agent_private_key" {
  # apply against the mocked providers so that the generated key values are known
  command = apply

  variables {
    agent_private_key   = null
    agent_public_key    = null
    helm_release_set_wo = []
  }

  assert {
    condition     = length(tls_private_key.agent) == 1
    error_message = "A convenience key must be generated when agent_private_key is not passed in"
  }
  assert {
    condition     = tls_private_key.agent[0].algorithm == "RSA" && tls_private_key.agent[0].rsa_bits == 4096
    error_message = "The convenience key must be an RSA key with 4096 bits"
  }
  assert {
    condition     = one([for s in helm_release.humanitec_agent.set_sensitive : s.value if s.name == "humanitec.privateKey"]) == tls_private_key.agent[0].private_key_pem_pkcs8
    error_message = "humanitec.privateKey must be set to the generated key in PKCS#8 format"
  }
  assert {
    condition     = output.agent_public_key == tls_private_key.agent[0].public_key_pem
    error_message = "agent_public_key output must contain the public key of the generated key"
  }
  assert {
    condition     = output.agent_private_key == tls_private_key.agent[0].private_key_pem_pkcs8
    error_message = "agent_private_key output must contain the generated key in PKCS#8 format"
  }
}

run "appends_custom_set_sensitive_values" {
  command = plan

  variables {
    helm_release_set_sensitive = [
      {
        name  = "some.secret"
        value = "s3cr3t"
      }
    ]
  }

  assert {
    condition     = length(helm_release.humanitec_agent.set_sensitive) == 2
    error_message = "Custom set_sensitive values must be added to the module's own set_sensitive values"
  }
  assert {
    condition     = one([for s in helm_release.humanitec_agent.set_sensitive : s.value if s.name == "some.secret"]) == "s3cr3t"
    error_message = "Custom set_sensitive value some.secret must be passed to the release"
  }
}

run "installs_chart_with_custom_release_settings" {
  command = plan

  variables {
    helm_release_name             = "my-agent"
    helm_release_namespace        = "my-namespace"
    helm_release_create_namespace = false
  }

  assert {
    condition     = helm_release.humanitec_agent.name == "my-agent"
    error_message = "Release name must be taken from helm_release_name"
  }
  assert {
    condition     = helm_release.humanitec_agent.namespace == "my-namespace"
    error_message = "Namespace must be taken from helm_release_namespace"
  }
  assert {
    condition     = helm_release.humanitec_agent.create_namespace == false
    error_message = "create_namespace must be taken from helm_release_create_namespace"
  }
}

run "installs_chart_from_custom_repository" {
  command = plan

  variables {
    helm_release_repository = "oci://registry.example.com/charts"
    helm_release_chart      = "my-humanitec-agent"
  }

  assert {
    condition     = helm_release.humanitec_agent.repository == "oci://registry.example.com/charts"
    error_message = "Repository must be taken from helm_release_repository"
  }
  assert {
    condition     = helm_release.humanitec_agent.chart == "my-humanitec-agent"
    error_message = "Chart must be taken from helm_release_chart"
  }
}

run "installs_chart_without_repository" {
  command = plan

  variables {
    helm_release_repository = null
    helm_release_chart      = "./charts/humanitec-agent-1.2.3.tgz"
  }

  assert {
    condition     = helm_release.humanitec_agent.repository == "oci://ghcr.io/humanitec/charts"
    error_message = "Repository must be unset when helm_release_repository is null"
  }
  assert {
    condition     = helm_release.humanitec_agent.chart == "./charts/humanitec-agent-1.2.3.tgz"
    error_message = "Chart must be taken from helm_release_chart"
  }
}

run "appends_custom_set_values" {
  command = plan

  variables {
    helm_release_set = [
      {
        name  = "image.tag"
        value = "latest"
      }
    ]
  }

  assert {
    condition     = length(helm_release.humanitec_agent.set) == 2
    error_message = "Custom set values must be added to the module's own set values"
  }
  assert {
    condition     = one([for s in helm_release.humanitec_agent.set : s.value if s.name == "image.tag"]) == "latest"
    error_message = "Custom set value image.tag must be passed to the release"
  }
}

run "uses_agent_id_and_description" {
  command = plan

  variables {
    agent_id          = "my-agent"
    agent_description = "My Agent"
  }

  assert {
    condition     = humanitec_resource_definition.agent.id == "my-agent"
    error_message = "Resource Definition ID must be taken from agent_id"
  }
  assert {
    condition     = jsondecode(humanitec_resource_definition.agent.driver_inputs.values_string).id == "my-agent"
    error_message = "Resource Definition driver input id must be taken from agent_id"
  }
  assert {
    condition     = humanitec_resource_definition.agent.name == "My Agent"
    error_message = "Resource Definition name must be taken from agent_description"
  }
  assert {
    condition     = length(random_string.agent_id_suffix) == 0
    error_message = "No random suffix must be generated when agent_id is passed in"
  }
}

run "defaults_agent_description_to_agent_id" {
  command = plan

  variables {
    agent_id = "my-agent"
  }

  assert {
    condition     = humanitec_resource_definition.agent.name == "my-agent"
    error_message = "Resource Definition name must default to agent_id"
  }
}

run "generates_agent_id_without_agent_id" {
  # apply against the mocked providers so that the generated suffix is known
  command = apply

  variables {
    helm_release_set_wo = []
  }

  assert {
    condition     = length(random_string.agent_id_suffix) == 1
    error_message = "A random suffix must be generated when agent_id is not passed in"
  }
  assert {
    condition     = humanitec_resource_definition.agent.id == "humanitec-agent-${random_string.agent_id_suffix[0].result}"
    error_message = "Generated agent ID must be humanitec-agent- followed by the random suffix"
  }
  assert {
    condition     = humanitec_resource_definition.agent.name == humanitec_resource_definition.agent.id
    error_message = "Resource Definition name must default to the generated agent ID"
  }
}
