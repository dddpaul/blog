+++
date = "2015-02-01T18:44:06+03:00"
draft = false
title = "Java network listeners"
tags = ["Java"]

+++

I've written a small [listeners library](https://github.com/dddpaul/java-network-listeners) today. It allows to create Callables which can be submitted to [ExecutorService](http://docs.oracle.com/javase/7/docs/api/java/util/concurrent/ExecutorService.html). The callable itself implements creating server socket and binding it to local port.

There two principal type of listeners: blocking and non-blocking (thanks to [Java NIO](http://en.wikipedia.org/wiki/Non-blocking_I/O_(Java)).

***

Blocking listener is very simple but in can't be interrupted by calling thread. So there's no point in that:

{{< highlight java >}}
Future<Socket> future = executor.submit( Listeners.createListener( PORT ) );
try {
    Socket socket = future.get( 1, TimeUnit.SECONDS );
} catch( TimeoutException e ) {
    future.cancel( true );
}
{{< /highlight >}}

Listener will stay active and PORT will be bound still. The reason is in usage of the uninterruptible [ServerSocket.accept()](http://docs.oracle.com/javase/7/docs/api/java/net/ServerSocket.html#accept()).

***

In contrary non-blocking listener is more sophisticated but it can be interrupted by calling thread. So you can do that:

{{< highlight java >}}
Future<Socket> future = executor.submit( Listeners.createListener( PORT ) );
try {
    Socket socket = future.get( 1, TimeUnit.SECONDS );
} catch( TimeoutException e ) {
    future.cancel( true );
}
{{< /highlight >}}

Listener will be terminated and PORT will be freed.



