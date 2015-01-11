+++
date = 2015-01-04T13:49:06Z
draft = false
title = "Подготовка и запуск docker-контейнеров"
Tags = ["Devops", "Docker"]
series = ["Building test environments with Docker"]

+++
Это первая статья цикла [Building test environments with Docker](/series/building-test-environments-with-docker).

Сразу оговорюсь, что все docker-контейнеры основаны на [baseimage-docker](http://phusion.github.io/baseimage-docker/). Этот образ позволяет запускать в контейнере несколько приложений с помощью супервизора [runit](http://smarden.org/runit/) и содержит ssh, cron, syslog "из коробки".

Хотя подобный подход [не рекомендуется разработчиками Docker](http://jpetazzo.github.io/2014/06/23/docker-ssh-considered-evil/), он очень удобен в эксплуатации и не принуждает разработчика к своему "proper way". Всегда можно использовать канонический подход от Docker с volumes и nsenter, а, при желании, подключаться к контейнерам по ssh.

Кроме того, я привык использовать сервера приложений в связке с nginx, и baseimage-docker позволяет легко это сделать.

### Базовый образ

При создании базового образа выполняются две вещи:

* публичный ssh-ключ добавляется в список разрешенных для суперпользователя контейнера;
* задается локаль.

*Dockerfile* базового образа:
```
FROM phusion/baseimage:0.9.15

# Add public SSH keys
ADD my_rsa_public_key /tmp/my_rsa_public_key
RUN cat /tmp/my_rsa_public_key >> /root/.ssh/authorized_keys && rm -f /tmp/my_rsa_public_key

# Locale
ENV LANG=en_US.utf8

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]
```

Свой публичный ssh-ключ, естественно, надо положить в *my_rsa_public_key* рядом с *Dockerfile*.

Сборка: ```docker build -t smile/base .``` и запуск:

```
docker run --rm -it -p 2022:22 smile/base /sbin/my_init -- bash -l
```

```--rm``` используется для удаления контейнера после его остановки, ```-it``` — для терминального интеракивного режима, а ```-- bash -l``` — для запуска шелла после запуска всех сервисов.

Также на контейнер можно зайти по ssh: ```ssh -p 2022 root@localhost```.

### Образ с nginx

Сборка [docker-nginx](https://github.com/dddpaul/docker-nginx): ```docker build -t smile/nginx .```

Основная особенность этого образа в том, что при запуске контейнера отключается IPv6.

Сделано это для того, чтобы обойти известную проблему с проксированием Nginx. Т.к. демон висит на tcp6, то апстрим иногда видит запрос от 127.0.0.1, а иногда от 0:0:0:0:0:0:0:1. Это принуждает к изменению ACL на сервере приложений, что не всегда удобно.

IPv6 отключается после выполнения серии sysctl-команд, которые требуют, чтобы контейнер был запущен в привилегированном режиме, т.е. команда запуска слегка усложняется:

```
docker run --privileged --rm -it -p 2022:22 smile/nginx /sbin/my_init -- bash -l
```

### Остальные образы

На основе docker-nginx можно строить более сложные образы, такие как [docker-java7-server](https://github.com/dddpaul/docker-java7-server) и  [docker-tomcat7](https://github.com/dddpaul/docker-tomcat7). На основе последнего уже строятся образы для конечных приложений.