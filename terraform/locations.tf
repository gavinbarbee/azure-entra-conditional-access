# Sign-ins from these IPs skip the CA101 MFA requirement.
resource "azuread_named_location" "trusted" {
  display_name = "nl-gavinbarbee-trusted-ips"

  ip {
    ip_ranges = var.trusted_ip_cidrs
    trusted   = true
  }
}

# CA104 blocks sign-ins from these countries.
resource "azuread_named_location" "blocked_countries" {
  display_name = "nl-gavinbarbee-blocked-countries"

  country {
    countries_and_regions                 = var.blocked_countries
    include_unknown_countries_and_regions = false
  }
}
