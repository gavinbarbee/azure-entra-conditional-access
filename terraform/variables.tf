variable "tenant_id" {
  description = "Entra ID tenant ID."
  type        = string
}

variable "break_glass_upn" {
  description = "UPN of the break-glass account (created in the portal, outside Terraform). Excluded from every policy."
  type        = string
}

variable "trusted_ip_cidrs" {
  description = "Public IP ranges treated as trusted, e.g. my home egress IP as a /32."
  type        = list(string)
}

variable "blocked_countries" {
  description = "Two-letter country codes to block sign-ins from."
  type        = list(string)
  default     = ["KP", "IR", "SY", "CU", "RU"]
}

variable "ca101_include_all_users" {
  description = "false = CA101 targets the pilot group only. true = CA101 targets all users."
  type        = bool
  default     = false
}

variable "policy_states" {
  description = "State per policy: enabledForReportingButNotEnforced (report-only), enabled, or disabled."
  type        = map(string)
  default = {
    ca101 = "enabledForReportingButNotEnforced"
    ca102 = "enabledForReportingButNotEnforced"
    ca103 = "enabledForReportingButNotEnforced"
    ca104 = "enabledForReportingButNotEnforced"
  }

  validation {
    condition = alltrue([
      for s in values(var.policy_states) :
      contains(["enabledForReportingButNotEnforced", "enabled", "disabled"], s)
    ])
    error_message = "Each policy state must be enabledForReportingButNotEnforced, enabled, or disabled."
  }
}
