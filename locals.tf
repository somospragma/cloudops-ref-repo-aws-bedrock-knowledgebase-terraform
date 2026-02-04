###########################################
############ Local Values #################
###########################################

locals {



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
