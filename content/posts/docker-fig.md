+++
date = 2015-01-12T10:42:00Z
draft = false
title = "Запуск контейнеров с помощью Fig"
Tags = ["Devops", "Docker"]
series = ["Building test environments with Docker"]

+++
Это третья статья цикла {{% link section="series" title="Building test environments with Docker" %}}.

Как мы уже убедились, запуск контейнеров с помощью ```docker run``` — занятие весьма муторное, т.к. необходимо указывать множество опций. При запуске же нескольких контейнеров ситуация только ухудшается, т.к. теперь нужно задавать имена и линки.

Эту проблему решает инструмент [Fig](http://www.fig.sh/), который может запустить/остановить целое тестовое окружение, состоящее из набора контейнеров. Описание контейнеров задано в YAML-файле. Таким образом, этот YAML-файл представляет собой конфигурацию тестового окружения.

Конфигурация нашего тестового окружения *test-env/fig.yml*:
```
app1:
  image: smile/app1
  ports: ['2021:22', '8081:80']
  privileged: true

app2:
  image: smile/app2
  ports: ['2022:22', '8082:80']
  privileged: true

gate:
  image: smile/gate
  links: [app1, app2]
  ports: ['2020:22', '80:80']
  privileged: true
```

Запуск тестового окружения (находясь в каталоге с файлом *fig.yml*): ```fig up```.

По-умолчанию, Fig захватывает консоль и мультиплексирует вывод всех контейнеров. Для запуска в detached mode нужно использовать опцию ```-d```. Посмотреть вывод контейнеров в этом режиме можно с помощью команды ```fig logs```.

Статус тестового окружения: ```fig ps```.

Остановка тестового окружения: ```fig stop```.

### Запуск тестового окружения с помощью Upstart

Job */etc/init/fig-test-env.conf* создан на основе [HeyImAlex/fig.conf](https://gist.github.com/HeyImAlex/9649374). Для отключения автостарта нужно закомментировать вторую строчку ("start on ...").
```
description "Test environment runner"
start on filesystem and started docker
stop on runlevel [!2345]
respawn
chdir /path/to/test-env
script
  # Wait for docker to finish starting up first.
  FILE=/var/run/docker.sock
  while [ ! -e $FILE ] ; do
    inotifywait -t 2 -e create $(dirname $FILE)
  done
  /usr/local/bin/fig up
end script
post-stop script
 /usr/local/bin/fig stop
end script
```

Теперь можно запустить тестовое окружение из любого места командой ```start fig-test-env```, а остановить — ```stop fig-test-env```.
