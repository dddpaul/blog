+++
date = 2014-12-06T18:33:46Z
draft = false
title = "Java Memory Model in few words"
series = [ "JMM" ]
tags = ["Java"]

+++

This article is mostly consist of quotes from [The Well-Grounded Java Developer](http://www.manning.com/evans/) by Benjamin J. Evans and Martijn Verburg. I like simplicity and brevity of their explanation approach.

And that's how *Happens-Before* and *Synchronizes-With* relationships are explained.  

***

* Happens-Before — This relationship indicates that one block of code fully completes before the other can start.
* Synchronizes-With — This means that an action will synchronize its view of an object with main memory before continuing.

The JMM has these main rules:

* An unlock operation on a monitor *Synchronizes-With* later lock operations.
* A write to a volatile variable *Synchronizes-With* later reads of the variable.
* If an action A *Synchronizes-With* action B, then A *Happens-Before* B.
* If A comes before B in program order, within a thread, then A *Happens-Before* B.

The general statement of the first two rules is that *"releases happen before acquires"*. In other words, the locks that a thread holds when writing are released before the locks can be acquired by other operations (including reads).

There are additional rules, which are really about sensible behavior:

* The completion of a constructor *Happens-Before* the finalizer for that object starts to run (an object has to be fully constructed before it can be finalized).
* An action that starts a thread *Synchronizes-With* the first action of the new thread.
* Thread.join() *Synchronizes-With* the last (and all other) actions in the thread being joined.*
* If X *Happens-Before* Y and Y *Happens-Before* Z then X *Happens-Before* Z (transitivity).

***

They even have granted free access to entire [Chapter 4. Modern concurrency](http://www.manning.com/evans/TWGJD_sample_ch04.pdf). Although I'm not relish with the code style (using trailing underscore to emphasize method parameters - why?) this chapter definitely deserves to read it.

Footnotes:

\* [JLS. Chapter 17. Threads and Locks](https://docs.oracle.com/javase/specs/jls/se7/html/jls-17.html) assures that:

> All actions in a thread happen-before any other thread successfully returns from a join() on that thread.

So, the truth is that thread actions happens-before Thread.join().