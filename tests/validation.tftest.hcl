# Verifies that callers cannot override the chart values set by the module

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

run "rejects_org_override_in_set" {
  command = plan

  variables {
    helm_release_set = [
      {
        name  = "humanitec.org"
        value = "other-org"
      }
    ]
  }

  expect_failures = [var.helm_release_set]
}

run "rejects_private_key_override_in_set" {
  command = plan

  variables {
    helm_release_set = [
      {
        name  = "humanitec.privateKey"
        value = "other-key"
      }
    ]
  }

  expect_failures = [var.helm_release_set]
}

run "rejects_org_override_in_set_list" {
  command = plan

  variables {
    helm_release_set_list = [
      {
        name  = "humanitec.org"
        value = ["other-org"]
      }
    ]
  }

  expect_failures = [var.helm_release_set_list]
}

run "rejects_private_key_override_in_set_list" {
  command = plan

  variables {
    helm_release_set_list = [
      {
        name  = "humanitec.privateKey"
        value = ["other-key"]
      }
    ]
  }

  expect_failures = [var.helm_release_set_list]
}

run "rejects_org_override_in_set_sensitive" {
  command = plan

  variables {
    helm_release_set_sensitive = [
      {
        name  = "humanitec.org"
        value = "other-org"
      }
    ]
  }

  expect_failures = [var.helm_release_set_sensitive]
}

run "rejects_private_key_override_in_set_sensitive" {
  command = plan

  variables {
    helm_release_set_sensitive = [
      {
        name  = "humanitec.privateKey"
        value = "other-key"
      }
    ]
  }

  expect_failures = [var.helm_release_set_sensitive]
}

run "rejects_org_override_in_set_wo" {
  command = plan

  variables {
    helm_release_set_wo = [
      {
        name  = "humanitec.org"
        value = "other-org"
      }
    ]
  }

  expect_failures = [var.helm_release_set_wo]
}

run "rejects_private_key_override_in_set_wo" {
  command = plan

  variables {
    helm_release_set_wo = [
      {
        name  = "humanitec.privateKey"
        value = "other-key"
      }
    ]
  }

  expect_failures = [var.helm_release_set_wo]
}

run "accepts_other_values" {
  command = plan

  variables {
    helm_release_set           = [{ name = "a", value = "1" }]
    helm_release_set_list      = [{ name = "b", value = ["2"] }]
    helm_release_set_sensitive = [{ name = "c", value = "3" }]
    helm_release_set_wo        = [{ name = "d", value = "4" }]
  }
}

run "rejects_agent_private_key_without_agent_public_key" {
  command = plan

  variables {
    agent_public_key = null
  }

  expect_failures = [var.agent_private_key]
}

run "rejects_agent_public_key_without_agent_private_key" {
  command = plan

  variables {
    agent_private_key = null
  }

  expect_failures = [var.agent_private_key]
}

run "rejects_empty_agent_private_key_with_agent_public_key" {
  command = plan

  variables {
    agent_private_key = ""
  }

  expect_failures = [var.agent_private_key]
}

run "rejects_blank_agent_public_key_with_agent_private_key" {
  command = plan

  variables {
    agent_public_key = " \n"
  }

  expect_failures = [var.agent_private_key]
}

run "accepts_neither_agent_key" {
  command = plan

  variables {
    agent_private_key = null
    agent_public_key  = null
  }
}

run "accepts_empty_agent_keys_as_unset" {
  command = plan

  variables {
    agent_private_key = ""
    agent_public_key  = ""
  }

  assert {
    condition     = length(tls_private_key.agent) == 1
    error_message = "A convenience key must be generated when both agent keys are empty"
  }
}

run "rejects_empty_agent_id" {
  command = plan

  variables {
    agent_id = ""
  }

  expect_failures = [var.agent_id]
}

run "rejects_single_character_agent_id" {
  command = plan

  variables {
    agent_id = "a"
  }

  expect_failures = [var.agent_id]
}

run "rejects_single_digit_agent_id" {
  command = plan

  variables {
    agent_id = "1"
  }

  expect_failures = [var.agent_id]
}

run "rejects_single_dash_agent_id" {
  command = plan

  variables {
    agent_id = "-"
  }

  expect_failures = [var.agent_id]
}

run "rejects_64_character_agent_id" {
  command = plan

  variables {
    # 64 characters, otherwise valid: only the length validation must fail
    agent_id = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  }

  expect_failures = [var.agent_id]
}

