###########################################
################ Outputs ##################
###########################################

output "knowledge_base_arns" {
  description = "Map of knowledge base keys to their ARNs"
  value = {
    for k, v in aws_bedrockagent_knowledge_base.knowledge_bases : k => v.arn
  }
}

output "knowledge_base_ids" {
  description = "Map of knowledge base keys to their IDs"
  value = {
    for k, v in aws_bedrockagent_knowledge_base.knowledge_bases : k => v.id
  }
}

output "data_source_ids" {
  description = "Map of data source keys to their data source IDs"
  value = {
    for k, v in aws_bedrockagent_data_source.data_source : k => v.data_source_id
  }
}
