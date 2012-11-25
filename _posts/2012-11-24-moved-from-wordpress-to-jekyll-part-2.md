---
layout: post
title: Moved from Wordpress to Jekyll Part 2
tags:
- Code
status: publish
type: post
published: true
---

Well so much for [Jekyll][] encouraging me to [blog
more](/2012/08/14/moved-from-wordpress-to-jekyll-part-1/)! But it has
been a busy year since I got my site redesign up. Namely, my short film
[D.N.E.](http://www.facebook.com/DNEDoNotErase) won [BEST SCI-FI
SHORT](http://dailydragon.dragoncon.org/contests-awards/film-festival-award-winners/)
 at [Dragon\*Con](http://dragoncon.org/), I got my
U.S. Permanent residency, and, oh yeah, [I got
married](http://www.flickr.com/photos/caseymckinnon/sets/72157632044476389/).

But excuses aside! Let us delve into the technical details of my moving
to Jekyll. Or if you want, [skip ahead](#tldr)!

## Migrating my old Posts

Jekyll's documentation provides [two ways to migrate posts from
Wordpress][migrate-wordpress].
The first method was unfortunately a non-starter; the blog was
being hosted on a shared server instance, which severely restricted my
ability to install gems.

Instead, I went with generating an export file, functionality available
in any Wordpress install, and running the "wordpressdotcom" migrator. This
worked for the most part ... Except for a bunch of bad character
encodings in the posts!

Particularly line breaks, quotations, and other
common characters were coming out all wrong. So wrong
that Jekyll could not even start up properly! Using various
[sed](http://ubuntuforums.org/showthread.php?t=1486493)
and
[PERL](http://hints.macworld.com/article.php?story=20001206164827794)
commands I managed to clean up most files.

Finally, as Google had already indexed my site, in order to ensure that
search results did not lead to dead-links, I needed to maintain the paths
of posts. This was done simply enough in the <code>config.yml</code>:

<script src="https://gist.github.com/4142545.js?file=config.yml">
</script>

## Stylishly Bootstrapping

Next up was laying out the site both structurally and design-wise. After
many years of playing the CSS reset, redefine, and tweaking game, I was
getting frustrated with having to establish on all the basic styles of
a site over and over again, none of which turned out particularly well;
you just have to take a look at [Galacticast's](http://galacticast.com)
for proof.

Which is why
[Bootstrap](http://twitter.github.com/bootstrap/) to developers like me.
Yes, there have been many styling frameworks that provide grid layouts
and other components. But Bootstrap goes beyond by establishing a
decent, pleasant style. 

Now keep in mind, I didn't avoid all the hard work. I still had to go
through the "tweak" step, adding site specific styling behavior.
Sometimes this was simply a matter of using the "appropriate" class to
get the behavior I wanted, like declaring the <code>&lt;section /&gt;</code>
containing the content of posts a <code>hero-unit</code> to get the
larger, readable font. Hackish I know, but it works.

But some behavior required a lot of labour. Particularly, while Bootstrap provides
[responsive
functionality](http://twitter.github.com/bootstrap/scaffolding.html#responsive), 
I spent a lot of time recreating the 
transforming navigation bar I had seen on other sites. Still, I can
definitively say this would have been much harder without Bootstrap.

## Responsive Video

Another responsive effect I wanted was to scale video to fill the width
of the main column across any device. As many of you
know, video has been a big part of my web-life, so showcasing on any
platform was very important. Luckily, better people than me have [already
solved this
problem](http://webdesignerwall.com/tutorials/css-elastic-videos).

I added the following to my site CSS:

<script
src="https://gist.github.com/4142545.js?file=responsive-video.css"> </script>

Then all I have to do for any video embed is ensure it's placed within a
<code>div</code> tag with a <code>video</code> style class. Loverly.

## Flying without Plugins and Databases

A big part of Wordpress' appeal was the built-in commenting and the
ability to extend functionality with plugins like
[Jetpack](http://wordpress.org/extend/plugins/jetpack/). The
flat-files Jekyll generates can't actually DO anything on the server
side; can't store anything, can't process form responses, etc.
Commenting is easily provided with [Disqus][] or [Facebook][]; I chose
the former as I didn't want to favor any particular social network.

For my contact form I went with [Simpleform](http://getsimpleform.com)
which delivers exactly what its name promises. You signup with the email
you want form data to be sent to, and you will receive  a token which 
you then pass back in the <code>action</code> path you submit the form to.
And that's it! Any fields you place in your HTML form are captured with
no further configuration. For example, here is my form:

<script
src="https://gist.github.com/4142545.js?file=contact_form.html"> </script>

As for other functionality like sharing plugins, and auto-formatting?
Well, the other benefit of moving to Jekyll hosted on [Github][] was that
alot of that stuff became difficult, if not impossible. Which made me
realize that I really didn't need it in the first place. The goal,
after all, was simplification.

## Feeding the Feeds

Finally, as feeds are not automatically provided by Jekyll, I had to
generate my own. Plenty of examples exist in the repos of other Jekyll
based sites, including the
[original](https://github.com/mojombo/mojombo.github.com). Here is mine for RSS:

<script src="https://gist.github.com/4142545.js?file=rss.xml"> </script>

For Atom:

<script src="https://gist.github.com/4142545.js?file=atom.xml"> </script>

Additionally the site map for search engines:

<script
src="https://gist.github.com/4142545.js?file=sitemap.xml"> </script>

Note in all cases the need to set <code>layout: nil</code> in the YAML
front-matter. Otherwise, it would be wrapping them in the default layout
of the site, which would produce invalid XML.

## Next?

Well there you have it, some of the small tips and tricks I used in
moving to Jekyll from my Wordpress install. What will I do next? I may
try to re-introduce tags or categories to my posts. But in the meantime
I am happy with what I have and look forward to get into the blogging
groove.

<a name="tldr"> </a>
## TL;DR

* There are many options to [migrate Wordpress data][migrate-wordpress]
  but be prepared to fix the data.
* [Bootstrap][] provides a great foundation for responsive site design.
* Use [Disqus][] for commenting and [simpleform][] for contact forms.
* Remember to generate your own feeds; sample templates can be found in
  multiple repos or [here](https://gist.github.com/4142545)

  [simpleform]: http://getsimpleform.com
  [Bootstrap]: http://twitter.github.com/bootstrap/
  [Jekyll]: http://jekyllrb.com
  [Wordpress]: http://wordpress.org
  [Github]: http://github.com
  [Disqus]: http://disqus.com
  [Facebook]: http://developers.facebook.com/docs/reference/plugins/comments/
  [migrate-wordpress]: https://github.com/mojombo/jekyll/wiki/blog-migrations
