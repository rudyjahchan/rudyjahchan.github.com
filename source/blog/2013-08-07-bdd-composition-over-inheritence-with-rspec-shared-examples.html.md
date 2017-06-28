---
layout: post
title: "BDD Composition over Inheritance with RSpec Shared Examples"
tags:
- Code
status: publish
type: post
published: true

---
_Originally posted on [Carbon Five's Blog](http://blog.carbonfive.com/2013/08/07/bdd-composition-over-inheritance-with-rspec-shared-examples/)._

The technique of [composition over inheritience][composition-over-inheritence] is more than simply encapsulating objects into larger entities; its really about defining models as being made up of _resuable behaviors_. It makes sense then in _Behavaior_ Driven Design we apply the technique not just when writing the implementations of our models but also when creating the specifications themselves. Instead of many files repeating the same functionality in large blocks of spec code, we end up with specs that look like:

<script src="https://gist.github.com/rudyjahchan/5923483.js?file=01_image_spec.rb"></script>

This is pleasantly tighter, DRYer, and tighter code. So how did we "compose" this spec and behaviors? <!--more-->&nbsp;<a href="#tldr"><strong>TL;DR &raquo;</strong></a>

## Sample Domain

Imagine we are developing a media management application. Within this system, an **assignment** can be created for an **image** into multiple **galleries**. This is simple enough to model.

<script src="https://gist.github.com/rudyjahchan/5923483.js?file=02_simple_models.rb"></script>

Additionally, each of these models can be marked with _metadata_, which comes in three flavors:

* **references** to one or more **creators** and **places**.
* **tags**, the traditional list of strings, stored in a [Postgres array][postgres-array] and can be searched on.
* a **hash-bag** of simple string key-value pairs stored as a [Postgres <code>hstore</code>][postgres-hstore] and are also searchable.

There is one additonal important detail; not all types of metadata would be available on every type of model:

* Images can have all types of metadata; references, tags, and the hash-bag.
* Galleries can only have tags and the hash-bag.
* Assignments can only have the hash-bag.

## Implementing Images

Given the above requirements, it is apparent that at some point composing with modules will come into play and we could leap to that point. But in practice, we would be following our story-based agile process, and so may end up fully developing the <code>Image</code> model first.

We start by writing out a spec, using [Factory-Girl][] to handle instance generation.

<script src="https://gist.github.com/rudyjahchan/5923483.js?file=03_image_w_everything_spec.rb"></script>

And then implement the model to pass the spec. Note the custom code below to handle the Postgres array and hstore based tags and hashbag:

<script src="https://gist.github.com/rudyjahchan/5923483.js?file=04_image_w_everything.rb"></script>

## Refactor into Shared Examples

With working specs and implementation in hand for all of our metadata, we can move on to adding the same but different functionality to the remaining models. And as good devs, we HAVE to start with specs that define the behavior. We could simply use the ugly technique of "copy-paste" the spec code of <code>Image</code> into the specs of the <code>Assignment</code> and <code>Gallery</code>. But this begs the wrath of The Maintenance Gods and their acolytes, your fellow devs!

So we won't, as we additionally follow the principle of DRY; [Don't Repeat Yourself][dry]. This is where [RSpec shared examples][shared-examples] come into play. A shared example is a collection of context and examples you can declare with a name:

<script src="https://gist.github.com/rudyjahchan/5923483.js?file=05_shared_example_example.rb"></script>
	
The shared example can then be invoked within the context of your specs with <code>include_examples</code> or (my preference) <code>it_behaves_like</code>:

<script src="https://gist.github.com/rudyjahchan/5923483.js?file=06_shared_example_use_example.rb"></script>
	
You can even pass in parameters into a shared example:

<script src="https://gist.github.com/rudyjahchan/5923483.js?file=07_shared_example_parameters_example.rb"></script>

Using this feature we can refactor the behavior of each of the three different types of metadata into their own shared examples. Looking at the code in the original specs, we need to change two things to better support testing against any model; not calling the methods on the <code>Image</code> class and using the appropriate factory when instantiating instances to test against. We do this by passing the model we are testing and the factory to use as parameters:

<script src="https://gist.github.com/rudyjahchan/5923483.js?file=08_meta_data_examples.rb"></script>

Now we can rewrite the spec for <code>Image</code> to use these shared examples:

