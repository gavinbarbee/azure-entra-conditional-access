data "azuread_domains" "initial" {
  only_initial = true
}

locals {
  domain = data.azuread_domains.initial.domains[0].domain_name
}

# Break-glass account is created in the portal on purpose, so a
# terraform destroy can never remove it. Terraform only reads it.
data "azuread_user" "break_glass" {
  user_principal_name = var.break_glass_upn
}

# Every policy excludes this group.
resource "azuread_group" "ca_exclude" {
  display_name     = "grp-gavinbarbee-ca-exclude"
  description      = "Excluded from all Conditional Access policies. Break-glass only."
  security_enabled = true
}

resource "azuread_group_member" "break_glass" {
  group_object_id  = azuread_group.ca_exclude.object_id
  member_object_id = data.azuread_user.break_glass.object_id
}

# CA101 is enforced on this group first, before all users.
resource "azuread_group" "ca_pilot" {
  display_name     = "grp-gavinbarbee-ca-pilot"
  description      = "Pilot ring for Conditional Access rollout."
  security_enabled = true
}

resource "random_password" "pilot_user" {
  length  = 20
  special = true
}

resource "azuread_user" "pilot" {
  user_principal_name   = "gavinbarbee-pilotuser@${local.domain}"
  display_name          = "Paige Pilot"
  password              = random_password.pilot_user.result
  force_password_change = false
}

resource "azuread_group_member" "pilot_user" {
  group_object_id  = azuread_group.ca_pilot.object_id
  member_object_id = azuread_user.pilot.object_id
}
