+++
date = "2015-12-21T18:45:00+03:00"
draft = false
title = "Different URI encodings for one Tomcat-based application"
tags = ["Java"]

+++

There some cases when you would like to map different URI encodings on different HTTP endpoints. And one of those cases is when your application handles GET requests containing [percent-encoded](https://en.wikipedia.org/wiki/Percent-encoding) non-ASCII data in different charsets. For example, one HTTP endpoint uses standard UTF-8 while the other uses [Windows-1251](https://en.wikipedia.org/wiki/Windows-1251).

## Plain Tomcat way 

According to [How do I change how GET parameters are interpreted?](http://wiki.apache.org/tomcat/FAQ/CharacterEncoding#Q2) the only way to specify GET request encoding is to use by-connector `URIEncoding` attribute. For example:

```xml
 <Connector port="8081" URIEncoding="utf-8"/>
 <Connector port="8082" URIEncoding="cp1251"/>
```

Then you have map servlets to different connectors somehow.

## Spring Boot multiple HTTP connectors way 

Spring Boot can help you out in this matter. Although it uses the only one URI encoding which is specified in `server.tomcat.uri-encoding` parameter ("UTF-8" by default, see [Appendix A. Common application properties](http://docs.spring.io/spring-boot/docs/current/reference/html/common-application-properties.html)), it can fire up multiple child applications residing on different ports.

Implementation is really simple as you can see from [Spring Boot Connectors application](https://github.com/dddpaul/spring-boot-connectors/blob/master/src/main/java/com/github/dddpaul/connectors/Application.java).

Pros:

* no hacks and workarounds, pure Spring Boot solution :)
* controller unit tests are passed.
  
Cons:

* some mess with controllers mappings;
* integration tests (with full context initialization) are failed on non-ASCII requests; in fact, you have no option to point which connector are used in test;
* say bye-bye to Spring Boot actuators, you'll have to use some workarounds to plug them in.  

Links:

* [Spring-Boot : How can I add tomcat connectors to bind to controller](http://stackoverflow.com/questions/26111050/spring-boot-how-can-i-add-tomcat-connectors-to-bind-to-controller)
* [Multiple HTTP connectors in Spring Boot example](https://github.com/dddpaul/spring-boot-connectors)

## Nginx+Lua way

Nginx being built with [Lua module](https://github.com/openresty/lua-nginx-module) becomes a very fast non-blocking application server. They even have a [framework](http://leafo.net/lapis/)! So the URI re-encode it's a quite an easy task to solve.

It's a more complicated way, but if you already use [Nginx](http://nginx.org/) as a reverse proxy server / balancer / HTTPS terminator in front of or Java application — why not?

Nginx build options, functions and configuration file example can be found in [docker-nginx](https://github.com/dddpaul/docker-nginx) project. [Function](https://github.com/dddpaul/docker-nginx/blob/master/lua/functions.lua) to convert encoding: 

{{< highlight lua >}}
function M.iconv(cd, args)
    for key, val in pairs(args) do
        if type(val) == "table" then
            for k, v in pairs(val) do
                val[k] = cd:iconv(v)
            end
        else
            args[key] = cd:iconv(val)
        end
    end
    return args
end
{{< /highlight >}}

It converts only URI parameter values and leaves parameter names untouched. Converting is performed by iconv C library with help of [Lua-iconv binding](http://ittner.github.io/lua-iconv/), so it's very fast.

This Nginx config block configures Lua module, load convert function and initializes iconv:

```
lua_package_path '/etc/nginx/lua/?.lua;;';
init_by_lua_block {
    functions = require("functions")
    iconv = require("iconv")
    cd = iconv.new("utf8", "cp1251")
}
```

In order to re-encode URIs before proxying to Java backend use the following sample:

```
location /app {
    rewrite_by_lua_block {
        if ngx.var.args == nil then return end
        local args = ngx.decode_args(ngx.var.args)
        args = functions.iconv(cd, args)
        args = ngx.encode_args(args)
        ngx.var.args = args
    }
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_pass http://localhost:8000;
}
```    

Pros:

* no multiple connectors, listen on single port;
* extremely fast, no performance drawback;
* all tests are passed.
  
Cons:

* extra devops work :)

Links:

* [dddpaul/docker-nginx](https://github.com/dddpaul/docker-nginx)
* [openresty/lua-nginx-module](https://github.com/openresty/lua-nginx-module)
* [Lua iconv](http://ittner.github.io/lua-iconv/)

## Java hackish way

The idea is the same — url-decode GET-request values, convert to proper encoding and url-encode. At this time it's achieved by using private API of [org.apache.coyote.Request](https://tomcat.apache.org/tomcat-8.0-doc/api/org/apache/coyote/Request.html) class to decode query string conditionally.

Implementation is quite simple as you can see from [Spring Boot Filters application](https://github.com/dddpaul/spring-boot-filters/blob/master/src/main/java/com/github/dddpaul/filters/Application.java).

URIs are re-encoded in servlet filter:
 
{{< highlight java >}}
static class CoyoteRequestManipulator extends OncePerRequestFilter {
    private static Field getField(Class clazz, String fieldName) throws NoSuchFieldException {
        ...
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
                                    FilterChain chain) throws ServletException, IOException {
        if (hasText(request.getQueryString()) && request.getQueryString().contains("%")) {
            RequestFacade facade = (RequestFacade) request;
            try {
                // First hack is to get org.apache.coyote.Request instance
                Field requestField = getField(RequestFacade.class, "request");
                requestField.setAccessible(true);
                Request connRequest = (Request) requestField.get(facade);
                org.apache.coyote.Request coyoteRequest = connRequest.getCoyoteRequest();

                // But it's already filled with decoded query parameters, so query string has
                // to be re-handled after URI encoding switch. So, in fact, query string is
                // processed twice. Yet, org.apache.coyote.Request instances are reusable,
                // so query encoding has to set every time.
                Parameters parameters = coyoteRequest.getParameters();
                parameters.setQueryStringEncoding(request.getServletPath().startsWith("/two")
                        ? "cp1251" : "utf-8");
                parameters.recycle();
                parameters.handleQueryParameters();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        chain.doFilter(request, response);
    }
}
{{< /highlight >}}

Pros:

* no multiple connectors, listen on single port;
* no recompiled Nginx stuff - just Java;
* controller unit tests are passed;
* integration tests are passed.
  
Cons:

* reflection and private API usage :)
* query string could be handled twice.

Links:

* [Spring Boot filter examples](https://github.com/dddpaul/spring-boot-filters)

## The other way

Use the microservices, Luke! But for their simplicity and scalability you have pay with massive infrastructure changes. See the following articles for consideration:

* [Building Microservices with Spring Cloud and Docker](http://www.kennybastani.com/2015/07/spring-cloud-docker-microservices.html)
* [Scaling To Infinity with Docker Swarm, Docker Compose and Consul](http://technologyconversations.com/2015/07/02/scaling-to-infinity-with-docker-swarm-docker-compose-and-consul-part-14-a-taste-of-what-is-to-come/)
* [Deploying Containers with Docker Swarm and Docker Networking](http://technologyconversations.com/2015/11/25/deploying-containers-with-docker-swarm-and-docker-networking/)
