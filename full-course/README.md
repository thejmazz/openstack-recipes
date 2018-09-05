After initial bootstrap, we manually set up vault:


```
docker run --rm -it -e VAULT_ADDR=http://10.110.1.9:8200 -e VAULT_CACERT=/etc/ssl/ca.pem -v /etc/cfssl:/etc/ssl vault:0.10.4 sh
vault operator init -n 5
vault operator unseal ...
vault login <root-token>
vault secrets enable -path=pki pki
# Something <= rootca (e.g. 43800h)
vault secrets tune -max-lease-ttl=2160h pki
vault write pki/intermediate/generate/internal common_name="My Vault Int CA" ttl=2160h
# Copy certificate request into "/etc/cfssl/int.csr"
docker run --rm -v /etc/cfssl:/etc/ssl -w /etc/ssl --entrypoint /usr/bin/env cfssl/cfssl:1.3.2 sh -c "cfssl sign -config=request-profile.json -tls-remote-ca ca.pem -profile=ca int.csr | cfssljson -bare int"
# Check it:
openssl x509 -in /etc/cfssl/int.pem -noout -text | less
# Log back into vault and set it
vault write pki/intermediate/set-signed certificate=@/etc/ssl/int.pem
# Set up CRLs (can be changed later)
vault write pki/config/urls issuing_certificates="http://127.0.0.1:8200/v1/pki/ca" crl_distribution_points="http://127.0.0.1:8200/v1/pki/crl"
```
