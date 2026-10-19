output "agent_id" {
  description = "ID of the Agent"
  value       = humanitec_agent.agent.id
}
output "agent_public_key" {
  description = "Public key of the Agent in PEM format."
  value       = local.agent_public_key
}
output "agent_private_key" {
  description = "Private key of the Agent in PEM format."
  value       = local.agent_private_key
  sensitive   = true
}
output "helm_release_namespace" {
  description = "Kubernetes namespace where the Agent is installed"
  value       = helm_release.humanitec_agent.namespace
}
output "helm_release_name" {
  description = "Name of the Helm release for the Agent"
  value       = helm_release.humanitec_agent.name
}
output "helm_release_version" {
  description = "Chart version used for the Agent installation"
  value       = helm_release.humanitec_agent.version
}
output "helm_release_repository" {
  description = "Repository used for the Agent Helm chart"
  value       = helm_release.humanitec_agent.repository
}
output "helm_release_chart" {
  description = "Chart name used for the Agent Helm chart"
  value       = helm_release.humanitec_agent.chart
}
output "resource_definition_id" {
  description = "ID of the Resource Definition created for Agent. Use it to attach matching criteria as required in your setup."
  value       = humanitec_resource_definition.agent.id
}
