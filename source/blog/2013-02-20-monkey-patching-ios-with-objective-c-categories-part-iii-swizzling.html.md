---
layout: post
title: "Monkey-Patching iOS with Objective-C Categories Part III: Swizzling"
tags:
- Code
status: publish
type: post
published: true

---
_Originally posted on [Carbon Five's Blog](http://blog.carbonfive.com/2013/02/20/monkey-patching-ios-with-objective-c-categories-part-iii-swizzling/)._

Have you ever wanted to introduce new functionality to base classes in the iOS SDK?
Or just make them work a **little** differently? In order to do so, you must enter the wild and dangerous world of monkey-patching.

In this series of posts, we'll show how to monkey-patch in Objective-C through [categories][] to [add and change methods][add-methods], to add new instance variables and properties, and introduce swizzling, a technique that allows us to extend and preserve existing functionality. <a href="#tldr"><strong>TL;DR &raquo;</strong></a>

In the [first post](http://blog.carbonfive.com/2012/01/23/monkey-patching-ios-with-objective-c-categories-part-1-simple-extensions-and-overrides/) we showed how you can add or override methods with extensions. The [second post](http://blog.carbonfive.com/2012/11/27/monkey-patching-ios-with-objective-c-categories-part-ii-adding-instance-properties/) focused on getting around restrictions on creating instance variables when adding properties to the classes being modified. This third and final post covers the technique of swizzling to override existing methods while preserving their behaviour.

## The Problem with Simply Overriding

Back in the original post of this series we discussed that while categories certainly allowed us to bluntly override existing methods of any class in the iOS SDK this was *strongly* discouraged for two reasons:

1. Other frameworks, both in the SDK or third-party, rely on the expected behavior of the original method. We would either have to re-implement that behavior in addition to the new functionality we wanted to introduce, or suffer side effects or more major errors due to its abscence.
2. If multiple categories override the same method only the last one loaded wins out as load order is non-deterministic; its possible even the original method will remain unaffected.

Ideally we need a way to have the new method handle calls to the original mathod, but preserve the original method so as to be able to invoke it when needed, much like the Ruby on Rails' [`alias_method_chain`][alias_method_chain]. Which is exactly what the **swizzling** technique provides.

## The Solution: Swizzling

So far I've been incorrectly referring to the "methods" of a class. But in Objective-C, when you write the following:

	[self presentViewController:mailController animated:YES completion:nil];

you are not actually invoking the <code>presentViewController:animated:completion:</code> _method_ but are instead _sending_ a <code>presentViewController:animated:completion:</code> _message_! How an object handles that message is determined at run-time by looking for a method under the message identifier or as it is commonly known as the selector. Normally this is the signature the method was declared under but it _can_ be changed at run-time!

Swizzling is simply exchanging the implementation of two of a class' methods so that when a message is sent using the original selector of one it actually goes to the other. In general, whether for monkey-patching or other scenarios, this is accomplished by using a number of Objective-C Runtime functions:

<script src="https://gist.github.com/rudyjahchan/2191796.js?file=SwizzleExample.m"></script>

Walking through the above code:

1. First we build selectors (the <code>SEL</code> variables) to identify the methods we are swizzling; in this case <code>firstMethod</code> and <code>secondMethod</code>.
2. References to the methods the selectors point to (represented by the <code>Method</code> data type) are then retrieved.
3. We first attempt to add the implementation of the second method under the selector of the first method. We do this in case the first method doesn't truly exist, which is sometimes a possibility.
4. If the method was added successfully we need SOMETHING under the selector of the second method, so we simply replace it with the first method's (empty) implementation.
5. If we failed to add the method, the first method already exists, so we can simply exchange their implementations.

Now, for the purposes of "monkey-patching", we rarely want to exchange two _existing_ methods. Instead we introduce a new method and then swizzle it with the original. Any calls to the original method will now be directed to the new implementation while the original implementation can be invoked under the name of the new method!

Let's look at...

## An Example

Going back to the last post's scenario of extending <code>UIViewController</code> with tour-guide functionality, suppose we want the tour guide information is to appear the first time a view is displayed to a user. The ideal place to have this happen is as part of the <code>viewWillAppear:</code> call all controllers receive. Remember, we _could_ spend time adding a sub-class for every controller variation we will use, but that could lead to unnecessary code bloat. But since <code>viewWillAppear:</code> is critical to the UI life-cycle, we can't simply replace it. Hence, we need to swizzle it!

As a best practice when we swizzle a method, it's with a method with the _same signature_ and a _similar but unique_ name. In our case, we'll be creating <code>tourGuideWillAppear</code>:

<script src="https://gist.github.com/rudyjahchan/2191796.js?file=UIViewController_TourGuide_Override.m">
</script>

Note the call to <code>tourGuideWillAppear</code> within its own implementation. You may be asking yourself "Isn't that going to result in an infinite recursive loop?"

But at what you have to remember is that at the point the method is invoked the swizzling will have already taken place. That seemingly recursive call will actually go to the original <code>viewWillAppear:</code>. So remember, _to invoke the original method implmentation, call it with the new method's name_.

## Swizzle on Load

Of course, we still have to at some point perform the swizzle. The first instinct would be to toss it into the <code>init</code> method of a class, but this is incorrect because:

1. We are not creating a class, but a category that will be mixed into a class whose <code>init</code> you probably don't want to override and
2. Even if that was possible, it's something you only want to do _once_ per _class_, and not in the per _instance_ constructor!

Luckily, when the Objective-C Runtime loads a category, it invokes a class-level <code>load</code> method. This is the perfect opportunity to perform the swizzle. We also wrap it with a <code>dispatch_once</code> block call to ensure it only happens the one time:

<script src="https://gist.github.com/rudyjahchan/2191796.js?file=SwizzleUIVIewController.m"></script>

And with that our swizzle is complete; when the framework calls <code>viewWillAppear:</code> on any controller it will pass through our <code>tourGuideWillAppear:</code>, triggering our custom tour-guide functionality. We can apply this same technique to extend any class method whether called by the framework or us directly, injecting new behavior while preserving any critical functionality.

We have achieved true monkey-patching!

## DRYing it Up

Our example has us replacing one method in one class but already it makes for a lot of code. Imagine having to repeat that multiple times across many categories. Let us DRY it up by introducing, in an elegantly meta way, a swizzling _category_ on the base <code>NSObject</code>:

<script src="https://gist.github.com/rudyjahchan/2191796.js?file=NSObject_Swizzle.h"></script>

<script src="https://gist.github.com/rudyjahchan/2191796.js?file=NSObject_Swizzle.m"></script>

Now in the <code>+load</code> of any category we simply call <code>swizzleInstanceSelector</code> on the category it<code>self</code> with the selectors of the methods we are swizzling. Here's the final <code>UIViewController+TourGuide</code> category implementation to illustrate that and all the other monkey-patching techniques we have learned in this series:

<script src="https://gist.github.com/rudyjahchan/2191796.js?file=UIViewController_TourGuide.m"></script>

## <a name="tldr"></a> TL;DR

* Use swizzling to preserve the original method behavior instead of simply overriding to avoid side-effects.
* Swizzling is simply the exchange of the identifiers of two methods so they point to each other's implementations.
* After swizzling you invoke the original method's implementation but calling the new implementations identifier.
* Swizzle in the <code>+load</code> method of your category.

[categories]: http://developer.apple.com/library/ios/#documentation/cocoa/conceptual/objectivec/chapters/occategories.html
[alias_method_chain]: http://api.rubyonrails.org/classes/Module.html#method-i-alias_method_chain
[add-methods]: http://blog.carbonfive.com/2012/01/23/monkey-patching-ios-with-objective-c-categories-part-1-simple-extensions-and-overrides/
[associated-references]: http://developer.apple.com/library/ios/#documentation/cocoa/conceptual/objectivec/chapters/ocAssociativeReferences.html
