+++
date = "2016-03-17T11:00:00+03:00"
draft = false
title = "Linearizability, serializability, transaction isolation and consistency models"
tags = [ "Database", "Concurrency" ]
+++

[Linearizability versus Serializability](http://www.bailis.org/blog/linearizability-versus-serializability/):

> **Linearizability** is a guarantee about single operations on single objects. It provides a real-time (i.e., wall-clock) guarantee on the behavior of a set of single operations (often reads and writes) on a single object (e.g., distributed register or data item).

> Linearizability for read and write operations is synonymous with the term “atomic consistency” and is the “C,” or “consistency,” in Gilbert and Lynch’s proof of the CAP Theorem. We say linearizability is composable (or “local”) because, if operations on each object in a system are linearizable, then all operations in the system are linearizable.

> **Serializability** is a guarantee about transactions, or groups of one or more operations over one or more objects. It guarantees that the execution of a set of transactions (usually containing read and write operations) over multiple items is equivalent to some serial execution (total ordering) of the transactions.

> Serializability is the traditional “I,” or isolation, in ACID. If users’ transactions each preserve application correctness (“C,” or consistency, in ACID), a serializable execution also preserves correctness. Therefore, serializability is a mechanism for guaranteeing database correctness.

***

[Distributed Consistency and Session Anomalies](http://blog.acolyer.org/2016/02/26/distributed-consistency-and-session-anomalies/):

> In the database systems community, the gold standard is serializability. We’ve spent plenty of time looking at this in the last couple of days. Serializability concerns transactions that group multiple operations across potentially multiple objects. A serializable schedule is one that corresponds to some ordering of the transactions such that they happen one after the other in time (no concurrent / overlapping transactions). It’s the highest form of isolation between transactions.

{{% img src="media/serializable.png" %}}

> In the distributed systems community, the gold standard is linearizability. Linearizability concerns single operations on single objects. A linearizable schedule is one where each operation appears to happen atomically at a single point in time. Once a write completes, all later reads (wall-clock time) should see the value of that write or the value of a later write. In a distributed context, we may have multiple replicas of an object’s state, and in a linearizable schedule it is as if they were all updated at once at a single point in time.

{{% img src="media/linearizable.png" %}}

***

[A Critique of ANSI SQL Isolation Levels](http://blog.acolyer.org/2016/02/24/a-critique-of-ansi-sql-isolation-levels/):

{{% img src="media/ansi-sql-isolation-levels.png" %}}

***

Other articles:

* [Strong consistency models](https://aphyr.com/posts/313-strong-consistency-models)
* [A beginner’s guide to database locking and the lost update phenomena](http://vladmihalcea.com/2014/09/14/a-beginners-guide-to-database-locking-and-the-lost-update-phenomena/)
* [Generalized Isolation Level Definitions](http://blog.acolyer.org/2016/02/25/generalized-isolation-level-definitions/)
* [PostgreSQL - 13.2. Transaction Isolation](http://www.postgresql.org/docs/current/static/transaction-iso.html)
