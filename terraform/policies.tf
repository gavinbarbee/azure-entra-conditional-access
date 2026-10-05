locals {
  # Built-in role template IDs (the same in every tenant).
  privileged_role_ids = [
    "62e90394-69f5-4237-9190-012177145e10", # Global Administrator
    "e8611ab8-c189-46e8-94e1-60213ab1f814", # Privileged Role Administrator
    "194ae4cb-b126-40b2-bd5b-6091b380977d", # Security Administrator
    "b1be1c3e-b65d-4f19-8427-f6fa0d97feb9", # Conditional Access Administrator
    "fe930be7-5e62-47db-91af-98c3a49a38b1", # User Administrator
  ]

  # Built-in "Phishing-resistant MFA" authentication strength (the same in every tenant).
  phishing_resistant_strength_id = "/policies/authenticationStrengthPolicies/00000000-0000-0000-0000-000000000004"
}

resource "azuread_conditional_access_policy" "ca101" {
  display_name = "CA101-gavinbarbee-require-mfa-outside-trusted-locations"
  state        = var.policy_states["ca101"]

  conditions {
    client_app_types = ["all"]

    applications {
      included_applications = ["All"]
    }

    users {
      included_users  = var.ca101_include_all_users ? ["All"] : []
      included_groups = var.ca101_include_all_users ? [] : [azuread_group.ca_pilot.object_id]
      excluded_groups = [azuread_group.ca_exclude.object_id]
    }

    locations {
      included_locations = ["All"]
      excluded_locations = [azuread_named_location.trusted.object_id]
    }
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["mfa"]
  }
}

resource "azuread_conditional_access_policy" "ca102" {
  display_name = "CA102-gavinbarbee-block-legacy-authentication"
  state        = var.policy_states["ca102"]

  conditions {
    client_app_types = ["exchangeActiveSync", "other"]

    applications {
      included_applications = ["All"]
    }

    users {
      included_users  = ["All"]
      excluded_groups = [azuread_group.ca_exclude.object_id]
    }
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["block"]
  }
}

# Stays report-only: enforcing before admins register a passkey or
# FIDO2 key risks locking them out of the tenant.
resource "azuread_conditional_access_policy" "ca103" {
  display_name = "CA103-gavinbarbee-require-phishing-resistant-mfa-for-admins"
  state        = var.policy_states["ca103"]

  conditions {
    client_app_types = ["all"]

    applications {
      included_applications = ["All"]
    }

    users {
      included_roles  = local.privileged_role_ids
      excluded_groups = [azuread_group.ca_exclude.object_id]
    }
  }

  grant_controls {
    operator                          = "OR"
    authentication_strength_policy_id = local.phishing_resistant_strength_id
  }
}

resource "azuread_conditional_access_policy" "ca104" {
  display_name = "CA104-gavinbarbee-block-high-risk-countries"
  state        = var.policy_states["ca104"]

  conditions {
    client_app_types = ["all"]

    applications {
      included_applications = ["All"]
    }

    users {
      included_users  = ["All"]
      excluded_groups = [azuread_group.ca_exclude.object_id]
    }

    locations {
      included_locations = [azuread_named_location.blocked_countries.object_id]
    }
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["block"]
  }
}
