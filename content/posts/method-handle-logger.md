+++
date = 2014-12-21T13:36:15Z
draft = false
title = "Using method handles to get logger"
tags = ["Java"]
+++

One more quote from [The Well-Grounded Java Developer](http://www.manning.com/evans/) by Benjamin J. Evans and Martijn Verburg about useful feature of [MethodHandle](http://docs.oracle.com/javase/7/docs/api/java/lang/invoke/MethodHandle.html).

***

One additional feature that method handles provide is the ability to determine the current class from a static context. If you’ve ever written logging code (such as for log4j) that looked like this,

```
Logger lgr = LoggerFactory.getLogger(MyClass.class);
```

you know that this code is fragile. If it’s refactored to move into a superclass or subclass, the explicit class name would cause problems With Java 7, however, you can write this:

```
Logger lgr = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
```

***

It's really works :)
