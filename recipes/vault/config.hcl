ui = true

storage "etcd" {
  address = "https://10.210.0.10:2379,https://10.210.0.11:2379,https://10.210.0.12:2379"
  etcd_api = "v3"
  ha_enabled = "false"
  path = "vault/"
  sync = "true"

  tls_ca_file = "/run/secrets/etcd-ca.pem"
  tls_cert_file = "/run/secrets/etcd-vault.pem"
  tls_key_file = "/run/secrets/etcd-vault-key.pem"
}

listener "tcp" {
 address = "0.0.0.0:8200"
 tls_disable = 1
}