run "rejects_64_character_agent_id_with_dashes" {
  command = plan

  variables {
    # 64 characters, otherwise valid: only the length validation must fail
    agent_id = "my-agent-aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  }

  expect_failures = [var.agent_id]
}

run "rejects_uppercase_agent_id" {
  command = plan

  variables {
    agent_id = "My-Agent"
  }

  expect_failures = [var.agent_id]
}

run "rejects_leading_dash_agent_id" {
  command = plan

  variables {
    agent_id = "-my-agent"
  }

  expect_failures = [var.agent_id]
}

run "rejects_trailing_dash_agent_id" {
  command = plan

  variables {
    agent_id = "my-agent-"
  }

  expect_failures = [var.agent_id]
}

run "rejects_double_dash_agent_id" {
  command = plan

  variables {
    agent_id = "my--agent"
  }

  expect_failures = [var.agent_id]
}

run "rejects_only_dashes_agent_id" {
  command = plan

  variables {
    agent_id = "--"
  }

  expect_failures = [var.agent_id]
}

run "rejects_underscore_agent_id" {
  command = plan

  variables {
    agent_id = "my_agent"
  }

  expect_failures = [var.agent_id]
}

run "rejects_dot_agent_id" {
  command = plan

  variables {
    agent_id = "my.agent"
  }

  expect_failures = [var.agent_id]
}

run "rejects_whitespace_agent_id" {
  command = plan

  variables {
    agent_id = "my agent"
  }

  expect_failures = [var.agent_id]
}

run "rejects_surrounding_whitespace_agent_id" {
  command = plan

  variables {
    agent_id = " my-agent "
  }

  expect_failures = [var.agent_id]
}

run "rejects_trailing_newline_agent_id" {
  command = plan

  variables {
    agent_id = "my-agent\n"
  }

  expect_failures = [var.agent_id]
}

run "rejects_non_ascii_letter_agent_id" {
  command = plan

  variables {
    agent_id = "my-agent-ä"
  }

  expect_failures = [var.agent_id]
}

run "rejects_en_dash_agent_id" {
  command = plan

  variables {
    # En dash (U+2013) instead of a hyphen
    agent_id = "my–agent"
  }

  expect_failures = [var.agent_id]
}

run "accepts_valid_agent_id" {
  command = plan

  variables {
    agent_id = "my-agent-01"
  }

  assert {
    condition     = humanitec_resource_definition.agent.id == var.agent_id
    error_message = "Resource Definition ID must be taken from agent_id"
  }
}

run "accepts_two_character_agent_id" {
  command = plan

  variables {
    agent_id = "ab"
  }

  assert {
    condition     = humanitec_resource_definition.agent.id == var.agent_id
    error_message = "Resource Definition ID must be taken from agent_id"
  }
}

run "accepts_two_digit_agent_id" {
  command = plan

  variables {
    agent_id = "01"
  }

  assert {
    condition     = humanitec_resource_definition.agent.id == var.agent_id
    error_message = "Resource Definition ID must be taken from agent_id"
  }
}

run "accepts_three_character_agent_id_with_dash" {
  command = plan

  variables {
    agent_id = "a-b"
  }

  assert {
    condition     = humanitec_resource_definition.agent.id == var.agent_id
    error_message = "Resource Definition ID must be taken from agent_id"
  }
}

run "accepts_digits_only_agent_id" {
  command = plan

  variables {
    agent_id = "123"
  }

  assert {
    condition     = humanitec_resource_definition.agent.id == var.agent_id
    error_message = "Resource Definition ID must be taken from agent_id"
  }
}

run "accepts_63_character_agent_id" {
  command = plan

  variables {
    # 63 characters: the maximum length
    agent_id = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  }

  assert {
    condition     = humanitec_resource_definition.agent.id == var.agent_id
    error_message = "Resource Definition ID must be taken from agent_id"
  }
}

run "accepts_63_character_agent_id_with_dashes" {
  command = plan

  variables {
    # 63 characters: the maximum length
    agent_id = "my-agent-aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  }

  assert {
    condition     = humanitec_resource_definition.agent.id == var.agent_id
    error_message = "Resource Definition ID must be taken from agent_id"
  }
}

run "accepts_null_agent_id" {
  command = plan

  variables {
    agent_id = null
  }
}
