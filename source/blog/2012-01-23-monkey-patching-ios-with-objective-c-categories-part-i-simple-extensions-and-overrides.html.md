---
layout: post
title: "Monkey-Patching iOS with Objective-C Categories Part I: Simple Extensions and Overrides"
tags:
- Code
status: publish
type: post
published: true

---
_Originally posted on [Carbon Five's Blog](http://blog.carbonfive.com/2012/01/23/monkey-patching-ios-with-objective-c-categories-part-1-simple-extensions-and-overrides/)._

Have you ever wanted to introduce new functionality to base classes in the iOS SDK? Or just make them work a **little bit** differently? In order to do so, you must enter the wild and dangerous world of monkey-patching.

Monkey-patching is extending or modifying the behavior of code at runtime **without** changing its original source code. You can monkey-patch any code, it doesn't matter whether it's your own code or not. This is distinctly different than traditional sub-classing because you are not creating a new class, instead, you are reopening an existing class and changing its behavior.

Monkey-patching is possible in Objective-C by using [categories](http://developer.apple.com/library/ios/#documentation/cocoa/conceptual/objectivec/chapters/occategories.html). In fact, the definition of a category practically matches that of monkey-patching:

<code>"A category allows you to add methods to an existing classâeven to one for which you do not have the source."</code>


In this series of posts, we'll use categories to add and change methods, to add new instance variables and properties, and introduce swizzling, a technique that allows us to extend and preserve existing functionality.<a href="#tldr"><strong>TL;DR &raquo;</strong></a>

## Category Basics

To modify an existing class specify the category in both its interface and implementation definitions:

#### Interface Definition

<script src="https://gist.github.com/1660134.js?file=AClassACategoryImplementation.h"></script>

#### Implementation

<script src="https://gist.github.com/1660134.js?file=AClassACategoryImplementation.m"></script>

## Adding Simple Methods

The most basic usage of categories is to add a new method to an existing class.

Suppose in our application we want to output dates relative to the current time, e.g., "13 minutes ago", "4 hours ago", "just now", etc. Traditional object-oriented solutions would have us introducing a new class that either extends <code>NSDate</code> (e.g., creating a <code>RelativeDescriptionDate</code> subclass with a <code>timeAgoInWords</code> instance method) or is a standalone helper/utility class (e.g., <code>[NSDateHelper timeAgoInWordsFromDate:myDate]</code>).

But with categories, we can reopen the <code>NSDate</code> class and simply add a new instance method:

#### NSDate+Formatting.h

<script src="https://gist.github.com/1660134.js?file=NSDateFormatting.h"></script>

#### NSDate+Formatting.m

<script src="https://gist.github.com/1660134.js?file=NSDateFormatting.m"></script>

Now **every** <code>NSDate</code> object will have the new method available to it. The following code:

<script src="https://gist.github.com/1660134.js?file=UsingNSDateFormatting.m"></script>

Will print out the following on the console:

<script src="https://gist.github.com/1660134.js?file=gistfile1.sh"></script>

## The Dangers of Simply Overriding Methods

We can take this a step further and instead of adding new behavior we'll override existing behavior. Continuing with our example, what if we wanted the default description of a <code>NSDate</code> object to include the time ago in words? We could simply do the following:

<script src="https://gist.github.com/1660134.js?file=NSDateFormatting2.m"></script>

However, this is **strongly discouraged** for two reasons.

1. Other frameworks may rely on the expected behavior of the original method. We now have to go through the trouble of re-implementing that behavior, in addition to the new functionality we wanted to introduce, or risk strange side effects and possibly even crashing out.
2. If multiple categories implement the same method, the last one loaded wins! The load order is consistent within an application, but it's arbitrary, out of our hands, and fragile. For all we know, our implementation could itself be overwritten by an internal framework category!

Because of these reasons, this blunt approach to overriding methods should only be used for the simplest of cases. Later in this series, we'll explore how swizzling allows us to override a method while preserving all implementations.

## Including Your Monkey-Patches

Categories are not automatically "picked up" in a project. Any code that relies on the behavior will need to <code>#import</code> the necessary header files:

<script src="https://gist.github.com/1660134.js?file=EntryCell.m"></script>

However, including the same set of headers over and over again is redundant. We should first create a single header file that imports all of our most frequently used categories:

<script src="https://gist.github.com/1660134.js?file=Extensions.h"></script>

We can then import this single header file into a prefix header that is added to all source files. XCode projects often have a <code>.pch</code> file in the Supporting Files group for this very purpose.

<script src="https://gist.github.com/1660134.js?file=pc.h"></script>

## Next Up

While adding and overriding classes is straightforward, there is one very big caveat when using Categories; you **cannot add new instance variables** to a class. We'll take a look at working around this limitation in the next post.

## <a name="tldr"></a> tl;dr

* Use Objective-C categories to add functionality to existing classes without subclassing.
* Avoid simple overrides with categories as it can cause problems with other frameworks.
* Use prefix headers to easily import your extensions.
