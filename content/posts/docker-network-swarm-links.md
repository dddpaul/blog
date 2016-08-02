+++
date = "2016-08-02T15:45:00+03:00"
draft = false
title = "Ddcker network and Swarm mode links"
tags = ["docker", "linux"]

+++

Some useful articles & videos about modern networking in Docker:

* [Macvlan Driver](https://github.com/docker/libnetwork/blob/master/docs/macvlan.md) - Docker Macvlan driver is out of experimental in Docker 1.12.
* [Configuring Macvlan and Ipvlan Linux Networking](http://networkstatic.net/configuring-macvlan-ipvlan-linux-networking/) - What Docker Macvlan driver does under the hood.
* [Materials for 2016 DevOps Networking Forum (DNF) Presentation](https://github.com/lowescott/2016-dnf-materials) - Slides about Docker networking with Ansible playbooks.
* [Видео докладов с Docker митапа](https://habrahabr.ru/company/badoo/blog/304702/) - Особо интересен доклад Константина Назарова "Каждому контейнеру по IP" (на русском).

Swarm mode was presented in Docker 1.12:

* [Docker Built-In Orchestration Ready For Production: Docker 1.12 Goes GA](https://blog.docker.com/2016/07/docker-built-in-orchestration-ready-for-production-docker-1-12-goes-ga/) - Post from Docker blog about Swarm mode release. It contains some links to the videos.
* [More Microservices Bliss with Docker 1.12 and Swarm only](http://blog.hypriot.com/post/more-microservice-bliss-with-docker-1-12/) - [Traefik](https://traefik.io/) can be replaced with Docker 1.12. routing mesh.
