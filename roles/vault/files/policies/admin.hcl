# Manage auth methods broadly across Vault
path "auth/*" {
  capabilities = [ "create", "read", "update", "delete", "list", "sudo" ]
}

# List, create, update, and delete auth methods
path "sys/auth" {
  capabilities = [ "read" ]
}
path "sys/auth/*" {
  capabilities = [ "create", "read", "update", "delete", "sudo" ]
}

# Read identities
# path "identity/*" {
#   capabilities = [ "create", "read", "update", "delete", "list" ]
# }

# List existing policies
path "sys/policy" {
  capabilities = [ "read" ]
}

path "sys/policies/*" {
  capabilities = [ "create", "update", "read", "list" ]
}
# Create and manage ACL policies broadly across Vault
path "sys/policy/*" {
  capabilities = [ "create", "read", "update", "delete", "list", "sudo" ]
}

# Manage and manage secret engines broadly across Vault.
path "sys/mounts/*" {
  capabilities = [ "create", "read", "update", "delete", "list", "sudo" ]
}

# List existing secret engines.
path "sys/mounts" {
  capabilities = [ "read" ]
}

path "/sys/internal/ui/mounts/*" {
  capabilities = [ "read" ]
}

# Read health checks
path "sys/health" {
  capabilities = [ "read", "sudo" ]
}

# Create and manage plugins
path "sys/plugins/*" {
  capabilities = [ "create", "read", "update", "delete", "list", "sudo" ]
}

path "secret/goldfish" {
  capabilities = [ "create", "read", "update", "delete" ]
}
