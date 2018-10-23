# Compute

Now we can start building some VMs. You may want to

- run minio as a state backend for Terraform (or use a cloud provider)
- run etcd as a backend for Vault (or use GCS)
- run an internal DNS server (e.g. dnsmasq, CoreDNS)
- run Vault
- run a CI/CD server (e.g. Drone)
- run a git server (e.g. Gitea)
- run a container orchestration system (Docker Swarm, Kubernetes)
- run a VM stack (e.g. nginx/haproxy + node/python/golang/etc + postgres/etc)
- run Minio as a backup for everything, which gets synced to an Amazon/Google bucket



One of the first things to do is create a bastion server.  It will allow ssh
(22/tcp) from your local network, and will be the source to allow 22/tcp from
for other instances in your network.
