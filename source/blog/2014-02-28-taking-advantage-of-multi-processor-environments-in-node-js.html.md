---
layout: post
title: "Taking Advantage of Multi-Processor Environments in Node.js"
tags:
- Code
status: publish
type: post
published: true

---
_Originally posted on [Carbon Five's Blog](http://blog.carbonfive.com/2014/02/28/taking-advantage-of-multi-processor-environments-in-node-js/)._

[Node.js][nodejs] has more than proven itself capable of handling
multiple events concurrently such as server connections, and all without
exposing us to the complexities of threading. Still, this locks
our apps down to a single process with a single thread of execution
consuming a single event queue. On a machine with a single processor, this
is no big loss; there is only one active process in any case.

But we live in a multi-core world now and out of the box Node does not take advantage of this,
though it certainly has the ability to. [tldr &raquo;](#tldr)

## The "Problem"

To illustrate why this may be a problem for some applications, let's
turn to a multi-player game system we recently released.

[vimtronner][vimtronner] is a vim trainer built atop Node.js and
[Socket.io][socketio] that allows multiple players
to remotely connect to a server and compete against each other. More
importantly, it can host many games at the same time. Each game uses
`setInterval` to update its state inform all its players of
changes every 100ms.

Except that is not entirely true.

As my colleague [Erin][erin] explained
in his post on the [JavaScript Event Loop][javascript-event-loop-explained]
there is only a SINGLE queue of events that our single-threaded process
works its way through. The `setTimeout` and `setInterval` function don't actually
RUN their callbacks at the specified time intervals. They simply ENQUEUE them
at that time, an important distinction.

When there are no events in the queue ahead of it, the callback is executed
more or less immediately, so there does not seem to be a problem. This
is effectively the situation when only a single game is running on a server.

But imagine if each game of vimtronner takes 10ms to update and broadcast its state
(which would be generous). When two games are running, it will take 20ms to process
through both games, leaving 80ms before the next updates are re-queued. At three games
this becomes 30ms, at four 40, and so on.

At 10 games we hit our problem point. The time taken to update all
the games matches the time interval before new update callbacks are
events. If just one more game is started, the time before each game next gets updated
will be DELAYED by 10ms from the expected 100ms. This worsens as more games
are added so a server running 20 games will take 200ms to update all the games before
it is even able to process the next set of update events. ALL games are slowed down by half!

This also does not even take into account the other events that are queued in the
system from players joining and leaving games, asking for game lists, or
even responding to simple controls from socket events.

Games don't actually interact with one another so it makes no sense
at all that they should block each other. Ideally each game should
have its own event loop and queue.  Additionally, we want to
minimize the impact taken handling socket events. And on a multi-core
box dedicated to running just the server, we are wasting the processing
power that will allow us to fulfill those needs.

So how can we maximize multi-processor environments to
parallelize tasks? Node's [about page][nodejs_about] directly supplies
the answer:

> You can start new processes via [`child_process.fork()`][child-process-fork] these other
> processes will be scheduled in parallel. For load balancing incoming
> connections across multiple processes use the [`cluster`][cluster-fork] module.

Let's take a look at how and when to use these two modules.

## Cluster to parallelize the SAME Flow of Execution

We'll begin with the [`cluster`][cluster] module. Introduced around version 0.8,
its stated purpose is to handle heavy workload by launching a cluster of
Node processes. Additionally, these processes can share the same server
ports, making it ideal for web applications.

The use of this module is very easy, revolving around determining if the
current Node process is the "master" who can launch "workers" with a
call to [`cluster.fork()`][cluster-fork], or one of many "workers" who are all expected to carry
out the same work. This is illustrated in the code below.

<script src="https://gist.github.com/rudyjahchan/9275029.js"></script>

Let's write a program that calls the above named
`cluster_example.coffee`:

<script src="https://gist.github.com/rudyjahchan/9275043.js"></script>

I can then run it on my quad-core MacBook Pro and get the following output:

<script src="https://gist.github.com/rudyjahchan/9276567.js"></script>

Reading through the lines we can see 8 workers were launched. But more
importantly notice the repeated output surrounding the master and worker
declaration lines. The "Before the fork" and "After the fork" came from
the launch code itself, but more interesting is the repeated "Launching
cluster". This was from the MAIN example code not the launcher. It tells us that
when we fork a cluster, we are running through the SAME program from the
BEGINNING.

This is what makes the `cluster` module ideal for parallelization of the
SAME work across many Node processes. The code will go through the same initialization.
You could introduce variation aside from the
differing "master" vs "worker" behavior into the mix if you felt like it, but this
would go against its intended purpose.

You can see this in the common example of load balancing connections on a
Node server instance:

<script src="https://gist.github.com/rudyjahchan/9276981.js"></script>

Each worker process will start up a server and listen to the same port,
a further feature of the `cluster` module.

## Child Process a DIFFERENT Flow of Execution

Reading [how `cluster` works][how-cluster-works], you will discover it
sits atop the other module we are interested in:
[`child_process`][child_process].

The module supplies a number of methods to coordinate the launching of processes
and communication between them. While the [`exec`][child-process-exec] and 
[`spawn`][child-process-spawn] methods
allow calling external commands, of interest to us is again the 
[`fork`][child-process-fork]
function. When we call it, we pass the full path to a Node module we wish to run,
as seen in this code below:

<script src="https://gist.github.com/rudyjahchan/9276642.js"></script>

As before let's write some example program that calls this `launch` code:

<script src="https://gist.github.com/rudyjahchan/9276661.js"></script>

Running this results in the following output:

<script src="https://gist.github.com/rudyjahchan/9276683.js"></script>

Unlike the `cluster` example, we DON'T see the repetition of the "Launching"
message, or the "Before" and "After" messages surrounding the fork.
Child processes launched this way BEGIN with the referenced module itself. We
don't go through any of the same code as the parent process, unless
explicitly required by the called module. Basically it's the way to go when we want to run
processes independently with different initialization and concerns.

This does not mean there is no way for the parent and child processes to
coordinate with each other. There are standard mechanisms like piped
streams or external messaging queues. But forked Node processes have an
additional avenue; a built in Inter-Process Communication channel.
Simple values and objects can be passed through this channel via the `send` functions
on either the [`child_process`][child-process-send] instance or the 
[`process` module][process] for either the parent or child process respectively.
These objects arrive as `'message'` events on the other side.

This is illustrated in the "processified" version of the
[vimtronner][vimtronner] game we released a month ago. Instead of the
server managing games directly like it use to, it forks a child process
for each game, sends configuration into it and waits for messages back.

<script src="https://gist.github.com/rudyjahchan/9276835.js"></script>

Likewise, a new 'game_process' module now wraps a game instance,
responding to events from players sent from the server process and
sending back game events.

<script src="https://gist.github.com/rudyjahchan/9276808.js"></script>

A final note. In addition to sending an object, the `send` allows the
transmission of handles like TCP servers and sockets between process. It
is through this mechanism that the `cluster` functionality was created.

## The Downside

There are some issues to keep in mind when taking advantage of the
forking functionality. While Node processes are considered "lightweight"
they do [consume resources when starting up][child_process_cost]:

> These child Nodes are still whole new instances of V8. Assume at least
> 30ms startup and 10mb memory for each new Node. That is, you cannot
> create many thousands of them.

Likewise, we while we can certainly run more things in parallel we are
still ultimately CPU bound. A multi-core processor can only run as many
processes as threads of execution it can throw at.

Finally, when clustering servers, we
must be aware that though the cluster can handle connections to the same
endpoint, each worker is only aware of the connection it handles. So if
two connections come in that are suppose to interact with other but are
handled by different workers, the interaction can never take place
without the support of other systems like Redis message queues or shared
storage.

## tl;dr

* Use either the [`child_process`][child_process] or the [`cluster`][cluster] modules to take
  advantage of multi-processer environments.
* Use `cluster` when you want to parallelize the *SAME* flow of execution
  and server listening.
* Use `child_process` when you want *DIFFERENT* flows of execution
  working together.
* Take advantage of built in [Inter-Process Communication][ipc] to pass
  objects between the processes.

[child_process]: http://nodejs.org/api/child_process.html
[cluster]: http://nodejs.org/api/cluster.html
[child_process_cost]: http://nodejs.org/api/child_process.html#child_process_child_process_fork_modulepath_args_options
[ipc]: http://nodejs.org/api/child_process.html#child_process_child_process_fork_modulepath_args_options
[nodejs]: http://nodejs.org
[nodejs_about]: http://nodejs.org/about/
[socketio]: http://socket.io
[vimtronner]: http://carbonfive.github.io/vimtronner
[javascript-event-loop-explained]: http://blog.carbonfive.com/2013/10/27/the-javascript-event-loop-explained/
[erin]: https://github.com/laser
[how-cluster-works]: http://nodejs.org/about/
[child-process-spawn]: http://nodejs.org/api/child_process.html#child_process_child_process_spawn_command_args_options
[child-process-exec]: http://nodejs.org/api/child_process.html#child_process_child_process_exec_command_options_callback
[child-process-fork]: http://nodejs.org/api/child_process.html#child_process_child_process_fork_modulepath_args_options
[cluster-fork]: http://nodejs.org/api/cluster.html#cluster_cluster_fork_env
[child-process-send]: http://nodejs.org/api/child_process.html#child_process_child_send_message_sendhandle
[process]: http://nodejs.org/api/process.html
