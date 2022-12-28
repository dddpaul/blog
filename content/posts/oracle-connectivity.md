+++
date = "2015-02-14T22:11:00+03:00"
draft = false
title = "Oracle connectivity in Java"
tags = ["Java"]

+++

A new small [test project](https://github.com/dddpaul/java-oracle-connectivity) is intended to answer the question - what is the proper way to specify network timeout for database connection?

There so many ways in JDBC API:

* [CommonDataSource.setLoginTimeout](http://docs.oracle.com/javase/7/docs/api/javax/sql/CommonDataSource.html#setLoginTimeout\(int\))
* [Connection.setNetworkTimeout](http://docs.oracle.com/javase/7/docs/api/java/sql/Connection.html#setNetworkTimeout\(java.util.concurrent.Executor,%20int\))
* [Statement.setQueryTimeout](http://docs.oracle.com/javase/7/docs/api/java/sql/Statement.html#setQueryTimeout\(int\))

And every database has it's own non-standard ways in addition.

But these tests have been lead us to a single conclusion — you must specify network timeouts on driver level. All these JDBC stuff isn't enough for Oracle database.

This code is suitable for [Tomcat JDBC Connection Pool](http://tomcat.apache.org/tomcat-7.0-doc/jdbc-pool.html):

{{< highlight java >}}
// Get datasource some way
Datasource ds = createDataSource(host);

// Set connect (login) timeout
ds.setConnectionProperties(OracleConnection.CONNECTION_PROPERTY_THIN_NET_CONNECT_TIMEOUT + "=3000");

// Set common network read timeout
ds.setConnectionProperties(OracleConnection.CONNECTION_PROPERTY_THIN_READ_TIMEOUT + "=3000");
{{< /highlight >}}

The proper way to specify these timeouts in [JNDI Datasource configuration](http://tomcat.apache.org/tomcat-7.0-doc/jndi-datasource-examples-howto.html):

{{< highlight xml >}}
<Resource name="jdbc/oracle"
    driverClassName="oracle.jdbc.OracleDriver"
    factory="org.apache.tomcat.jdbc.pool.DataSourceFactory"
    connectionProperties="oracle.net.CONNECT_TIMEOUT=3000;oracle.jdbc.ReadTimeout=3000"
    ...
    />
{{< /highlight >}}
