output "pilot_user_upn" {
  description = "Pilot user for sign-in testing."
  value       = azuread_user.pilot.user_principal_name
}

output "pilot_user_password" {
  description = "Pilot user password. Read in the terminal only."
  value       = random_password.pilot_user.result
  sensitive   = true
}

output "policy_states" {
  description = "Deployed Conditional Access policies and their states."
  value = {
    for p in [
      azuread_conditional_access_policy.ca101,
      azuread_conditional_access_policy.ca102,
      azuread_conditional_access_policy.ca103,
      azuread_conditional_access_policy.ca104,
    ] : p.display_name => p.state
  }
}
