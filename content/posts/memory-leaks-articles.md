+++
date = "2015-01-17T22:35:49+03:00"
draft = false
title = "List of memory leaks articles"
series = [ "Memory leaks" ]
tags = [ "Java" ]
+++

"Solving OutOfMemoryError" series from Nikita Salnikov-Tarnovsky and Vladimir Šor:

* [Solving OutOfMemoryError (part 1) – story of a developer](https://plumbr.eu/blog/solving-outofmemoryerror-story-of-a-developer)
* [Solving OutOfMemoryError (part 2) – why didn’t operations solve it?](https://plumbr.eu/blog/solving-outofmemoryerror-why-didnt-operations-solve-it)
* [Solving OutOfMemoryError (part 3) – where do you start?](https://plumbr.eu/blog/solving-outofmemoryerror-where-do-you-start)
* [Solving OutOfMemoryError (part 4) – memory profilers](https://plumbr.eu/blog/solving-outofmemoryerror-memory-profilers)
* [Solving OutOfMemoryError (part 5) – JDK Tools](https://plumbr.eu/blog/solving-outofmemoryerror-jdk-tools)
* [Solving OutOfMemoryError (part 6) – Dump is not a waste](https://plumbr.eu/blog/solving-outofmemoryerror-dump-is-not-a-waste)

***

"Classloader leaks" series from Mattias Jiderhamn:

* [Classloader leaks I – How to find classloader leaks with Eclipse Memory Analyser (MAT)](http://java.jiderhamn.se/2011/12/11/classloader-leaks-i-how-to-find-classloader-leaks-with-eclipse-memory-analyser-mat/)
* [Classloader leaks II – Find and work around unwanted references](http://java.jiderhamn.se/2012/01/01/classloader-leaks-ii-find-and-work-around-unwanted-references/)
* [Classloader leaks III – “Die Thread, die!”](http://java.jiderhamn.se/2012/01/15/classloader-leaks-iii-die-thread-die/)
* [Classloader leaks IV – ThreadLocal dangers and why ThreadGlobal may have been a more appropriate name](http://java.jiderhamn.se/2012/01/29/classloader-leaks-iv-threadlocal-dangers-and-why-threadglobal-may-have-been-a-more-appropriate-name/)
* [Classloader leaks V – Common mistakes and Known offenders](http://java.jiderhamn.se/2012/02/26/classloader-leaks-v-common-mistakes-and-known-offenders/)
* [Classloader leaks VI – “This means war!” (leak prevention library)](http://java.jiderhamn.se/2012/03/04/classloader-leaks-vi-this-means-war-leak-prevention-library/)

Object, class and classloader relationships are illustrated by this graph from [What is a PermGen leak?](https://plumbr.eu/blog/what-is-a-permgen-leak) article.

{{% img src="media/object-class-classloader.png" %}}

***

Tomcat specific articles:

* [Memory Leak Protection in Tomcat 7](http://java.dzone.com/articles/memory-leak-protection-tomcat)
* [Tomcat Wiki - MemoryLeakProtection](http://wiki.apache.org/tomcat/MemoryLeakProtection)

***

Other articles:

* [What is a memory leak?](https://plumbr.eu/blog/what-is-a-memory-leak)
* [What is a PermGen leak?](https://plumbr.eu/blog/what-is-a-permgen-leak)
* [The Guide to Solving Permgen Leaks](https://plumbr.eu/permgen)
* [Classloader leaks: the dreaded "java.lang.OutOfMemoryError: PermGen space" exception](http://frankkieviet.blogspot.se/2006/10/classloader-leaks-dreaded-permgen-space.html)
