+++
date = 2014-07-30T07:14:41Z
draft = true
title = "Multi-pane layout for tablets"
tags = [ "Android", "Java" ]

+++

Some articles:

* [Multiple-View ViewPager Options](http://commonsware.com/blog/2012/08/20/multiple-view-viewpager-options.html). It's a brilliant set of methods to display several fragments simultaneously using ViewPager. I've personally used first method (overriding getPageWidth() in PagerAdapter) - it works for me.
* [Android ViewPager with Multiple Views](http://shashikawlp.wordpress.com/2012/12/13/android-viewpager-with-multiple-views/). Looks like third method from previous article.

And StackOverflow discussions:

* [Can ViewPager have multiple views in per page?](http://stackoverflow.com/questions/9468581/can-viewpager-have-multiple-views-in-per-page). There are links to CommonsWare article and description of method used for some Dutch newspaper app. Looks nice but it display one full page and part of another - it's not what I need now.
* [ViewPager with different adapters for portrait and landscape](http://stackoverflow.com/questions/23149850/viewpager-with-different-adapters-for-portrait-and-landscape). Dude wants to show A,B,C fragments in portrait mode and A,C only in landscape. Not my case but interesting.
* [How to determine the screen width in terms of dp or dip at runtime in Android?](http://stackoverflow.com/questions/6465680/how-to-determine-the-screen-width-in-terms-of-dp-or-dip-at-runtime-in-android). Describe how to calculate screen size in "density-independent pixels". It's useful for decide when which layout to use programmatically. 
