+++
date = 2014-11-14T16:04:00Z
draft = false
title = "Дистанционное управление Motion с помощью Go"
tags = [ "Golang", "Linux" ]

+++

Цель — сделать удобное управление для сервачка с системой motion detection.  В качестве сервера пригодился классический нетбук Asus Eee PC 701 4-х гигабайтным SSD на борту. На него была установлена Ubuntu 14.04.

Задачи:

1. Собственно, motion detection (для этого был использован [Motion](http://www.lavrsen.dk/foswiki/bin/view/Motion/WebHome)).
1. Управление настройками Motion через ИК-пульт.
1. Вывод всех сообщений от Motion и сигналов от пульта на консоль (*/dev/tty1*).
1. Минимальное время работы экрана (быстрый переход в энергосберегающйй режим, просыпание по сигналу от пульта).

**1.** Motion ставится элементарно — ```apt-get install motion```. Важные настройки:

{{< highlight shell >}}
# Максимальный fps
framerate 5

# Снимать на максимальном fps только во время движения
webcam_motion on

# Выкрутил в максимум, чтобы избежать срабатывания на включение света
lightswitch 100

# Кол-во кадров с движением, необходимых для генерации события
minimum_motion_frames 3

# Записать кадры до движения
pre_capture 5

# Записать кадры после движения
post_capture 5

# Маска для определения области детекции, легко делается в Gimp'е из снимка с камеры.
# Области, закрашенные черным, игнорируются.
mask_file /path/to/mask.pgm

# Время определения окончания движения (если за 15 секунд после начала движения
# не было никаких поползновений, то считаем, что событие-движение закончилось)
gap 15

# Отключить создание снимков
output_normal off

# Обозначать движение прямоугольником 
locate on

# Запуск скрипта по началу движения (это симлимк, который указывает на реальный скрипт).
# Изменение симлинка осущестляется по команде с пульта (см. п. 2 про конфиг) 
on_event_start "/etc/motion/handlers/on_event_start"
{{< /highlight >}}

Для подгонки чувствительности, порога шумов и т.д., нужно использовать setup mode, который активируется при запуске ```
motion -s```.

При этом в mjpeg-трансляции область детекции будет обозначена черным, шумы — серым, а распознанное движение — синим.

**2.** Для управления нетбуком был использован [ИК-пульт с USB-приемником](http://www.dx.com/p/multimedia-ir-remote-controller-with-usb-receiver-for-pc-1-cr2025-26368#.VGYO33WUe24). Подобные пульты есть и на aliexpress, и ebay. USB-приемник эмулирует HID-устройство, по сути — обычную клавиатуру.

Для работы с символьными устройствами ввода в Linux есть подсистема [evdev](http://en.wikipedia.org/wiki/Evdev). Потестить распознавание сигналов с пульта можно с помощью утилиты [evtest](http://manpages.ubuntu.com/manpages/trusty/man1/evtest.1.html).

На гитхабе нашелся [пакет для работы с evdev на Go](https://github.com/gvalkov/golang-evdev). Проект больше не поддерживается, так что я отфоркался от [более свежего форка](https://github.com/ungerik/golang-evdev) и сделал rebase на ядро Ubuntu 14.04 (3.13.0-39-generic на данный момент):

```
cd evdev
make ecodes.go
```

Поверх golang-evdev я написал [evhandler](https://github.com/dddpaul/go-evhandler). Эта программа запускается от root'а и слушает события от input device, указанного в конфиге (как правило, */etc/evhandler.toml*).  Мой конфиг:

```
[params]
    device = "/dev/input/event9"

[actions]
    KEY_STOPCD = "service motion stop"
    KEY_PLAYPAUSE = "service motion start"
    KEY_PAGEUP = "/etc/motion/handlers/handler-select up"
    KEY_PAGEDOWN = "/etc/motion/handlers/handler-select down"
```

В разделе *actions* на кнопки пульта вешаются команды: остановка и запуск motion, и выбор скрипта, который будет запущен при детекции движения. Скрипт *handler-select* "передвигает" симлинк *on_event_start* вверх/вниз, устанавливая, таким образом, реальный скрипт, который будет запускаться. Коллекцию этих скриптов я выложил в [отдельный проект](https://github.com/dddpaul/motion-handlers).

Для чтения и парсинга конфигов я использовал пакет [Viper](http://spf13.com/project/viper). Это очень классная либа от автора [Hugo](http://gohugo.io/), которая умеет:

 * парсить YAML, TOML и JSON;
 * искать конфиги в разных местах (например, сначала в $HOME, а потом в */etc*);
 * устанавливать значение по-умолчанию и переопределять значения из конфига значениями из CLI. 

**3.** evhandler должен использовать в качестве стандартного вывода */dev/tty1*. Сделать это очень просто.

Сначала отключим ввод с */dev/tty1* — ```rm /etc/init/tty1.conf```.

И создадим новый upstart job в */etc/init/evhandler.conf*:

{{< highlight shell >}}
# evhandler - Simple key press listener and handler written in Go

start on runlevel [2345]
stop on runlevel [!2345]

respawn

exec /path/to/go-evhandler > /dev/tty1 2>&1
{{< /highlight >}}

Теперь evhandler будет запускаться при загрузке, а также перезапускаться, если его процесс будет прибит. Для ручного запуска — ```
start evhandler```.

4. Управлять включением энергосберегающего режима (а именно, гашением экрана) можно з-мя способами:
* указать ```consoleblank=sss``` (где sss - секунды) в параметрах ядра (*GRUB_CMDLINE_LINUX* в */etc/default/grub*);
* использовать команду ```setterm -blank mm``` (где mm - минуты), для включения — ```setterm -blank poke```;
* использовать специальные ESC-последовательности в команде ```echo```.

```consoleblank``` давал странный эффект - после загрузки системы экран становился пустым, но было видно, что подсветка работает. При нажатии клавиш он загорался и полностью погасал через заданное время.

```setterm``` через ssh у меня как-то не заработал.

И только управляющая ESC-последовательность для терминала подошла отлично — ```echo -e '\033[9;X]``` (где X - минуты).

Для автоматического запуска этой команды создадим job */etc/init/tty1.conf*:

{{< highlight shell >}}
# tty1 - getty
#
# This service is used to maintain a getty on tty1 from the point the system is
# started until it is shut down again.

start on stopped rc RUNLEVEL=[2345] and (
            not-container or
            container CONTAINER=lxc or
            container CONTAINER=lxc-libvirt)

stop on runlevel [!2345]

# Blank screen after 1 minute timeout
# See http://www.armadeus.com/wiki/index.php?title=FrameBuffer
exec echo -ne "\033[9;1]" > /dev/tty1
{{< /highlight >}}

Ссылки:

* [Evhandler : Simple key press listener and handler written in Go](https://github.com/dddpaul/go-evhandler)
* [Viper : Go Configuration Management With Fangs](http://spf13.com/project/viper)
* [Change Linux console screen blanking behavior](http://superuser.com/a/154388)
* [Wake console screen with SSH](http://raspberrypi.stackexchange.com/questions/10374/wake-console-screen-with-ssh)
* [ArmadeusWiki - Framebuffer](http://www.armadeus.com/wiki/index.php?title=FrameBuffer)