---
title: Tweaking this Site
date: 2017-01-03 22:08 UTC
tags:
---
As my [beloved wife pointed out](http://caseymckinnon.com), a New Year
makes me return to this site to restructure it.  Funny thing was this
year I had no interest in a redesign.  The old one still suited me and I
really need to focus on WHY I have a site; not to maintain one but to
WRITE.  I had to break the cycle of not achieving the latter goal due to
being distracted by the former.  Plus I love my [faux terminal
header][faux-terminal].

BUT...

In returning to this site I discovered that [Middleman][middleman], the
generator I use, had long [upgraded][middleman-upgraded].  A lot of my
site no longer worked.  Additionally, while I was using
[Bootstrap][bootstrap] and [jQuery][jQuery], both still great
frameworks, professionally I have tried to stop using them.  I decided
it was time to kill two birds with one stone.

Here then is how I changed the site.

## Moved to a Webpack Asset Pipeline

This was by far the most difficult change, driven by the Middleman
team's decision to [abandon a Rails like
pipeline][middleman-abandon-pipeline].  This was fine by me.  In my work
with [Carbon Five][carbon-five] I usually advocate using
[Webpack][webpack] to generate front-end assets.  Luckily [Ross
Kaffenberger][rossta] had a great guide to using [Webpack
with Middleman][webpack-with-middleman].

The only problem I ran into was that running the Middleman local server
(`middleman server`) did not use the Webpack content!  I had initially
had Webpack deliver the content to a `build` directory, but the local
server never made use of that!  In the end (and what I think Ross and
the Middleman team intended) I had Webpack build into the Middleman
source directory, letting Middleman take care of copying the output to
the final distribution folder.

## Leaving Bootstrap and jQuery

As mentioned, I also wanted to move off of Bootstrap and jQuery.  Again
there is nothing wrong with both of those frameworks.  It's just that I
have become conciously aware of the bloat we introduce to our usually
simple sites when we add these really powerful tools, especially when we
only use a tiny bit of their functionality.

In my case, Bootstrap and jQuery was primarily being used for the basic navigation
bar and menu functionality.  At the time they were introduced this made
complete sense.  Getting consistent behavior of those features across
web browsers was a difficult task and these libraries had done all the
work for me.

However, both CSS and JavaScript have come a long way.  With
the introduction of [flexbox][flexbox] and the long available
[media-queries][media-queries] to change styling and layout based on screen size I
was able to rapidly recreate the navigation bar.
In the past I would have used jQuery's
[`toggleClass`][jquery-toggle-class] functionality to make the menu
appear and disappear.  Except the ability to easily toggle classes is
baked into the HTML DOM API; we simply find our element, ask for it's
[`classList`][class-list] and call the `toggle` function with
the class in question. Quick searches on the net got me simple code to
recreate the other small Bootstrap styles I was using namely [circle
cropped images][circle-images] and [responsive
embeds][responsive-embeds].

### Conclusion

You can see all of this functionality and more by reading the code of
this [on Github][site-code].

There you have it.  A day's worth of research and work, and my site's on
the latest (for now) stack.  And with it I get out my first blog post in
a while.  Here's to another New Year and to again getting into a writing
groove.

Cheers!

[faux-terminal]: http://blog.carbonfive.com/2015/01/07/vintage-terminal-effect-in-css3/
[carbon-five]: https://www.carbonfive.com
[middleman-upgraded]: https://middlemanapp.com/basics/upgrade-v4/
[middleman-abandon-pipeline]: https://middlemanapp.com/advanced/asset_pipeline/
[middleman]: https://middlemanapp.com/
[bootstrap]: http://getbootstrap.com/
[jquery]: https://jquery.com/
[webpack]: https://webpack.github.io/
[webpack-with-middleman]: https://rossta.net/blog/using-webpack-with-middleman.html
[rossta]: https://twitter.com/rossta
[media-queries]: https://developer.mozilla.org/en-US/docs/Web/CSS/Media_Queries/Using_media_queries
[flexbox]: https://css-tricks.com/snippets/css/a-guide-to-flexbox/
[jquery-toggle-class]:http://api.jquery.com/toggleclass/
[site-code]: https://github.com/rudyjahchan/rudyjahchan.github.com
[class-list]: https://developer.mozilla.org/en-US/docs/Web/API/Element/classList
[circle-images]: https://www.abeautifulsite.net/how-to-make-rounded-images-with-css
[responsive-embeds]: https://css-tricks.com/NetMag/FluidWidthVideo/Article-FluidWidthVideo.php
