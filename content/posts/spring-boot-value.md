+++
date = "2015-07-12T18:30:00+03:00"
draft = false
title = "Тонкости использования аннотации @Value в Spring Boot"
tags = ["Java"]

+++

Аннотация [@Value](http://docs.spring.io/spring/docs/current/javadoc-api/org/springframework/beans/factory/annotation/Value.html) - это самый простой способ для "впрыскивания" значений из конфигурации Spring Boot в код. При этом также можно задать значение по-умолчанию.

Однако, стоит учитывать, что резолвинг значения будет выполняться для каждой аннотации @Value. Например, если аннотировать @Value два поля (в одном или разных классах - не суть важно) вот так:

{{< highlight java >}}
@Value("${unique-param}")
private String param1;

@Value("${unique-param}")
private String param2;
{{< /highlight >}}

, то в debug-логе мы увидим:

```
TRACE 23601 --- [lication.main()] o.s.c.e.PropertySourcesPropertyResolver  : getProperty("unique-param", String)
DEBUG 23601 --- [lication.main()] o.s.c.e.PropertySourcesPropertyResolver  : Searching for key 'unique-param' in [environmentProperties]
...
TRACE 23601 --- [lication.main()] o.s.c.e.PropertySourcesPropertyResolver  : getProperty("unique-param", String)
DEBUG 23601 --- [lication.main()] o.s.c.e.PropertySourcesPropertyResolver  : Searching for key 'unique-param' in [environmentProperties]
...
```

Т.е. поиск (резолвинг) был проведен дважды. Конечно, это слишком мизерная операция, чтобы хоть как-то замедлить старт приложения, но знать об этом стоит.

***

Еще более неоднозначная штука связана с передачей дефолтного значения через @Value.

{{< highlight java >}}
@Value("${unique-param:DefaultValue}")
private String param;
{{< /highlight >}}

При резолвинге значения будет сначала проведен поиск параметра "unique-param:DefaultValue", а уже потом - "unique-param". Таким образом, если в конфигурации указать:

{{< highlight ini >}}
unique-param\:DefaultValue = Another value
{{< /highlight >}}

, то param в коде будет равен "Another value".

Такая логика прописана в org.springframework.util.PropertyPlaceholderHelper#parseStringValue.

***

Оба этих нюанса могут ответить на вопрос - почему debug-лог приложения на Spring Boot такой большой. 

Мораль - используйте [ConfigurationProperties](http://docs.spring.io/autorepo/docs/spring-boot/current/api/org/springframework/boot/context/properties/ConfigurationProperties.html), что, в конце-концов, и советуется в [23. Externalized Configuration](http://docs.spring.io/spring-boot/docs/current/reference/html/boot-features-external-config.html), раздел "23.7 Typesafe Configuration Properties".

Например:

{{< highlight java >}}
@ConfigurationProperties(prefix = "params")
public class Config {
    private String uniqueParam = "Default value";

    // Getters are mandatory. Setters are mandatory for immutable types (such as String).
 }
{{< /highlight >}}

Конфигурация:

{{< highlight ini >}}
params.unique-param = Another value
{{< /highlight >}}