<script src="https://gist.github.com/rudyjahchan/5923483.js?file=09_image_spec_w_examples.rb"></script>

Even better we can now easily write the specs of the other two models:

<script src="https://gist.github.com/rudyjahchan/5923483.js?file=10_other_model_specs_with_examples.rb"></script>

We have effectively "composed" our specs from a set of behaviors! We also have not said anything about HOW this functionality will be achieved, maintaining the BDD mantra of testing _behavior_ NOT _implementation_.

## Compose with Modules (where Inheritence will fail us)

Now how to get these new specs to pass? Again the most ugly way would be to simply copy and paste but remember; those gods and devs sure are wrathful!  

In all seriousness, this is where code reuse becomes important and also illustrates where composition will trump inheritence. Yes, the desired functionality can be achieved with inheritence. We could introduce a parent <code>MetadataBase</code> class that all our models inherit from. Or decide that <code>Image</code> descends from <code>Gallery</code> which descends from <code>Assignment</code> with each level adding the additional metadata implementation needed their parent does not provide. But neither correctly represents our domain; the first example exposes functionality on <code>Assignment</code> and <code>Gallery</code> that really shouldn't be there while adding class bloat, and the other solution is just plain wrong!

The better solution is to encapsulate the behavior of each specific kind of metadata into seperate modules:

<script src="https://gist.github.com/rudyjahchan/5923483.js?file=11_metadata_in_modules.rb"></script>

We can then compose our models by including the modules of behavior they actually have.

<script src="https://gist.github.com/rudyjahchan/5923483.js?file=12_models_w_modules.rb"></script>

This is extremely elegant on so many levels. It adheres to the [single responsibility principle][single-responsibility-principle] with each module solely focused around the logic of the metadata it represents. It DRYs up the implementation. And the resulting code practically reads like the domain model we outlined at the top of this post:

* An image includes references, tags, and a hash bag.
* A gallery includes tags and a hash bag.
* An assignment include just a hash bag.

## Getting Cleaner

Our specs could stand to be DRYed up even further. The repetitive passing in of the class we are testing and its factory now standout like a sore thumb after all our efforts. What to do?

By default the <code>subject</code> of a spec of a class is an instance of that class created via a call to <code>new</code>. Given that, we create a shared context that derives the model and factory from the current subject.

<script src="https://gist.github.com/rudyjahchan/5923483.js?file=13_subject_class.rb"></script>

We can then include the shared context within each shared example and drop the need to have them passed in.

<script src="https://gist.github.com/rudyjahchan/5923483.js?file=14_final_meta_data_examples.rb"></script>

Finally, our specs drop repeatedly passing the same set of arguments to the shared examples, reading cleaner than ever:

<script src="https://gist.github.com/rudyjahchan/5923483.js?file=15_final_model_specs.rb"></script>

## Final Thoughts

There are further "optimizations" we could do to the code above. For example, we could also write specs for each module itself, testing all paths within it, and only compose the model specs from "coarser" variations that just verify the general functionality; this approach would speed up running the entire test suite. But these and other exercises are left for the reader to pursue.

Most important is to realize that composition over inheritence can be elegantly implemented in our codebase from the very start, resulting in well-designed and easily maintainable domain, specs and implementation.

## <a name="tldr"></a> tl;dr

* Use composition over inheritance when the latter does not correctly reflect the domain model.
* Use RSpec's <code>shared_example</code> to define the behaviors that are shared between objects.
* Compose your specs from those shared examples by invoking <code>it_behaves_like</code>.
* Implement the behaviors as <code>Module</code>s that you will <code>include</code> in your implementation.

[composition-over-inheritence]: http://en.wikipedia.org/wiki/Composition_over_inheritance "Composition over inheritence"
[postgres-array]: http://reefpoints.dockyard.com/ruby/2012/06/18/postgres_ext-adding-postgres-data-types-to-active-record.html
[postgres-hstore]: https://github.com/engageis/activerecord-postgres-hstore
[shared-examples]: https://www.relishapp.com/rspec/rspec-core/v/2-14/docs/example-groups/shared-examples
[factory-girl]: https://github.com/thoughtbot/factory_girl/blob/master/GETTING_STARTED.md
[dry]: http://en.wikipedia.org/wiki/Don't_repeat_yourself
[single-responsibility-principle]: http://en.wikipedia.org/wiki/Single_responsibility_principle
