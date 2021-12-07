locals {

  defaults = {
    label_order         = ["team", "environment", "region", "name", "attributes"]
    regex_replace_chars = "/[^-a-zA-Z0-9]/"
    delimiter           = "-"
    replacement         = ""
    label_key_case      = "title"
  }

  replacement                             = local.defaults.replacement
  default_labels_allowed_in_tags          = keys(local.tags_context)
  context_labels_allowed_in_tags_is_unset = try(contains(var.context.labels_allowed_in_tags, "unset"), true)

  input = {
    enabled     = var.enabled == null ? var.context.enabled : var.enabled
    team        = var.team == null ? var.context.team : var.team
    environment = var.environment == null ? var.context.environment : var.environment
    region      = var.region == null ? var.context.region : var.region
    name        = var.name == null ? var.context.name : var.name
    delimiter   = var.delimiter == null ? var.context.delimiter : var.delimiter
    attributes  = compact(distinct(concat(coalesce(var.context.attributes, []), coalesce(var.attributes, []))))
    tags        = merge(var.context.tags, var.tags)

    additional_tag_map  = merge(var.context.additional_tag_map, var.additional_tag_map)
    label_order         = var.label_order == null ? coalescelist(var.context.label_order, local.defaults.label_order) : var.label_order
    regex_replace_chars = var.regex_replace_chars == null ? var.context.regex_replace_chars : var.regex_replace_chars
    label_key_case      = var.label_key_case == null ? var.context.label_key_case : var.label_key_case

    labels_allowed_in_tags = local.context_labels_allowed_in_tags_is_unset ? var.labels_allowed_in_tags : var.context.labels_allowed_in_tags
  }

  enabled             = local.input.enabled
  regex_replace_chars = coalesce(local.input.regex_replace_chars, local.defaults.regex_replace_chars)

  string_label_names = ["team", "environment", "region", "name"]
  normalized_labels = { for k in local.string_label_names : k =>
    local.input[k] == null ? "" : replace(local.input[k], local.regex_replace_chars, local.replacement)
  }
  attributes = compact(distinct([for v in local.input.attributes : replace(v, local.regex_replace_chars, local.replacement)]))

  team        = local.normalized_labels["team"]
  environment = local.normalized_labels["environment"]
  region      = local.normalized_labels["region"]
  name        = local.normalized_labels["name"]

  delimiter      = local.input.delimiter == null ? local.defaults.delimiter : local.input.delimiter
  label_order    = local.input.label_order == null ? local.defaults.label_order : local.input.label_order
  label_key_case = local.input.label_key_case == null ? local.defaults.label_key_case : local.input.label_key_case

  labels_allowed_in_tags = contains(local.input.labels_allowed_in_tags, "default") ? local.default_labels_allowed_in_tags : local.input.labels_allowed_in_tags
  additional_tag_map = merge(var.context.additional_tag_map, var.additional_tag_map)
  tags = merge(local.generated_tags, local.input.tags)
  tags_as_list_of_maps = flatten([
    for key in keys(local.tags) : merge(
      {
        key   = key
        value = local.tags[key]
    }, local.additional_tag_map)
  ])

  tags_context = {
    team        = local.team
    environment = local.environment
    region      = local.region
    name        = local.id
    attributes  = local.id_context.attributes
  }

  generated_tags = {
    for l in setintersection(keys(local.tags_context), local.labels_allowed_in_tags) :
    local.label_key_case == "upper" ? upper(l) : (
      local.label_key_case == "lower" ? lower(l) : title(lower(l))
    ) => local.tags_context[l] if length(local.tags_context[l]) > 0
  }

  id_context = {
    team        = local.team
    environment = local.environment
    region      = local.region
    name        = local.name
    attributes  = join(local.delimiter, local.attributes)
  }
  labels = [for l in local.label_order : local.id_context[l] if length(local.id_context[l]) > 0]
  id     = join(local.delimiter, local.labels)


  output_context = {
    enabled                = local.enabled
    team                   = local.team
    environment            = local.environment
    region                 = local.region
    name                   = local.name
    delimiter              = local.delimiter
    attributes             = local.attributes
    tags                   = local.tags
    additional_tag_map     = local.additional_tag_map
    label_order            = local.label_order
    regex_replace_chars    = local.regex_replace_chars
    label_key_case         = local.label_key_case
    labels_allowed_in_tags = local.labels_allowed_in_tags
  }

}
