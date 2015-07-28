+++
date = "2015-07-28T10:45:00+03:00"
draft = false
title = "Bind interfaces to multiple zones with Firewalld on CentOS-7"
tags = ["Linux"]

+++

As you can expect from [man firewall-cmd](http://linuxmanpages.net/manpages/fedora20/man1/firewall-cmd.1.html) interface binding to zone other than default (public) could be achieved with the following command sequence:

```
firewall-cmd --zone public --remove-interface eth1 --permanent
firewall-cmd --zone internal --add-interface eth1 --permanent
firewall-cmd --reload
```

Seems like it's done:

```
firewall-cmd --get-zone-of-interface=eth1
internal
```

But after firewalld restart or server reboot things aren't so bright:
 
```
firewall-cmd --get-zone-of-interface=eth1
public
```

The reason is in this [CentOS-7 bug](https://bugs.centos.org/view.php?id=7526). The only workaround is to specify zone in _/etc/sysconfig/network-scripts/ifcfg-eth1_ file:

```
TYPE=Ethernet
NAME="eth1"
IPADDR=x.x.x.x
...
ZONE=internal
```
