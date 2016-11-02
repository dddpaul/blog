+++
date = "2016-11-02T09:00:00+03:00"
draft = false
title = "Docker registry on Centos 7"
tags = ["linux", "docker"]

+++

**1.** Create logical volumes for `direct-lvm` production mode

Official [Device Mapper storage driver guide](https://docs.docker.com/engine/userguide/storagedriver/device-mapper-driver/) recommends to use [thin pools](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Logical_Volume_Manager_Administration/thinprovisioned_volumes.html) now. But we will follow more simple way :)
 
Assume that we have 40 GByte block device named as `/dev/sdb` with one full-size Linux partition on it. 

{{< highlight shell >}}
pvcreate /dev/sdb1                 # Create physical volume
vgcreate docker /dev/sdb1          # Create volume group and add this physical volume to it
lvcreate -L 2G -n metadata docker  # Create logical volume for Docker metadata
lvcreate -L 15G -n data docker     # Create logical volume for Docker data (layers, containers etc)
lvcreate -L 15G -n registry docker # Create logical volume for Docker Registry data
{{< /highlight >}}

Mount volume for Docker registry:

{{< highlight shell >}}
mkfs.xfs /dev/docker/registry
echo "/dev/docker/registry /var/lib/docker-registry    xfs     defaults        1 3" >> /etc/fstab 
mount -a
{{< /highlight >}}

Check:

```
lsblk
NAME                             MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda                                8:0    0   120G  0 disk
├─sda1                             8:1    0   876M  0 part /boot
└─sda2                             8:2    0 119,1G  0 part
  ├─centos-swap                  253:0    0     2G  0 lvm  [SWAP]
  └─centos-root                  253:1    0 117,2G  0 lvm  /
sdb                                8:16   0    40G  0 disk
└─sdb1                             8:17   0    40G  0 part
  ├─docker-metadata              253:2    0     2G  0 lvm
  │ └─docker-253:1-23762136-pool 253:5    0    15G  0 dm
  ├─docker-data                  253:3    0    15G  0 lvm
  │ └─docker-253:1-23762136-pool 253:5    0    15G  0 dm
  └─docker-registry              253:4    0    15G  0 lvm  /var/lib/docker-registry
```

**2.** Configure Docker daemon

Create systemd drop-in file: 

{{< highlight shell >}}
mkdir -p /etc/systemd/system/docker.service.d
cat > /etc/systemd/system/docker.service.d/env.conf 
[Service]
EnvironmentFile=-/etc/sysconfig/docker
ExecStart=
ExecStart=/usr/bin/dockerd $OPTIONS $DOCKER_NETWORK_OPTIONS $DOCKER_STORAGE_OPTIONS
{{< /highlight >}}

Specify Docker configuration:

{{< highlight shell >}}
cat > /etc/sysconfig/docker 
OPTIONS='--iptables=false'
DOCKER_NETWORK_OPTIONS=''
DOCKER_STORAGE_OPTIONS='--storage-driver=devicemapper --storage-opt dm.datadev=/dev/docker/data --storage-opt dm.metadatadev=/dev/docker/metadata'
{{< /highlight >}}

Check:
 
{{< highlight shell >}}
systemctl daemon-reload
systemctl show docker | grep EnvironmentFile
EnvironmentFile=/etc/sysconfig/docker (ignore_errors=yes)
{{< /highlight >}}

And run:

{{< highlight shell >}}
systemctl enable docker
systemctl restart docker
{{< /highlight >}}

Check again:

{{< highlight shell >}}
docker info | grep data
 Data file: /dev/docker/data
 Metadata file: /dev/docker/metadata
 Metadata Space Used: 639 kB
 Metadata Space Total: 2.147 GB
 Metadata Space Available: 2.147 GB
{{< /highlight >}}

**3.** Obtain SSL certificate from Let's Encrypt

It's can be done by different ways, see [Let's Encrypt with lego and Nginx]({{< ref "posts/lego-nginx.md" >}}) for one of these.

Assume that certificate and key was obtained and stored in `/etc/pki/tls/lego/certificates` directory.  

**4.** Run Docker registry container as systemd unit
 
Create systemd unit:

{{< highlight shell >}}
cat > /etc/systemd/system/docker-registry.service
[Unit]
Description=Docker registry container
Requires=docker.service
After=docker.service

[Service]
Restart=always
ExecStartPre=/usr/bin/docker create -p 5000:5000 -v /var/lib/docker-registry:/var/lib/registry -v /etc/pki/tls/lego/certificates:/certs -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/example.org.crt -e REGISTRY_HTTP_TLS_KEY=/certs/example.org.key --name registry registry:2
ExecStart=/usr/bin/docker start -a registry
ExecStop=/usr/bin/docker stop -t 5 registry
ExecStopPost=/usr/bin/docker rm registry

[Install]
WantedBy=multi-user.target
</pre>
{{< /highlight >}}

**5.** Permit access to Docker registry only from trusted networks

{{< highlight shell >}}
firewall-cmd --zone=trusted --add-port=5000/tcp --permanent
firewall-cmd --zone=trusted --add-source=192.168.1.0/24 --permanent
firewall-cmd --reload
{{< /highlight >}}

Since Docker daemon was launched with `--iptables=false` option, Docker registry port may be accessed from trusted networks only.   

Links:

* [Control and configure Docker with systemd](https://docs.docker.com/engine/admin/systemd/)
* [Docker and the Device Mapper storage driver](https://docs.docker.com/engine/userguide/storagedriver/device-mapper-driver/)
* [Deploying Docker Registry with Let's Encrypt SSL/TLS Certs](http://trainingdevops.com/insights-and-tutorials/deploying-docker-registry-with-let-s-encrypt-ssl-tls-certs)
