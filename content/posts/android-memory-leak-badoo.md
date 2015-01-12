+++
date = 2014-10-21T14:30:16Z
draft = false
title = "Борьба с утечками памяти в Android (Badoo)"
series = [ "Memory leaks" ]
tags = [ "Android", "Java" ]

+++

На хабре появилась статья [Борьба с утечками памяти в Android. Часть 1](http://habrahabr.ru/company/badoo/blog/240479/) от компании Badoo. Т.к. тема созвучна с моими постами из серии {{% link section="series" title="Memory leaks" %}}, то решил вкратце описать их методы.

Суть проблемы — использование android.os.Handler, в который постится анонимный Runnable с помощью метода [postDelayed](http://developer.android.com/reference/android/os/Handler.html#postDelayed(java.lang.Runnable, long). Для демонстрации, Runnable просто меняет какой-либо TextView (т.е. содержит внутри себя ссылку mTextView), и время до выполнения Runnable берется довольно большим. Так вот, если за этот промежуток времени повернуть девайс несколько раз, то старые активити не будут собираться GC, т.к. в Java любой анонимный класс всегда имеет неявную ссылку на внешний класс.

### Решение с использованием статического класса

Переделка анонимного класса в статический проблему не решает — Activity сохранен в ссылке mContext из mTextView внутри нашей реализации Runnable.

### Решение с использованием статического класса и WeakReference

В реализации Runnable сохраняем ссылку на TextView в WeakReference. Использование WeakReference требует особой аккуратности: такая ссылка в любой момент может обнулиться. Поэтому сначала сохраняем ссылку в локальную переменную и работаем только с последней, проверив ее на null.

Для использования данного подхода нам необходимо:

* использовать статический внутренний или внешний класс;
* использовать WeakReference для всех объектов, на которые мы ссылаемся.

Это решает проблему.

### Очистка всех сообщений в onDestroy

Добавим в onDestroy вызов метода класса Handler [removeCallbacksAndMessages](http://developer.android.com/reference/android/os/Handler.html#removeCallbacksAndMessages\(java.lang.Object\)). Он удаляет все сообщения, находящиеся в очереди данного Handler'а. Это очень хороший способ защититься от утечки памяти, но во-первых, нужно не забыть это сделать, а во-вторых, в комментах к статье пишут, что вызов onDestroy в общем случае не гарантирован.  

Цитата из документации — [Stopping and Restarting an Activity](http://developer.android.com/training/basics/activity-lifecycle/stopping.html):

> When your activity receives a call to the onStop() method, it's no longer visible and should release almost all resources that aren't needed while the user is not using it. Once your activity is stopped, the system might destroy the instance if it needs to recover system memory. In extreme cases, the system might simply kill your app process without calling the activity's final onDestroy() callback, so it's important you use onStop() to release resources that might leak memory.

### Решение с использованием WeakHandler

Команда Badoo написала свой Handler — [WeakHandler](github.com/badoo/android-weak-handler). Это класс, который ведет себя совершенно как Handler, но исключает утечки памяти за счет использования слабых ссылок.
 
Главная идея — держать жесткую ссылку на сообщения или Runnable до тех пор, пока существует жесткая ссылка на WeakHandler. Как только WeakHandler может быть удален из памяти, все остальное должно быть удалено вместе с ним.

### Выводы

Отличная и годная статья :)

Ссылки:

* [A journey on the Android Main Thread - PSVM](http://corner.squareup.com/2013/10/android-main-thread-1.html). Рассказ про про внутренности Main Thread: Loopers, Handlers и т.д.
* [A journey on the Android Main Thread - Lifecycle bits](http://corner.squareup.com/2013/12/android-main-thread-2.html). Продолжение — про lifecycle и orientation change. 