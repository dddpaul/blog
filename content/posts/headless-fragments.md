+++
date = 2014-07-29T07:55:41Z
draft = false
title = "Retaining state with headless fragments"
tags = [ "Android", "Java" ]

+++

Some articles:

* Official [Fragments guide](http://developer.android.com/guide/components/fragments.html). Has some clues for headless fragments (see "Adding a fragment without a UI").
* Superb [multi-pane fragments tutorial](http://www.vogella.com/tutorials/AndroidFragments/article.html) from Lars Vogel. Contains some tips for [headless fragments](http://www.vogella.com/tutorials/AndroidFragments/article.html#headlessfragments).
* [Android best tip to work with fragments and orientation change](http://techbandhu.wordpress.com/2013/07/02/android-headless-fragment/). More detailed headless fragments technique description. 
* Headless fragment example - [FragmentRetainInstance.java](https://android.googlesource.com/platform/development/+/master/samples/ApiDemos/src/com/example/android/apis/app/FragmentRetainInstance.java). In this code headless fragment is created from other fragment. In my case it's inappropriate because of Robolectric testing (recursive fragment transactions).
* [Saving (And Retrieving) Android Instance State – Part 2](http://www.intertech.com/Blog/saving-and-retrieving-android-instance-state-part-2/). Details about retained fragments. Neat retained fragment lifecycle.
* [Handling Configuration Changes with Fragments](http://www.androiddesignpatterns.com/2013/04/retaining-objects-across-config-changes.html). Main advice - Manage the Object Inside a Retained Fragment.
* [Android Activity/Fragment life cycle analysis](http://ideaventure.blogspot.com.au/2014/01/android-activityfragment-life-cycle.html). Full logging of all lifecycle method calls in different situations.

And StackOverflow discussions:

* [Unable to use Fragment.setRetainInstance() as a replacement for Activity.onRetainNonConfigurationInstance()](http://stackoverflow.com/questions/11591302/unable-to-use-fragment-setretaininstance-as-a-replacement-for-activity-onretai). How to preserve fragments with WebViews and AsyncTasks. One of the answers is to override Fragment.onDestroy() and save asynctasks to Application object.
* [Further understanding setRetainInstance(true)](http://stackoverflow.com/questions/12640316/further-understanding-setretaininstancetrue). Retained fragment lifecycle logs.
* [Android Fragments. Retaining an AsyncTask during screen rotation or configuration change](http://stackoverflow.com/questions/8417885/android-fragments-retaining-an-asynctask-during-screen-rotation-or-configuratio). Retained fragment with inner asynctask example and much more. AsyncTask has reference to fragment - it's interesting.
