project_name               = "policy-gov"
environment                = "production"
admin_user_email           = "example@domain.com"
prod_location              = "westeurope" # eastasia southafricanorth
addr_space                 = "10.0.0.0/16"
prod_subnet_prefixes       = "10.0.1.0/24"
db_subnet_prefixes         = "10.0.2.0/24"
appservice_subnet_prefixes = "10.0.3.0/24"
pe_subnet_prefixes         = "10.0.4.0/24"
waf_subnet_prefix          = "10.0.5.0/24"

laravel_credentials = {
  pat : {
    github_pat : "ghp_1234567890sdgfergdfgdfgdfgdfgdfgdfg"
  }
  repo : {
    laravel_app_repo : "https://github.com/username/repo_name.git"
  }
  branch : {
    laravel_app_branch : "main"
  }
  db : {
    admin_user : "admin",
    admin_pass : "password123"
  },

  env : {
    appkey = "base64:generate_app_key_here"
  },
}

email_address = {
  kelvin = "admin@domain.com"
}
custom_domain_name    = "subdomain.domain.com"
custom_domain_enabled = true
webapp_default_url    = "https://app_name.azurewebsites.net"
kv_ssl_cert_name      = "cert_name-pfx"
prod_hostname         = "domain.com"
staging_hostname      = "domain.com"
ssl_certificate_name  = "cert-ssl"