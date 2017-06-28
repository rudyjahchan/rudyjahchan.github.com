---
layout: post
title: "Sweeter Javascript: Defining Properties to Add Syntactic Sugar"
tags:
- Code
status: publish
type: post
published: true

---
_Originally posted on [Carbon Five's Blog](http://blog.carbonfive.com/2013/02/12/sweeter-javascript-defining-properties-to-add-syntactic-sugar/)._

Syntatic sugar makes for more human-readable code and, if done
correctly, provides for more flexibility. In the world of [Node][node]
many turn to [Coffeescript][coffee-script] to add that "sweetness",
but you can also achieve it with plain old Javascript. <a href="#tldr"><strong>TL;DR &raquo;</strong></a>

## <code>Object.defineProperty</code>

It all comes down to using [<code>defineProperty</code>][object-define-property] of the
<code>Object</code> class. Introduced as part of ECMAScript 5 and
implemented in Javascript 1.8.5 - which is supported by Node and most
major browsers - it allows you to add or modify
a property on an object by not just determining its value but its
entire behaviour.

    Object.defineProperty(obj, prop, descriptor)

The magic comes in the <code>descriptor</code> parameter. You can
directly set an initial <code>value</code> that will always be returned
by anyone using the property.  You can use other attributes in the
descriptor to make the property
<code>writable</code> (allowing new values assigned),
<code>configurable</code> (permit further changes), and
<code>enumerable</code> (returned during property enumeration).

But you can go beyond the simple retrieval and assignment of value to
properties by passing *functions* as the <code>get</code> and/or <code>set</code>
attributes in the descriptor.

Let's see how we can use it to add our sugar.

## An Example: Read-only Attributes

Recently I published [nock-vcr][nock-vcr], a node module to deliver
the same functionaly of the Ruby gem [VCR][vcr] but built atop the HTTP 
mocking framework [nock][nock]. VCR use the metaphor of "cassettes"
to record the HTTP interactions, with the interactions being written
out to a file named after the name given to the cassette. If a
cassette doesn't exist at the time of recording, it will be created.  

For various reasons, we don't want to give users of the module
the ability to change the <code>name</code> of a <code>Cassette</code>
once an instance is created. This is accomplished by using
<code>Object.defineProperty</code> to explicity set the
<code>value</code>:

<script src="https://gist.github.com/rudyjahchan/4753384.js?file=cassette.js"></script>

Now when we instantiate an instance of <code>Cassette</code>, the string
passed in the construtor is returned by the <code>name</code> property.

<script src="https://gist.github.com/rudyjahchan/4753384.js?file=cassette.sh"></script>

More importantly, because we never set the <code>writable</code>
attribute in the descriptor to <code>true</code>, no one can assign 
a new value to the property:

<script src="https://gist.github.com/rudyjahchan/4753384.js?file=cassette-read-only.sh"></script>

## Now Add the Syntactic Sugar

At this point, we haven't done anything to "sweeten" the syntax. An
opportunity arises in implementing <code>exists</code>. If implemented
as a function, it would be used as follows:

	if(cassette.exists())

But wouldn't it be sweeter to do the following?

	if(cassette.exists)

In this case, we pass in a <code>get</code> function when defining
'exists' as a property. This function will be run every time the property is
referenced, ensuring it represents the current state of the cassette, but without
need of keeping tract with another attribute.

<script src="https://gist.github.com/rudyjahchan/4753384.js?file=cassette-exists.js"></script>

Now we can call <code>exists</code> without need of the parenthesis:

<script src="https://gist.github.com/rudyjahchan/4753384.js?file=cassette-exists.sh"></script>

A small, "sweet" victory.

## Another Example: Sweeter Tests

The previous example did not really gain us much; what are a couple of
parenthesis in the larger scheme of things? A more useful example of this
technique and the benefits of syntactic sugar comes in writing out a 
[chai][chai]-like test framework called <code>rooibos</code>.

Let's begin by creating an <code>Assertion</code> "class", that accepts a
value we will be running our assertions against. We will also create and
export <code>expect</code> function as the only interface into our framework and
creating these assertions.

<script src="https://gist.github.com/rudyjahchan/4753384.js?file=rooibos.js"></script>

We can add two basic assertions; <code>truthy</code> which will
assert if the value is non-falsy and <code>empty</code>, which asserts
the value is has no characters if a string, no elements if an array, and
is non-null or undefined in all other cases.

<script src="https://gist.github.com/rudyjahchan/4753384.js?file=rooibos-truthy-empty.js"></script>

At this point, we can use the framework as follows:

<script src="https://gist.github.com/rudyjahchan/4753384.js?file=rooibos-demo.sh"></script>

We can sweeten this further with <code>to</code> and <code>be</code> properties that pass through the <code>Assertion</code> instance, doing nothing but enhancing readability.

<script src="https://gist.github.com/rudyjahchan/4753384.js?file=rooibos-passthroughs.js"></script>

So finally we can write our tests with the sweetest syntax of all:

<script src="https://gist.github.com/rudyjahchan/4753384.js?file=rooibos-passthroughs.sh"></script>

## <a name="tldr"></a> tl;dr

* [<code>Object.defineProperty</code>][object-define-property] allows you add more behavior when a
property is assigned or referenced.
* By assigning a value with <code>Object.defineProperty</code> you make
it read-only.
* Assign a <code>get</code> function to a property to introduce
syntactic sugar like pass-throughs and queries for readability.

[nock]: https://github.com/flatiron/nock
[nock-vcr]: https://github.com/carbonfive/nock-vcr
[vcr]: https://github.com/vcr/vcr
[node]: http://nodejs.org
[coffee-script]: http://coffeescript.org/
[object-define-property]: https://developer.mozilla.org/en-US/docs/JavaScript/Reference/Global_Objects/Object/defineProperty
[chai]: http://chaijs.com/
