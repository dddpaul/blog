+++
date = 2014-08-01T13:34:16Z
draft = false
title = "Memory leaks"
tags = [ "Android", "Java" ]

+++

Articles:

* [Avoiding memory leaks](http://android-developers.blogspot.ru/2009/01/avoiding-memory-leaks.html). This great article describes base causes of memory leaks on Android. I quote summary from there:

    * Do not keep long-lived references to a context-activity (a reference to an activity should have the same life cycle as the activity itself)
    * Try using the context-application instead of a context-activity
    * Avoid non-static inner classes in an activity if you don't control their life cycle, use a static inner class and make a weak reference to the activity inside. The solution to this issue is to use a static inner class with a WeakReference to the outer class, as done in ViewRoot and its W inner class for instance
    * A garbage collector is not an insurance against memory leaks

* [How to Leak a Context: Handlers & Inner Classes](http://www.androiddesignpatterns.com/2013/01/inner-class-handler-memory-leak.html). Be cautious when using inner classes inside activity. The summary:
    
    * In Java, non-static inner and anonymous classes hold an implicit reference to their outer class. Static inner classes, on the other hand, do not.
    * Avoid using non-static inner classes in an activity if instances of the inner class outlive the activity's lifecycle.
    * Instead, prefer static inner classes and hold a weak reference to the activity inside.

* [Отслеживание утечек памяти в Android приложениях](http://habrahabr.ru/post/116294/). This article gives example of class for tracking memory leaks based on WeakReference.

StackOverflow discussions mostly:

* [TextView with id and textIsSelectable="true" causes leaking of the Activity object](http://geekple.com/blogs/feeds/9AlMn/posts/354891570708736). And corresponding [Stack Overflow topic](http://stackoverflow.com/questions/22990634/textview-with-id-and-textisselectable-true-causes-leaking-of-the-activity-obje). I've bumped into this issue personally and spent a quite some time too. Rotating emulator and heapdumping mostly :) The point is that TextView with id and android:textIsSelectable="true" causes memory leak on Android 4.0.x, 4.1.x, 4.2.x, 4.3.x. Can't check it on 4.4.2 because of [emulator bug](https://code.google.com/p/android/issues/detail?id=61671).
* [Android EditText Memory Leak](http://stackoverflow.com/questions/18348049/android-edittext-memory-leak), [Why does EditText retain its Activity's Context in Ice Cream Sandwich](http://stackoverflow.com/questions/8497965/why-does-edittext-retain-its-activitys-context-in-ice-cream-sandwich), [EditText causing memory leak](http://stackoverflow.com/questions/14069501/edittext-causing-memory-leak). The main theme of this topics is that EditText leaks when spellchecker suggestions are used. You can turn it off but it can help or maybe not. EditText is leaking on Android 4.0.x, 4.1.x, 4.2.x. Thanks god, seems like it's fixed in Android 4.3, API 18 (checked on Nexus 7 2013 emulator). Although [corresponding issue](https://code.google.com/p/android/issues/detail?id=60930) is still open.
* [Fragments are not being released from memory](http://stackoverflow.com/a/18414294). A valuable advice - use weak references to point to any object that references its context outside of your Activity. I'm not sure is it a proper approach to weak referencing ViewPager, but for some more "distant" object like [AsyncTask](http://www.michenux.net/android-asynctask-in-fragment-best-pratices-725.html) it might be reasonable.

Videos:

* [ Google I/O 2011: Memory management for Android Apps ](http://www.youtube.com/watch?v=_CruQY55HOk). Presentation by [Patrick Dubroy](http://dubroy.com).