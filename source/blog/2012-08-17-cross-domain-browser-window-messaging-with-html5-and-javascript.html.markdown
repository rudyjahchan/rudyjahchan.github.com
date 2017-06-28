---
layout: post
title: "Cross-Domain Browser Window Messaging with HTML5 and Javascript"
tags:
- Code
status: publish
type: post
published: true

---
_Originally posted on [Carbon Five's Blog](http://blog.carbonfive.com/2012/08/17/cross-domain-browser-window-messaging-with-html5-and-javascript/)._

We've previously covered how [JSONP and CORS][json-cors] allow thick-client web applications to circumvent the same origin policy preventing requests to servers in different domains. However, cross-domain interaction is also blocked on the client-side; browser windows loaded with different sites have limited access to each other in order to prevent security breaches. Sadly, this also prevents any communication between thick-clients of web applications that do know of and trust each other ... unless they use the [`Window#postMessage`][window-postmessage] method introduced in HTML5. <a href="#tldr"><strong>TL;DR &raquo;</strong></a>

## A Problem

I recently faced the following dilemma on a project. We were working on two applications with feature-rich thick clients that were on different domains. It was required that navigating to a path on one application would automatically launch a child window opened to a page in the other application, or reuse the same child window if it already existed. This functionality could easily be fulfilled by calling the <code>window.open</code> method with a targeted window name, except for an additional criteria; if the child window was already open we did _NOT_ want it to reload the page as this would trigger other events on our server!

Why was this a problem? Because calling [`Window#postMessage`][window-postmessage] with a URL _WILL_ load it, even if the child window exists and is already displaying that URL. You can prevent this by passing <code>null</code> as the URL parameter. But now if the child window did not exist it will be created with no content!

"No problem," I thought. "I'll just detect that situation by checking the child window <code>location</code> property or its <code>document.URL</code>; if they were undefined, I could call <code>window.open</code> again, but this time pass in the real URL to load."

Unfortunately this was where I ran into the cross-domain access issue. Accessing those properties would always log errors and return <code>undefined</code> regardless of if the child window was properly loaded or empty because the second application was on separate domain. Likewise, the child window could not talk back to the parent window through the <code>window.opener</code> property.

How could I query the other window to see if it was already loaded? I found the answer in <code>Window#postMessage</code>.

## Sending data through <code>postMessage()</code>

Introduced a few years ago in Firefox and now supported by all major browsers, <code>postMessage</code> allows documents to communicate with each other through their containing <code>window</code> instances. While it doesn't provide full access to another window's model, it gives us a _framework_ to establish communication.

The window sending the event obviously need a reference to the receiving window. We have a variety of ways to do this:

<script src="https://gist.github.com/3376283.js?file=01.getting.windows.js"> </script>

The last example is what I will be using in my solution; more on that later.

With the reference, the sending window can now call <code>postMessage</code> on the receiver, passing the data they want to send and the domain that is permitted to receive it.

<script src="https://gist.github.com/3376283.js?file=02.postMessage.js"> </script>

You can specify the wild-card `'*'` character as the second parameter to mean any domain, but this is frowned upon as an opening for security breaches.

## Handling <code>'message'</code> Events

In order to receive the events, the code in the other window must register a handler for <code>'message'</code> events on its <code>window</code>:

<script src="https://gist.github.com/3376283.js?file=03.listening.js"> </script>

While not strictly enforced, the first thing a handler should do to lessen potential security issues is verify the domain of the message sender with the <code>Event#origin</code> property:

<script src="https://gist.github.com/3376283.js?file=04.check.origin.js"> </script>

The handler is then able to access the sent data through the <code>Event#data</code> property.

<script src="https://gist.github.com/3376283.js?file=05.accessing.data.js"> </script>

It also receives a reference to the sending window in the <code>Event#source</code> property. It can use this to post messages back:

<script src="https://gist.github.com/3376283.js?file=06.posting.back.js"> </script>

Of course, the original sender must be listening for its own <code>'message'</code> events in order to receive them!

[David Walsh][david-walsh] provides an [excellent basic example][window-postmessage-example] illustrating all of this. I highly recommend you check it out.

## A Solution

Back to my original problem of only loading a child window if it was newly created, but preventing a reload otherwise. I decided to use <code>window#postMessage</code> as the basis of a "keep-alive" system, pinging the child and reloading only if no response was received.

You can see the implementation below of the opening code that would be run in the parent window:

<script src="https://gist.github.com/3376283.js?file=07.parent.js"> </script>

As before, I would call <code>window.open</code> with a <code>null</code> URL which will either return an existing window without reloading its contents or create an empty one. I then use <code>postMessage</code> to ping the child window in the other domain and wait a second for a response.

In the client-side code of the second application, I would setup a listener for <code>'message'</code> events on the window.

<script src="https://gist.github.com/3376283.js?file=08.child.js"> </script>

If the child window is already loaded with the second application, the listener will handle any pings from the parent window and send the correct response; the parent window would then take no further action. But in the case of a new, empty child window the listener would not even exist; the correct response would never be sent back and so the parent window would eventually call <code>window.open</code> again, this time passing in the full URL. Thus we got the desired behavior!

I could also clean up code by using a library like jQuery to normalize listening for the message event across browsers:

<script src="https://gist.github.com/3376283.js?file=09.jQuery.window.event.listening.js"> </script>

## Conclusion

HTML5's [`Window#postMessage`][window-postmessage] provides a simple framework for thick-clients of different domains to communicate on the client-side with each other, without having to round-trip through the servers. As long as we verify messages are sent to and originate from trusted domains we can safely exchange data and trigger functionality. In fact, you could open your thick clients to new interactions that goes beyond the traditional browser functionality by establishing a protocol with other applications.

## <a name="tldr"></a> tl;dr

* Send messages to other windows [`Window#postMessage`][window-postmessage]; be sure to specify the domain
* Receive messages by listening for <code>'message'</code> events on the <code>window</code>
* Verify the sender of the message by checking the domain in the <code>Event#origin</code> property.
* Read the message sent in the <code>Event#data</code> property.
* A reference to the window that sent the message is found in the <code>Event#source</code> property.

[window-postmessage]: http://www.w3.org/TR/html5/comms.html#dom-window-postmessage-2
[window-postmessage-example]: http://davidwalsh.name/window-postmessage
[david-walsh]: http://davidwalsh.name/
[json-cors]: http://blog.carbonfive.com/2012/02/27/supporting-cross-domain-ajax-in-rails-using-jsonp-and-cors/
