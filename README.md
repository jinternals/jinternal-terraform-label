# terraform-tags

### Run test cases
```
go test -v .
```

```terraform
module "label-demo-1" {
  source           = "../"

  team             = "007"
  environment      = "prod"
  region           = "main"
  name             = "network"
  delimiter        = "-"
  label_key_case   = "title"
  attributes       = ["public"]

  tags = {
    "BusinessUnit" = "XYZ",
    "Snapshot"     = "true"
  }
}

module "label-demo-2" {
  source       = "../"

  name         = "vm"
  delimiter    = "."

  tags = {
    "OWNER"    = "Rabbit"
  }

  context      = module.label-demo-1.context
}

```

Changes to Outputs :

```terraform

  + demo_1_tags = {
      + "Attributes"   = "public"
      + "BusinessUnit" = "XYZ"
      + "Environment"  = "prod"
      + "Name"         = "007-prod-main-network-public"
      + "Region"       = "main"
      + "Snapshot"     = "true"
      + "Team"         = "007"
    }
  
  + demo_2_tags = {
      + "Attributes"   = "public"
      + "BusinessUnit" = "XYZ"
      + "Environment"  = "prod"
      + "Name"         = "007.prod.main.vm.public"
      + "OWNER"        = "Rabbit"
      + "Region"       = "main"
      + "Snapshot"     = "true"
      + "Team"         = "007"
    }


```

