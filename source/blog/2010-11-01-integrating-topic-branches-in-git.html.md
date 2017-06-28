---
layout: post
title: Integrating Topic Branches in Git
tags:
- Code
status: publish
type: post
published: true

---
_Originally posted on [Carbon Five's Blog](http://blog.carbonfive.com/2010/11/01/integrating-topic-branches-in-git/)._

A key feature of <a href="http://git-scm.com/">Git</a> is how easy it is to create topic branches to separate and organize work.  This power leads to a codebase with many more branches than you would typically see in other SCMs, like SVN.  However, without an appropriate and consistent branch-and-merge strategy, your team will wind up with a confusing and unhelpful history.

How do we avoid this mess? And what do we actually want our history to look like?

<h2>A Tale of Two Timelines</h2>
No one sets out to create a messy history. Most of us want our main branches to be a straight line of commits.

<img class="alignnone size-full wp-image-1378" title="fast-forward" src="http://blog.carbonfive.com/wp-content/uploads/2010/12/fast-forward14.png" alt="" width="374" height="77" />

This clear, linear history absent of any merge commits is highly readable.  Git's default behavior when merging a branch that has not diverged from the mergee is to perform a fast-forward, resulting in this type of history.

There is a major shortcoming; it doesn't reflect the use of topic branches!  You can't see the workflow that was used and you can't rollback the work from a single topic branch without a bit of investigation.

So lately we've been aiming to have our histories look like the following:

<img class="alignnone size-full wp-image-1386" title="multiple-no-fast-forward" src="http://blog.carbonfive.com/wp-content/uploads/2010/12/multiple-no-fast-forward13.png" alt="" width="496" height="221" />

The main branch (master in this case) consists of nothing (besides the initial commit) but merge commits from topic branches. This is just as clear as the above linear timeline, but now:
<ol>
	<li>the history reflects the fact that we used topic branches for our work</li>
	<li>a naming convention for topic branches helps identify the work done</li>
	<li>it's easy to revert the work of a branch; just revert the single merge commit!</li>
</ol>

So how do we achieve this model?

<h2>The Workflow</h2>

We follow a few key steps around branching and merging in order to create this style of history.

<h3>Branch Around Stories</h3>

As part of the agile process, we write stories to describe one feature, bug fix, or chore to be delivered. When we begin work on a story we create a topic branch named after it.

We usually use <a href="http://pivotaltracker.com">Pivotal Tracker</a> to manage our stories, but no matter what system we can easily apply our naming convention:

<code>[<em>feature|bug|chore</em>]-[<em>id</em>]-[<em>abbreviated_story_title_separated_by_underscores</em>]</code>

Here are some examples:
<table>
<thead>
<tr>
<th>Story</th>
<th>Branch</th>
</tr>
</thead>
<tbody>
<tr>
<td>Feature #12345: Threaded post comments</td>
<td>feature-12345-threaded_post_comments</td>
</tr>
<tr>
<td>Bug #23456: Can create 2 groups with the same name</td>
<td>bug-23456-prevent_duplicate_groups</td>
</tr>
<tr>
<td>Chore #34567: Setup CI environment</td>
<td>chore-34567-setup_ci_environment</td>
</tr>
</tbody>
</table>

Assuming you are on the master branch, creating a new branch would look like this:

```
git checkout -b feature-12345-threaded_post_comments
```

It also makes sense to push this topic branch to the remote repository for backup or remote access by you and others.

```
git push origin feature-12345-threaded_post_comments
```

<h3>Rebase When Ready to Deliver</h3>
When a feature is complete, we rebase our work on the latest version of our main branch (master in this case):

```
git rebase master
```

This step is what gives our history model the appearance of each topic branch being created sequentially.

You may be concerned about rebasing when working in a team environment as your next push would have to be forced, rewriting the history. But remember, we only do this step when we've <em>finished</em> the story i.e. we no longer plan any further changes to it.
<h3>Merge Without Fast Forwarding</h3>
As discussed, Git's default merge behavior (when the 2 branches have not diverged or after a rebase of one on another) is to perform a fast forward. Instead of accepting the default behavior we use merge's <code>--no-ff</code> flag:

```
git checkout master
git merge --no-ff feature-12345-threaded_post_comments
```

This prevents the default behavior and generates a merge commit, achieving the goal of our model!

<img class="alignnone size-full wp-image-1381" title="no-fast-forward" src="http://blog.carbonfive.com/wp-content/uploads/2010/12/no-fast-forward23.png" alt="" width="435" height="86" />
<h3>A Note on Squashing</h3>
Some developers prefer to squash all their work in a topic branch into a single commit before they merge.  If you're doing this, then we don't see much advantage to not fast-fowarding because every topic branch in your history would be a single commit!  Instead accept the default behavior and fast foward but at least make sure the story id is in the commit message for reference.
<h3>Be Good, Cleanup after Yourself!</h3>
Always remember to delete local topic branches after integrating them into another branch.

```
git branch -d feature-12345-threaded_post_comments
```

If you've pushed the topic branch to a remote, delete it there as well to avoid confusing other developers about its status.

```
git push origin :feature-12345-threaded_post_comments
```

<h2>Conclusion</h2>
Implementing this non-fast-forward workflow requires a bit of discipline from all of us after using the default behavior for some time. But we do enjoy the results, particularly a history that preserves the existence of topic branches.

We would love to hear your opinions and how you manage branching in your own work.
