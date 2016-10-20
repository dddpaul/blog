+++
date = "2016-10-20T11:00:00+03:00"
draft = false
title = "Let's Encrypt with lego and Nginx"
tags = ["linux"]

+++

[xenolf/lego](https://github.com/xenolf/lego) it's a feature-rich Let's Encrypt client and ACME library written in Go.

**1.** Prepare Nginx server

```
server {
    listen 80 default;
    server_name example.org www.example.org;

    location /.well-known/acme-challenge {
        proxy_pass http://127.0.0.1:81;
        proxy_set_header Host $host;
    }

    # Other directives
}
```

**2.** Update ca-certificates for CentOS 5 (optional)

Let's Encrypt CA certificate is not included into root CA bundle of old Linux distributions like RHEL/Centos 5. You have to replace this bundle manually with fresh one from [cURL website](http://curl.haxx.se/):
  
```
cp /etc/pki/tls/certs/ca-bundle.crt /etc/pki/tls/certs/ca-bundle.crt.bak
wget -O /etc/pki/tls/certs/ca-bundle.crt http://curl.haxx.se/ca/cacert.pem
```

**3.** Order the certificate from Let's Encrypt

```
lego -d example.org -d www.example.org -m cert-owner@example.org -a --path=/etc/pki/tls/lego --http=:81 run
```

**4.** Update Nginx server

```
server {
    listen 80 default;
    server_name example.org www.example.org;

    location /.well-known/acme-challenge {
        proxy_pass http://127.0.0.1:81;
        proxy_set_header Host $host;
    }

    # Other directives
}

server {
    listen 443 ssl;
    server_name example.org www.example.org;

    ssl_certificate /etc/pki/tls/lego/certificates/example.org.crt;
    ssl_certificate_key /etc/pki/tls/lego/certificates/example.org.key;

    location /.well-known/acme-challenge {
        proxy_pass http://127.0.0.1:444;
        proxy_set_header Host $host;
    }

    # Other directives
}

```

**5.** Renew certificate every 2 month at 01:30 of first day of the month

Add to crontab:

```
30 01 01 */2 * /usr/local/bin/lego -d example.org -d www.example.org -m cert-owner@example.org -a --path=/etc/pki/tls/lego --http=:81 --tls=:444 renew && /usr/sbin/nginx -s reload
```

Links:

* [Let's Encrypt client and ACME library written in Go](https://github.com/xenolf/lego)
* [LET’S ENCRYPT WITH LEGO AND NGINX](https://code.kuederle.com/letsencrypt/)
* [CentOS 5 CA Certificate Bundle Update](https://raymii.org/s/snippets/CentOS_5_CA_Certificate_Bundle_Update.html)
