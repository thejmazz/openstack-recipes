# PKI with openssl

This is good for quick, ad-hoc CAs and certificates. You can expect to find
`openssl` in most linux distributions. CFSSL is useful for being able to get
certs signed over https, whereas with openssl we would need to manually copy
files around servers (which perhaps is not a huge deal, since we need to
distribute the `ca.crt` to all servers as well with cfssl). Also cfssl has a
nice JSON format for certificate signing requests. Anyways, back to openssl:

*Typically you would apply proper permissions to these files.  For example,
0600 on the root ca key, 0644 on everything else.*

## Create the Root CA

```
openssl genrsa -out ca.key 2048
openssl req -new -x509 -days 365 -key ca.key -out ca.crt -subj "/C=CA/ST=State/L=City/O=Organization/OU=Organizational Unit/CN=Self Signed Inc."
```

## Create Client Certificate

It's called "client" here but just as well could be called `server.crt` and
used to secure an nginx server, etc. It's a client in the sense of being a
client to the CA.

```
openssl genrsa -out client.key 2048
SUBJ="
C=CA
ST=State
L=Locality
O=Organization
OU=Organizational Unit
CN=example.com
"
openssl req -new -key client.key -out client.csr -subj "$(echo -n "$SUBJ" | tr "\n" "/")"
```

If you want Subject Alternative Names (e.g., another DNS entry, another IP), it
is [a tricky one-liner][one-liner] (with CFSSL it is simply
`-hostname=example.com,www.example.com,192.168.10.5`):

[one-liner]: https://security.stackexchange.com/questions/74345/provide-subjectaltname-to-openssl-directly-on-command-line

*NOTE:* This didn't work for me. The comments suggest including `-extensions
SAN`, among others. Why waste time playing with openssl arguments when cfssl
Just Works™.

```
openssl req -new \
    -key client.key \
    -subj "$(echo -n "$SUBJ" | tr "\n" "/")" \
    -reqexts SAN \
    -config <(cat /etc/ssl/openssl.cnf \
        <(printf "\n[SAN]\nsubjectAltName=DNS:example.com,DNS:www.example.com")) \
    -out client.csr
```

Then sign the CSR using the root CA:

```
openssl x509 -req -days 365 -in client.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out client.crt
```

**NOTE:** You need to use a different serial to sign multiple requests, else you will get `SEC_ERROR_REUSED_ISSUER_AND_SERIAL` on your browser.

## Inspect Certificate

```
cat client.crt | openssl x509 -noout -text
```
