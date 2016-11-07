+++
date = "2016-11-07T21:00:00+03:00"
draft = false
title = "Træfik on Docker Swarm mode cluster"
tags = ["docker"]

+++

Træfɪk is a modern HTTP reverse proxy and load balancer made to deploy microservices with ease. Since 1.1.0-rc1 it supports Docker Swarm mode as backend. It means that Træfɪk will automatically create proxying frontends which will be binded to corresponding Docker Swarm services.

This post is based on [Docker Swarm (mode) cluster](https://docs.traefik.io/user-guide/swarm-mode/) example.

Assuming we have Docker Swarm mode cluster already, we will need to create an overlay network:

{{< highlight shell >}}
docker network create --driver=overlay traefik-net
{{< /highlight >}}

Backends are the simple [emilevauge/whoami](https://github.com/emilevauge/whoamI) services:

{{< highlight shell >}}
docker service create --name test1 --label traefik.port=80 --network traefik-net emilevauge/whoami
docker service create --name test2 --label traefik.port=80 --network traefik-net emilevauge/whoami
{{< /highlight >}}

Træfɪk itself may be ran in rich variety of configurations.

**1.** HTTP only proxy

{{< highlight shell >}}
docker service create \
--name traefik \
--constraint=node.role==manager \
--publish 80:80 --publish 8080:8080 \
--mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
--network traefik-net \
traefik:v1.1.0-rc3 \
--docker \
--docker.swarmmode \
--docker.domain=example.org \
--docker.watch \
--logLevel=DEBUG \
--web
{{< /highlight >}}

Remarks:

* Træfɪk web UI will we accessible on http://example.org:8080.
* Debug log level must be disabled on production.

**2.** HTTPS proxy with Let's Encrypt certificate and HTTP to HTTPS redirection

{{< highlight shell >}}
docker service create \
--name traefik \
--constraint=node.role==manager \
--publish 80:80 --publish 443:443 --publish 8080:8080 \
--mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock,readonly \
--mount type=bind,source=/var/tmp,target=/etc/traefik/acme \
--network traefik-net \
traefik:v1.1.0-rc3 \
--entryPoints='Name:http Address::80 Redirect.EntryPoint:https' \
--entryPoints='Name:https Address::443 TLS' \
--defaultEntryPoints=http,https \
--acme.entryPoint=https \
--acme.email=owner@example.org \
--acme.storage=/etc/traefik/acme/acme.json \
--acme.domains=example.org \
--acme.onHostRule=true \
--docker \
--docker.swarmmode \
--docker.domain=example.org \
--docker.watch \
--web
{{< /highlight >}}

**3.** HTTPS-only proxy with Let's Encrypt certificate

{{< highlight shell >}}
docker service create \
--name traefik \
--constraint=node.role==manager \
--publish 443:443 --publish 8080:8080 \
--mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock,readonly \
--mount type=bind,source=/var/tmp,target=/etc/traefik/acme \
--network traefik-net \
traefik:v1.1.0-rc3 \
--entryPoints='Name:https Address::443 TLS' \
--defaultEntryPoints=https \
--acme.entryPoint=https \
--acme.email=owner@example.org \
--acme.storage=/etc/traefik/acme/acme.json \
--acme.domains=example.org \
--acme.onHostRule=true \
--docker \
--docker.swarmmode \
--docker.domain=example.org \
--docker.watch \
--logLevel=DEBUG \
--web
{{< /highlight >}}

**4.** HTTPS-only proxy with Let's Encrypt certificate and HTTPS web UI

{{< highlight shell >}}
docker service create \
--name traefik \
--constraint=node.role==manager \
--publish 443:443 --publish 8443:8443 \
--mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock,readonly \
--mount type=bind,source=/etc/pki/realms/domain,target=/etc/traefik/tls,readonly \
--mount type=bind,source=/var/tmp,target=/etc/traefik/acme \
--network traefik-net \
traefik:v1.1.0-rc3 \
--entryPoints='Name:https Address::443 TLS:/etc/traefik/tls/default.crt,/etc/traefik/tls/default.key' \
--defaultEntryPoints=https \
--acme.entryPoint=https \
--acme.email=owner@example.org \
--acme.storage=/etc/traefik/acme/acme.json \
--acme.domains=example.org \
--acme.onHostRule=true \
--docker \
--docker.swarmmode \
--docker.domain=example.org \
--docker.watch \
--logLevel=DEBUG \
--web.address=:8443 \
--web.certfile=/etc/traefik/tls/default.crt \
--web.keyfile=/etc/traefik/tls/default.key
{{< /highlight >}}

**5.** For debugging purposes you can run Træfɪk without Docker

{{< highlight shell >}}
traefik -d \
--entryPoints='Name:http Address::8080 Redirect.EntryPoint:https' \
--entryPoints='Name:https Address::8443 TLS' \
--defaultEntryPoints=http,https \
--acme.entryPoint=https \
--acme.email=owner@example.org \
--acme.storage=acme.json \
--acme.domains=example.org
--logLevel=DEBUG \
--web
{{< /highlight >}}

Links:

* [Træfɪk](https://traefik.io/)
