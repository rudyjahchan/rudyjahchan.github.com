--- 
layout: post
title: How to Dismantle a Shia LaBomb
tags: 
- Coding
- Fun
- mayhem
- Projects
status: publish
type: post
published: true

---
<object width="425" height="350" class="image"> <param name="movie" value="http://www.youtube.com/v/o8XanqiBnOI"> </param> <embed src="http://www.youtube.com/v/o8XanqiBnOI" type="application/x-shockwave-flash" width="425" height="350"> </embed> </object>

Above is the core of what I dub the Shia LaBomb. Notice the stylish use of crotch shots.

But the full Shia LaBouef is the above video playing as the DESKTOP BACKGROUND of its intended target MacOSX system. Yes, a terrible weapon, but these terrible times demand nothing less.

Assembling your own is easy, and I post them here for the sake of mutually assured destruction:

1.  First, collect <a href="http://www.shialabeouf.us/">images from here</a>
1.  Then, use some <a href="http://www.youtube.com/watch?v=eBGIQ7ZuuiU">long forgotten music</a>.
1.  Assemble the above with your favorite video editor into a loving montage of the man in question. I used iMovie.
  1.  Grab this <a href="http://s.sudre.free.fr/Software/SaveHollywood.html">freeware screen-saver</a> that let's you play movies.
  1.  Load the video in question.
  1.  Using Apple's Script Editor, create an application using this code:

          {% highlight applescript %}
            tell application "System Events"
              if process "ScreenSaverEngine" exists then
                tell application "ScreenSaverEngine" to quit
              else
                do shell script "/System/Library/Frameworks/ScreenSaver.framework/Resources/ScreenSaverEngine.app/Contents/MacOS/ScreenSaverEngine -background > /dev/null 2>&1 &"
              end if
            end tell
          {% endhighlight %}

  1.  You run it to turn on/off the currently selected screensaver. Run it to start the ball rolling and and voila, instant Shia LaBomb!

So what could bring me to develop such a monstrous creation? Well ...

Last night, we had a last-minute get together with <a href="http://shey.net/">Tim Shey</a>, his beautiful wife Rachel, and our friends (and leaders in the independent show producers field) <a href="http://epicfu.com/">Zadi Diaz and Steve Woolf</a>. Among the catch-up and laughs, Casey and my horrible seekrit came out.

We don't like Shia LaBouef.

Actually only I don't like him. <a href="http://caseymckinnon.com/">Casey</a> LOATHES him.

In my case, its nothing personal, and I respect he's a working actor. I just want to see him move beyond frustrated joe reacting to shit that's so much cooler than him. Not entirely his fault I realize but hey, I am pathetic enough to funnel my anger at a meaningless target.

When rumors emerged of <a href="http://io9.com/5028007/shia-the-last-man-in-2010">Shia possibly starring in the adaptation of one of our favorite comic-book series, Y: The Last Man</a>, it came with a shocking image. Probably photoshopped but who knows. For us Shia-haters, it's just painful.

I joked with Casey that one day I would play the nasty trick of setting her desktop to that image. Well, that didn't go over well, so she went for the preemptive strike.

<a href="http://www.flickr.com/photos/coderonin/2845044562/" title="Shia'ed!!! by Rudy Jahchan, on Flickr" class="image"><img src="http://farm4.static.flickr.com/3211/2845044562_1a99984e15.jpg" width="500" height="313" alt="Shia'ed!!!" /></a>

Of course you realize this meant war.

I believe in shock and awe (but don't ask me about a follow-up), so created the Shia LaBomb, and left it running on her laptop, enjoying her twittered reactions.

WARNING: It came at a terrible cost. For the rest of the day, images of Shia and how he wouldn't never gonna let me down haunted me.

But it was worth it.
