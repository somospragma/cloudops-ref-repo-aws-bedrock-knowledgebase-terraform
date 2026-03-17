# Bedrock Knowledge Base Module - Outputs del ejemplo

output "knowledge_base_arns" {
  description = "ARNs de los knowledge bases creados"
  value       = module.knowledge_base.knowledge_base_arns
}

output "knowledge_base_ids" {
  description = "IDs de los knowledge bases creados"
  value       = module.knowledge_base.knowledge_base_ids
}

output "data_source_ids" {
  description = "IDs de los data sources creados"
  value       = module.knowledge_base.data_source_ids
}
