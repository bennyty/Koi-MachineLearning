Koi Pond. An intro to machine learning.
=======================================
	Benjamin Espey

Koi (rename possible as these will not look like fish) is a very very basic interactive simulation of life.
Good luck to me!


                    Diagram of the HFSM                                                                 Decision tree for hunting state

+----------------------------+                 +---------------------------+                           +--------------------+
|                            |                 |                           |                           |                    |
|                            |                 |                           |                           |      Hunting       |
|                            |                 |                           |                           |                    |
|                            |                 |                           |                           +---+---------------++
|                            |    Eats enough  |                           |                               |               |
|        Wander State        | <-------------- |        Hunting State      |                               |               |
|                            |                 |                           |                               |               |
|                            |                 |                           |                               |               |
|                            |                 |                           |                  +------------v----+          |
|                            |                 |                           |                  |                 |          |
|                            |                 |                           |                  | Charging attack +----------+
|                            |                 |                           |                  |                 |         ||
+-------------+--------------+                 +--------------^------------+                  +---------+-------+         ||
              |                                               |                                         |                 ||
              |                                               |                                         |                 ||
              |                                               |                                +--------v---------+       ||
              |                                               |                                |Track nearest fish|       ||
              | Low health or sundown                         |                                +------------------+       ||
              |                                               |                                                          +vv-v------------+
              |                                               |                                                          |                |
              |                                               | Sun comes up                                             |    Chasing     |
              |         +----------------------------+        |                                                          |                |
              |         |                            |        |                                                         ++-------+--------+
              |         |                            |        |                                                         |        |
              |         |                            |        |                                                         |        |
              |         |                            |        |                                                         |        |
              |         |                            |        |                                                         |  +-----v-----------+
              |         |                            |        |                                                         |  |Seek nearest fish|
              |         |      Hibernating State     |        |                                                         |  +---+--------+----+
              +-------> |                            | +------+                                                         |      |        |
                        |                            |                                                                  |      |        |
                        |                            |                                                                 +v------v-+      |
                        |                            |                                                                 |Hibernate|      |
                        |                            |                                                                 +---------+      |
                        |                            |                                                                            +-----v+
                        +----------------------------+                                                                            |Wander|
                                                                                                                                  +------+
