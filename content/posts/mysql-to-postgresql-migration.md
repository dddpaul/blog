+++
date = "2016-11-13T12:45:00+03:00"
draft = false
title = "MySQL to PostgreSQL migration"
tags = ["database"]

+++

Install migration Ruby gem and run it:

```
gem install mysql2psql
mysql2psql
```

Update database credentials in generated mysql2psql.yml file:

```
mysql:
  database: redmine
  hostname: localhost
  port: 3306
  username: redmine
  password: xxxxxxx
  encoding: utf8

destination:
 # if file is given, output goes to file, else postgres
 file: /tmp/redmine-pg.sql
 postgres:
  hostname: localhost
  port: 5432
  username: mysql2psql
  password:
  database: mysql2psql_test
```

Run command again:

```
mysql2psql
```

Links:

* [How to migrate from MySQL to PostgreSQL](http://www.redmine.org/boards/2/topics/12825?r=41870)
