---
layout: post
title: 'Getting "Test"-y in iOS Apps: Test-Driven Development and Automated Deployment'
tags:
- Code
status: publish
type: post
published: true

---
_Originally posted on [Carbon Five's Blog](http://blog.carbonfive.com/2011/07/19/ios-apps-test-driven-development-and-automated-deployment/)._

Recently, Jonah and I have been exploring test-driven development and automated deployment on the iOS platform. As we were both attending <a href="http://www.iphonedevcamp.org/">iOSDevCamp 2011</a>, we decided to give a lightning talk summarizing our discoveries and to generate excitement within others in the community to start their project on the right foot by testing right from the start. While it wasn't recorded, here is some of the ground we covered in the brief time we had.

<div style="width:595px" id="__ss_8615702"><iframe src="http://www.slideshare.net/slideshow/embed_code/8615702" width="595" height="497" frameborder="0" marginwidth="0" marginheight="0" scrolling="no"></iframe> <div style="padding:5px 0 12px"> View more <a href="http://www.slideshare.net/" target="_blank">presentations</a> from <a href="http://www.slideshare.net/rudyjahchan" target="_blank">rudyjahchan</a> </div> </div>


<a href="#tldr">tl;dr - Too Long; Didn't Read &raquo;</a>

<strong>Download:</strong> <a href='http://blog.carbonfive.com/2011/07/19/ios-apps-test-driven-development-and-automated-deployment/iosdevcamp2011-testdrivendev-2/' rel='attachment wp-att-4421'>.ppt</a> | <a href='http://blog.carbonfive.com/2011/07/19/ios-apps-test-driven-development-and-automated-deployment/iosdevcamp2011-testdrivendev/' rel='attachment wp-att-4420'>.pdf</a>

<h2>Unit Testing</h2>

After briefly reviewing why we test first (you are doing that, aren't you?) we started with how to unit-test the behavior of classes in Objective-C. To Apple's credit, they've bundled a unit-testing framework and the tools to use it in XCode; SenTestingKit. It follows the xUnit style of writing a series of tests with assertions, with an optional setup and teardown that can be executed before and after each test.

<script src="https://gist.github.com/1090887.js?file=MyCounterTest.m"></script>

SenTestingKit works but is by no means our favorite, having issues with readability, mocking, and running from the command-line. Luckily, there are already a number of great tools to address these issues.

<a href="http://code.google.com/p/hamcrest/wiki/TutorialObjectiveC">OCHamcrest</a> is the Objective-C port of the popular matching library <a href="http://code.google.com/p/hamcrest/">Hamcrest</a>. Simply including the framework in your project gives you many useful matchers to allow you to write with more readability:

<script src="https://gist.github.com/1090887.js?file=MyCounterHamcrestTest.m"></script>

Likewise, adding the <a href="http://www.mulle-kybernetik.com/software/OCMock/">OCMock</a> framework provides a wealth of mocking functionality including stubbing of methods, verifying execution of expected methods, partial mocking allowing passthrough to real instances, and even the ability to swap in new implementations for methods.

<script src="https://gist.github.com/1090887.js?file=MyCounterOCMockTest.m"></script>

Finally, the <a href="http://code.google.com/p/google-toolbox-for-mac/wiki/iPhoneUnitTesting">Google Toolbox for Mac</a> and <a href="http://gabriel.github.com/gh-unit/">GHUnit</a> are excellent test runners, extending functionality including the capability to run headlessly.

<h2>Behavior Driven Development</h2>

For a few years now the testing community has been moving towards a more BDD or "spec" style of test-writing, allowing for better structure, more readability, and less repetition of code. The classic example of this is the Ruby based RSpec framework:

<script src="https://gist.github.com/1090887.js?file=my_counter_spec.rb"></script>

For those interested more about writing tests in this style, the <a href="http://pragprog.com/book/achbd/the-rspec-book">RSpec Book</a> is an excellent introduction and reference. While its examples are language specific, its principles can be applied to similar frameworks.

<a href="https://github.com/pivotal/cedar">Cedar</a> from Pivotal Labs, takes full advantage of the new Objective-C blocks to mimic RSpec's structure:

<script src="https://gist.github.com/1090887.js?file=MyCounterSpec.m"></script>

Interestingly, instead of plugging into SenTestingKit, Cedar runs the specs as an app, allowing it to be compiled for the simulator or hardware device. Additionally, Cedar has baked in support to provide colorized output when run from the command-line; look into the accompanying project Rakefile to see how it is done.

A more recent entry into the game is <a href="http://www.kiwi-lib.info/">Kiwi</a>. Kiwi is structurally similar to Cedar but provides much cleaner assertions:

<script src="https://gist.github.com/1090887.js?file=MyCounterKiwiSpec.m"></script>

Using Kiwi is as simple as including its source in your project. Since it sits atop of SenTestingKit, you can include running all tests as part of your XCode build process. Our brief usage of Kiwi has shown it has some issues running UI components but it does hold promise.

<h2>Integration Testing</h2>

More recently our explorations have taken us into looking for an integration and acceptance testing framework to include in our process. While we could write test or specs to do end-to-end testing, it's best to separate the concerns; in fact, we should start by writing integration tests that focus on the user experience!

Again, using our experiences with web development in Ruby, we looked for something similar to <a href="http://cukes.info/">Cucumber</a>. Its use of plain text and the tools to parse it are an ideal way to specify what a system is expected to do:

<script src="https://gist.github.com/1090887.js?file=google_apps_account.feature"></script>

Is there a way to write Cucumber specs for iOS? There is! In fact there are two; <a href="https://github.com/unboxed/icuke">iCuke</a> and <a href="https://github.com/moredip/Frank">Frank</a>.

<script src="https://gist.github.com/1090887.js?file=iCuke.feature"></script>

<script src="https://gist.github.com/1090887.js?file=Frank.feature"></script>

However, there are problems with both projects. iCuke launches the application in the simulator and automatically launches an HTTP interface to interact with the screen. The project also hasn't seen a commit for over a year, though a number of forks seem to be actively developed. Frank, the other Cucumber based library, is actively maintained and follows a similar strategy of embedding an HTTP server. 

A Frank Cucumber driver then communicates with the server to fire-off user events. Our hesitation to use it comes in the amount of setup it requires with care needed to ensure you don't include it in a release build of the application. And for both iCuke and Frank, the idea of running an entire server feels incredibly heavy for what we want to do. Is there another option?

Strangely enough, a possible candidate was released into the wild the day before our talk. <a href="https://github.com/square/KIF">KIF</a>, short for Keep It Functional, from <a href="https://squareup.com/">Square</a> aims to minimize the layers and load in order to test like a user. Each step in a scenario focuses on a single user action, targeting an interface component through the accessibility attributes. Well documented, and with the ability to capture screenshots (and video come the release of Lion), KIF has a lot of potential and we look forward to exploring it in the future.

<h2>Continuous Integration and Automated Deployment</h2>

We close the loop on the full agile process through continuous integration and automated deployment, ensuring code stability and getting it out in the hands of testers. We've previously documented how to do so in other posts, including how to build XCode projects and run tests from the command-line, as well as rolling your own Over The Air distribution. Jonah provided <a href="http://blog.carbonfive.com/2011/05/04/automated-ad-hoc-builds-using-xcode-4/">a full script</a> that carries out all these steps from start to finish.

Using Jonah's script and following the lead of Cedar, I started creating a set of <a href="http://rake.rubyforge.org/">Rake</a> tasks to carry out each step, from building to headlessly running specs to signing - all from the command-line (it can be found <a href="https://gist.github.com/1017153">here</a>). I also decided to use <a href="https://testflightapp.com/">TestFlight</a> to distribute and target builds; it provides a intuitive interface for our pre-release users to access the latest builds and easy to use tools for developers to manage those releases. Even better, their upload API allowed us to write a Rake task to deploy right from the command-line.

<h2>What's Missing</h2>

While we're excited to see all these great tools emerging for iOS development, there is still a LOT to be done to get us anywhere near the ease of writing tests that the Ruby world currently enjoys. While the nested spec-style of code alleviates duplication, you can still end up with large blocks of code that look like this:

<script src="https://gist.github.com/1093622.js?file=BadCode.m"></script>

This doesn't really tell us anything about what we are trying to do! It would be far more pleasant to have a library like <a href="https://github.com/thoughtbot/factory_girl">Factory Girl</a> and simply write:

<script src="https://gist.github.com/1093622.js?file=GoodCode.m"></script>

Similarly, while CoreData provides a way to update schemas from one release to another, there is no proper migration path that can move forward and back to ensure compatibility. Add to that time-based testing like <a href="https://github.com/jtrupiano/timecop">Timecop</a> or automatic testing via <a href="https://github.com/guard/guard">Guard</a> and you have a slew of great projects that we could work on.

<h2>In Conclusion</h2>

As you can see, there are a number of solid options to test and deploy your iOS projects. Personally, I'm looking forward to bringing KIF into my current stack of Cedar, OCHamcrest, and OCMock. More importantly, there is plenty of room for new tools to help these processes. I plan on releasing a gem of the Rake tasks we've whipped up, and hope to write an interpreter of gherkin (the language cucumber features are written in) to KIF. What would you like to see?

<h2><a name="tldr"></a>tl;dr</h2>

<ul>
<li>Test-driven principles still apply in iOS development.</li>
<li>While out-of-the-box unit testing in XCode comes in SenTestingKit, it is somewhat limited. Use <a href="http://code.google.com/p/hamcrest/wiki/TutorialObjectiveC">OCHamcrest</a>, <a href="http://www.mulle-kybernetik.com/software/OCMock/">OCMock</a>, <a href="http://code.google.com/p/google-toolbox-for-mac/wiki/iPhoneUnitTesting">GTM</a>, and <a href="http://gabriel.github.com/gh-unit/">GHUnit</a> to expand functionality</li>
<li>Alternatively, for a more BDD approach, use <a href="https://github.com/pivotal/cedar">Cedar</a> or the newer <a href="http://www.kiwi-lib.info/">Kiwi</a>.</li>
<li>Cucumber driven integration tests have been implemented with iCuke and Frank,while the recently released KIF provides for doing the same in Object-C.</li>
<li>Command line <a href="http://blog.carbonfive.com/2011/05/04/automated-ad-hoc-builds-using-xcode-4/">builds</a>, <a href="http://blog.carbonfive.com/2011/04/06/running-xcode-4-unit-tests-from-the-command-line/">running tests</a>, and <a href="http://blog.carbonfive.com/2011/05/04/automated-ad-hoc-builds-using-xcode-4/">Over The Air distribution</a> are all possible and documented. We've done it as a <a href="http://blog.carbonfive.com/2011/05/04/automated-ad-hoc-builds-using-xcode-4/">bash script</a>, or <a href="https://gist.github.com/1017153">rake tasks</a>.</li>
<li><a href="https://testflightapp.com/">TestFlight</a> provides not only a great way for your pre-release users to get your builds, but an API to automate sending it to them.</li>
<li>There is much work to be done; factories, fixtures, time manipulation, ... why not dive in?</li>
</ul>
