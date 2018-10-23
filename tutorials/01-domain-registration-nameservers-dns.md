# Domain Registration, Nameservers, and Public DNS

1. Obtain a domain from a certified registrar. For example,
   [Namecheap][namecheap]. For the purposes of this tutorial, we will assume it
   is `my.cloud`.

2. Wait for your domain to resolve. You can check this with `nslookup -type=ns
   my.cloud` or `dig ns my.cloud`. If the domain is not resolved yet, you will
   get `NXDOMAIN`.

   *NOTE: `nslookup` will output `NXDOMAIN` while `dig` will not
   include an answer section.*

3. Choose a public DNS provider. For example, [Cloudflare][cloudflare]. The DNS
   provider will give you some nameservers, set these as custom nameservers
   from your registrar's settings page for the domain.

4. Wait for the nameservers update to finish. Could take up to 48 hours. Check
   with `nslookup` or `dig`.

## Definitions

- registrar
- domain, top level domain
- nameserver
- DNS, public DNS service

## Tools

- dig
- nslookup

[namecheap]: https://www.namecheap.com
[cloudflare]: https://www.cloudflare.com/
