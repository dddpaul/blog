+++
date = "2015-04-12T12:15:00+03:00"
draft = false
title = "Java builders"
tags = ["Java"]

+++

So it's time to scrutinize [a builder pattern](http://en.wikipedia.org/wiki/Builder_pattern). There are bunch of options to implement builder pattern in Java:

* [classic](http://habrahabr.ru/post/86252/) builder;
* [elegant](http://habrahabr.ru/post/244521/) builder;
* classic builder with [IntelliJ IDEA plugin](https://github.com/analytically/innerbuilder);
* [Google AutoValue](https://github.com/google/auto/tree/master/value) builder;
* [Project Lombok](http://projectlombok.org/features/Builder.html) builder;
* [POJO](https://github.com/mkarneim/pojobuilder) builder;
* [Immutables](http://immutables.github.io/) builder.

All of these variants have been examined in [Java builders](https://github.com/dddpaul/java-builders) GitHub project.

The winners are (and this a tough IMHO):

* IDEA InnerBuilder plugin if you use builder class from frameworks like [Spring/Spring MVC](http://spring.io/) or [Play](https://www.playframework.com/). You can't pass validation annotations to generated class. Despite everything if there is a way to do this I'll be happy to mistake.
* Immutables.org builder in all other cases. It's features rich and generates beautiful code.

But do not forget about AutoValue because it's backed by Google itself.
