+++
date = "2015-06-30T13:27:00+03:00"
draft = false
title = "Логирование HTTP-запросов в Tomcat"
tags = ["Java"]

+++

## Apache Tomcat Request Dumper Filter

[Request Dumper Filter](http://tomcat.apache.org/tomcat-7.0-doc/config/filter.html#Request_Dumper_Filter) входит в состав Tomcat. Рассмотрим способы его конфигурации. 

### Spring Boot

Достаточно поместить вот такой bean в класс, аннотированный @Configuration:

{{< highlight java >}}
@Bean
RequestDumperFilter requestDumper() {
    return new RequestDumperFilter();
}
{{< /highlight >}}

Вывод дампа запросов в отдельный лог здесь не рассматриваем.

### Tomcat 7

Стандартный способ конфигурации фильтра — server.xml / context.xml / web.xml, в зависимости от того, какой scope нам нужен. Для логирования запросов в рамках одного приложения — web.xml.

{{< highlight xml >}}
<filter>
    <filter-name>RequestDumper</filter-name>
    <filter-class>org.apache.catalina.filters.RequestDumperFilter</filter-class>
</filter>

<filter-mapping>
    <filter-name>RequestDumper</filter-name>
    <url-pattern>*</url-pattern>
</filter-mapping>
{{< /highlight >}}

Для логирования в отдельный файл нужно сконфигурировать [Tomcat JULI](https://tomcat.apache.org/tomcat-7.0-doc/logging.html). По-идее, можно логировать через Apache Commons Logging, но в доке дается пример для JULI. Поэтому, вот такой logging.properties можно смело кидать в webapp/WEB-INF/classes:

{{< highlight ini >}}
# Uncomment to dump HTTP request data, see http://tomcat.apache.org/tomcat-7.0-doc/config/filter.html#Request_Dumper_Filter
#handlers = 1request-dumper.org.apache.juli.FileHandler

# To this configuration below, 1request-dumper.org.apache.juli.FileHandler
# also needs to be added to the handlers property near the top of the file
1request-dumper.org.apache.juli.FileHandler.level = INFO
1request-dumper.org.apache.juli.FileHandler.directory = ${catalina.base}/logs
1request-dumper.org.apache.juli.FileHandler.prefix = request-dumper.
1request-dumper.org.apache.juli.FileHandler.formatter = org.apache.juli.VerbatimFormatter
org.apache.catalina.filters.RequestDumperFilter.level = INFO
org.apache.catalina.filters.RequestDumperFilter.handlers = 1request-dumper.org.apache.juli.FileHandler
{{< /highlight >}}

Получился почти production-ready вариант, для включения логирования можно раскомментировать строчку с handlers и перезапустить приложение. Совсем по-хорошему это нужно сделать через JMX, тогда, быть может, получится избежать перезапуска приложения.

### Tomcat 5

Для старого Томката нужно использовать [Request_Dumper_Valve](https://tomcat.apache.org/tomcat-5.5-doc/config/valve.html#Request_Dumper_Valve). Фильтра в базовой поставке еще нет, его нужно отдельно собирать из servlet-examples.

Для включения дампа нужно просто вставить строчку в server.xml (в блоки Engine или Host) и перезапустить сервер Tomcat:

{{< highlight xml >}}
<Valve className="org.apache.catalina.valves.RequestDumperValve"/>
{{< /highlight >}}

В первом случае (Engine) дамп будет выдаваться в catalina.out, а во втором (Host) - в localhost.log.

***

У Request Dumper Filter есть два недостатка:

* нельзя залогировать тело запроса, только GET- и POST-параметры;
* нет возможности логировать HTTP-ответы сервера.

## Кастомные фильтры

Основная проблема логирования тела запроса — это то, что body из [ServletRequest](http://docs.oracle.com/javaee/6/api/javax/servlet/ServletRequest.html) достается из InputStream, т.е. это одноразовая операция. Мы не можем сначала где-то в фильтре прочитать body, залогировать, а потом второй раз прочитать body в обработчике запроса в приложении. В этом случае выскочит что-то вроде "java.io.IOException: Attempted read on closed stream".  

Различные кастомные способы обходят эту проблему, используя wrapper'ы или декораторы. Т.е. в фильтре мы читаем body из ServletRequest в String-поле wrapper'а, и далее по цепочке передаем уже wrapper. Метод же getInputStream() создает stream из этого String-поля wrapper'а.

Есть две большие статьи с кусками почти работающего кода, реализующего этот подход:

* [Read Request Body in Filter](http://natch3z.blogspot.co.uk/2009/01/read-request-body-in-filter.html)
* [Servlet Filer to Log Request and Response Payload](http://wetfeetblog.com/servlet-filer-to-log-request-and-response-details-and-payload/431)

Также есть маленький, но многообещающий проект [spring-mvc-logger](https://github.com/isrsal/spring-mvc-logger), заточенный под Spring MVC (он использует его logging filters). Его я, к сожалению, не смотрел.

## Logback-access

100% работающий способ логировать HTTP-ответы и запросы. Это [Logback-access](http://logback.qos.ch/access.html), часть проекта Logback. Подробнее см. [Capturing HTTP requests and responses](http://logback.qos.ch/recipes/captureHttp.html). 

Для выборочного отключения логирования (например, для тестовых или мониторинговых платежей) используется библиотека [Janino](http://janino.net/changelog.html). С ее помощью можно задать для logback-access фильтры (правила), которым должен соответствовать логируемый HTTP-пакет.

Однако, весь набор библиотек:

* logback-access.jar + logback-core.jar as dependency,
* janino.jar + commons-compiler.jar as dependency,

должен лежать в $TOMCAT_HOME/lib/.

Конфигурация logback-access.xml кладется в $TOMCAT_HOME/conf/:

{{< highlight xml >}}
<configuration>
    <!-- Tomcat's lib folder must contain logback-core.jar and logback-access.jar to dump HTTP requests and responses -->
    <appender name="DUMPER" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <!-- Tomcat's lib folder must contain janino.jar and commons-compiler.jar to filter which HTTP requests and responses to dump -->
        <filter class="ch.qos.logback.core.filter.EvaluatorFilter">
            <evaluator>
                <!-- Disable dumping for HTTP requests for all apps except specified one and for requests with specific header -->
                <!-- Responses to these requests will not be dumped too -->
                <expression>!event.getRequestURI().startsWith("/webapp") || event.getRequestHeader("X-Logging-Disabled").equals("true")</expression>
            </evaluator>
            <onMismatch>NEUTRAL</onMismatch>
            <onMatch>DENY</onMatch>
        </filter>
        <encoder>
            <pattern>
                %date{yyyy-MM-dd HH:mm:ss.SSS} REQUEST: %fullRequest%n%n%date{yyyy-MM-dd HH:mm:ss.SSS} RESPONSE: %fullResponse
            </pattern>
        </encoder>
        <file>${catalina.base}/logs/dumper.log</file>
        <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <fileNamePattern>${catalina.base}/logs/dumper.%d.%i.log</fileNamePattern>
            <timeBasedFileNamingAndTriggeringPolicy class="ch.qos.logback.core.rolling.SizeAndTimeBasedFNATP">
                <maxFileSize>10MB</maxFileSize>
            </timeBasedFileNamingAndTriggeringPolicy>
        </rollingPolicy>
    </appender>
    <appender-ref ref="DUMPER"/>
</configuration>
{{< /highlight >}}

Эта конфигурация устанавливает логирование всех HTTP-запросов на /webapp без HTTP-заголовка X-Logging-Disabled. 

Также, должен быть активирован LogbackAccessValve в $TOMCAT_HOME/conf/server.xml (в блоке Host):

{{< highlight xml >}}
<Valve className="ch.qos.logback.access.tomcat.LogbackValve"/>
{{< /highlight >}}

Последний штрих — объявление фильтра [TeeFilter](http://logback.qos.ch/apidocs/ch/qos/logback/access/servlet/TeeFilter.html). В Spring Boot это делается элементарно:
 
{{< highlight java >}}
/**
 * Enable HTTP response logging, see <a href="http://logback.qos.ch/recipes/captureHttp.html">Capturing HTTP requests and responses</a>.
 * Tomcat's lib folder must contain logback-core.jar and logback-access.jar.
 */
@Bean
Filter httpRequestAndResponseDumper() {
    return new TeeFilter();
}
{{< /highlight >}}
