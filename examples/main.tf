module "label-demo-1" {
  source   = "../"

  team           = "007"
  environment    = "prod"
  region         = "main"
  name           = "network"
  delimiter      = "-"
  label_key_case = "title"
  attributes     = ["public"]

  tags = {
    "BusinessUnit" = "XYZ",
    "Snapshot"     = "true"
  }
}

module "label-demo-2" {
  source   = "../"

  name         = "vm"
  delimiter = "."

  tags = {
    "OWNER" = "Rabbit"
  }

  context   = module.label-demo-1.context
}
