---
layout: post
title: "Monkey-Patching iOS with Objective-C Categories Part II: Adding Instance Properties"
tags:
- Code
status: publish
type: post
published: true

---
_Originally posted on [Carbon Five's Blog](http://blog.carbonfive.com/2012/11/27/monkey-patching-ios-with-objective-c-categories-part-ii-adding-instance-properties/)._

Have you ever wanted to introduce new functionality to base classes in the iOS SDK? 
Or just make them work a **little** differently? In order to do so, you must enter the wild and dangerous world of monkey-patching.

In this series of posts, we'll show how to monkey-patch in Objective-C through [categories][] to [add and change methods][add-methods], to add new instance variables and properties, and introduce swizzling, a technique that allows us to extend and preserve existing functionality.&nbsp;<a href="#tldr"><strong>TL;DR &raquo;</strong></a>

In the [first post](http://blog.carbonfive.com/2012/01/23/monkey-patching-ios-with-objective-c-categories-part-1-simple-extensions-and-overrides/) we showed how you can add or override methods with extensions. In this post we'll cover how to add new properties to instances.

## The Scenario : Adding a New Feature

Why would we want want to patch in a new property to our class hierarchy instead of using subclassing? 

Let's imagine we are creating an app with multiple controllers and wish to add a "touring" feature; the first time a user arrives on a screen, popup tips appear to guide them through its functionality. It would make sense to add a <code>tourSteps</code> property to our controllers, which they each set with their own unique tour.

We could add this property through subclassing <code>UIViewController</code>; introducing a <code>TouringViewController</code> for example that our controllers would then extend. But what if want the functionality of other core iOS controllers like <code>UINavigationController</code> or <code>UITableViewController</code>? You would either have to create custom subclasses for each of them (<code>TouringNavigationController</code>, <code>TouringTableViewController</code>, etc.) which your own controllers would then extend, or abandon using them and reimplement their functionality. Neither solution is appealing.

Instead, use categories to inject the new property into <code>UIViewController</code> and have it available to all descendents, whether our own or
the iOS framework. As when defining properties for regular classes, the <code>@property</code> declarative is used as shorthand to define the getters and setters of a property in the category header file.

### UIViewController+TourGuide.h
<script src="https://gist.github.com/rudyjahchan/2191625.js?file=UIViewController_TourGuide.h"></script>

The usual "next step" after defining a property is to use a <code>@syntesize</code> declarative in the implementation to create the expected getter and setter methods and back them with an appropriate instance variable. We would expect the same to work when adding a property via a category:

<script src="https://gist.github.com/rudyjahchan/2191625.js?file=UIViewController_TourGuide_BadImplementation.m"></script>

However, the above code will fail. Why?

## The Problem: No Instance Variables

From the [Objective-C Programming Language Guide - Categories and Extensions][categories]:

> Note that a category canât declare additional instance variables for the class; it includes only methods.

So the <code>@syntesize</code> cannot create a <code>\_tourSteps</code> instance variable to back the generated getter and setter. Likewise defining the instance variable in the category header file as follows would still not work:

### Non-legal Declaration of Instance Variables in Category
<script src="https://gist.github.com/rudyjahchan/2191625.js?file=UIViewController_TourGuide_BadImplementation2.m"></script>

What are our options? We clearly have to implement the getter method <code>-tourSteps</code> and setter method <code>-setTourSteps:</code> ourselves, but where will we store the actual values if not an instance variable? A <code>static</code> variable? Doing so at the class-level makes no sense as each instance needs its *own* value, and we face memory retention headaches if we create them at the method level.

We could maintain a global mapping of objects to their per-instance property values but it would be difficult to correctly manage memory for that collection and properly clean up variables when their associated instance is dealocated.

Luckily the Objective-C runtime already provides such a global mapping for us, handling the memory management issues as long as we use it properly.

## The Solution: Associated References

[Associated Reference](associated-references) are provided through a collection of Objective-C runtime functions to simulate the behavior of instance variables. Through them you can create and set associations between your class instance and objects that represent their property values. More importantly, those associations are released automatically when your objects are released.

Using associated references, our implementation of <code>-tourSteps</code> and <code>-setTourSteps:</code> is as follows:

<script src="https://gist.github.com/rudyjahchan/2191625.js?file=UIViewController_TourGuide.m"></script>

Let's walk through what is happening here.

## The "Key" to Creating Associations

The functions for getting and setting associations refer to an <code>object</code> and a <code>key</code>. The <code>object</code> value is the instance that owns the property. In our case, it is <code>self</code>. We then identify the property we will try to retrieve with the <code>key</code>. But what is the key?

Unlike most mapping systems, it is NOT a string; it's a fixed address in memory, hence the pointer in the method signature. It needs to be fixed to ensure we are always using the same key value when retrieving a specific property. A <code>static</code> variable fits this criteria perfectly. And since the address is all we care about (retrieved with the address (<code>&</code>) operator), what is in that memory address doesn't matter at all. We make it a <code>char</code> to minimize its footprint. So we define the key OUTSIDE the class as:

    static char tourStepsKey;

And later use <code>&tourStepsKeys</code> when we set or get the value.

## Respecting Property Attributes When Setting Values

The methods we create an association with is the <code>objc_setAssociatedObject</code> runtime function:

    void objc_setAssociatedObject(id object, void *key, id value, objc_AssociationPolicy policy)

We make use of it in our property setter implementation, passing in <code>self</code> and the address of <code>tourStepsKey</code> as previously discussed. The third parameter is literally the <code>value</code> we are setting the property to. Note that it is a <code>id</code> reference, meaning we cannot pass primitive values (like <code>NSInteger</code>) but only objects (like <code>NSNumber</code>). Keep this in mind when defining and implementing your own properties.

The final parameter to <code>objc_setAssociatedObject</code> is the <code>policy</code>. It clues the runtime on what to do with the values when their associated object is removed from memory, corresponding to the property attributes **strong**, **weak**, **copy**, and so on. When implementing instance properties, simply pass in the appropriate policy:

* (weak) / (assign)  <code>OBJC_ASSOCIATION_ASSIGN</code>
* (strong) / (retain)  <code>OBJC_ASSOCIATION_RETAIN</code>
* (copy) <code>OBJC_ASSOCIATION_COPY</code>
* (nonatomic,strong) <code>OBJC_ASSOCIATION_RETAIN_NONATOMIC</code>
* (nonatomic,copy) <code>OBJC_ASSOCIATION_COPY_NONATOMIC</code>

You can also remove an association using <code>objc_setAssociatedObject</code> by passing <code>nil</code> as the <code>value</code>. This works perfectly for our purposes of implementing the behavior of properties.

## Getting the Associated Values

Retrieving our property is even easier with the <code>objc_getAssociatedObject</code> runtime method:

    id objc_getAssociatedObject(id object, void *key)

Like when the value was set, we pass in <code>self</code> and the address of our property identifying key variable to the method. Note we return the value right away instead of casting it; again, as it is an <code>id</code> reference, no type will be enforced by the compiler.

## Next

So there you have it; while you can't technically have instance variables backing category defined properties, through the use of Associated References you can implement their functionality rather easily.

In the next and final post in the series, we will see how to use the technique of swizzling to accomplish something we were warned off last time; truly overriding and extending existing methods, even those core to the operation of iOS.

## <a name="tldr"></a> TL;DR

* You can add _properties_ through [categories][] but **NOT** instance variables; <code>@syntesize</code> will fail.
* Use [Associated References][associated-references] to replicate the behavior of instance variables.
* The property is identified using a fixed memory address; define a <code>static char</code> variable whose address is the identifier.
* Use the <code>objc_setAssociatedObject</code> to implement the setter, passing in <code>self</code> as the object, the address of your key variable, the value of the property and the appropriate policy.
* Use <code>objc_getAssociatedObject</code> to implement the getter.
* Check out a related bonus trick below!

## BONUS: The Exception to the Rule

There is ONE exception to the rule of categories being unable to define instance variables using <code>@synthesize</code> for properties defined in the category; when it's a [class extension][categores]. For example, the code below defines a property <code>foo</code> in an extension, which appears as an "anonymous" category with empty () paratheses:

<script src="https://gist.github.com/rudyjahchan/2191625.js?file=MyClassWithFakePrivateProperties.m"></script>

But why is this useful? Well when the extension is declared not in an header file but with immediately with the implementation it effectively provides for "private" properties. The property will not be available to other components that reference the header, but you can within the implementation and without the hassle of using associated references! We can also use this technique to have a property defined with one set of attributes in its header file (for example <code>readonly</code>) and then redefine it with a different set of attributes in extension only available to the implementation!

[categories]: http://developer.apple.com/library/ios/#documentation/cocoa/conceptual/objectivec/chapters/occategories.html
[add-methods]: http://blog.carbonfive.com/2012/01/23/monkey-patching-ios-with-objective-c-categories-part-1-simple-extensions-and-overrides/
[associated-references]: http://developer.apple.com/library/ios/#documentation/cocoa/conceptual/objectivec/chapters/ocAssociativeReferences.html
