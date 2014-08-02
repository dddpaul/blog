+++
date = 2014-08-01T13:34:16Z
draft = false
title = "Memory leaks"
tags = [ "Android", "Java" ]

+++

StackOverflow discussions mostly:

* [TextView with id and textIsSelectable="true" causes leaking of the Activity object](http://geekple.com/blogs/feeds/9AlMn/posts/354891570708736). And corresponding [Stack Overflow topic](http://stackoverflow.com/questions/22990634/textview-with-id-and-textisselectable-true-causes-leaking-of-the-activity-obje). I've bumped into this issue personally and spent a quite some time too. Rotating emulator and heapdumping mostly :) The point is that TextView with id and android:textIsSelectable="true" causes memory leak on Android 4.0.x, 4.1.x, 4.2.x, 4.3.x. Can't check it on 4.4.2 because of [emulator bug](https://code.google.com/p/android/issues/detail?id=61671).
* [Android EditText Memory Leak](http://stackoverflow.com/questions/18348049/android-edittext-memory-leak), [Why does EditText retain its Activity's Context in Ice Cream Sandwich](http://stackoverflow.com/questions/8497965/why-does-edittext-retain-its-activitys-context-in-ice-cream-sandwich), [EditText causing memory leak](http://stackoverflow.com/questions/14069501/edittext-causing-memory-leak). The main theme of this topics is that EditText leaks when spellchecker suggestions are used. You can turn it off but it can help or maybe not. EditText is leaking on Android 4.0.x, 4.1.x, 4.2.x. Thanks god, seems like it's fixed in Android 4.3, API 18 (checked on Nexus 7 2013 emulator). Although [corresponding issue](https://code.google.com/p/android/issues/detail?id=60930) is still open.
* [Fragments are not being released from memory](http://stackoverflow.com/a/18414294). A valuable advice - use weak references to point to any object that references its context outside of your Activity. I'm not sure is it a proper approach to weak referencing ViewPager, but for some more "distant" object like [AsyncTask](http://www.michenux.net/android-asynctask-in-fragment-best-pratices-725.html) it might be reasonable.