###########################################
################ Outputs ##################
###########################################

###########################################
############ Agent Functions #############
###########################################

output "agents" {
  description = "Complete information about all agents created"
  value = {
    for k, v in var.knowledgebases : k => {
      knowledgebase_arn = aws_bedrockagent_knowledge_base.knowledge_bases[k].arn
      knowledgebase_id  = aws_bedrockagent_knowledge_base.knowledge_bases[k].id
    }
  }
}
