###########################################
############ Local Values #################
###########################################

locals {
  # Prefijo de gobernanza (PC-IAC-003, PC-IAC-012)
  governance_prefix = "${var.client}-${var.project}-${var.environment}"

  # Construcción de nombres para knowledge bases (PC-IAC-003)
  kb_names = {
    for key, config in var.knowledgebases : key => "${local.governance_prefix}-kb-${key}"
  }

  # Aplanamiento de data sources para for_each (PC-IAC-012)
  data_sources = flatten([
    for kb_key, kb_value in var.knowledgebases : [
      for ds_idx, ds_value in coalesce(kb_value.data_sources, []) : {
        kb_key    = kb_key
        ds_key    = "${kb_key}-${ds_idx}"
        ds_config = ds_value
      }
    ]
  ])
}
