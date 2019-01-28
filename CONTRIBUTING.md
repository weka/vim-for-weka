What it is
==========

This repository should contain only things that are specific to Vim **and**
specific to Weka. This includes, but is not limited to:

* Configurations and adjustments for Vim plugins to work properly with the Weka
  codebase.
* Vim functions and commands that integrate Weka tools(teka) into Vim's
  features.

What it isn't
=============

This repository **should not** contain:

* Weka things that are useful for users of lesser text editors. These belong in
  teka commands, so that other Weka developers can use them. Note that category
  does not include things that integrate with Vim features even if other
  editors have them - for example code to populate Vim's quickfix list from
  Weka errors belongs here, even if Sublime has a similar feature, because a
  teka command will not be able to populate these lists so Sublime will need
  it's own implementation anyways.
* General Vim things that are useful outside Weka. These belong in their own
  plugins.
* Configuration tweaks that make Vim a nicer experience for you. These are your
  preferences - don't enforce them on all of us. This deserves it's own bullet,
  but it's usually a case of the previous bullet. No one is going to complain
  that ALE is linting actual errors that'll show up on the build server instead
  of failing earlier on things solved in the Weka fork of LDC, but if you
  change - for example - some of it's UX settings it will annoy Vimmers who are
  used to different settings and now need to figure what and how to change it
  back.
* Plugins. Don't force us to use a plugin you like, no matter how much you like
  it. Tweaks for that plugin that make it work with the Weka codebase do belong
  here, but the plugin itself should be installed separately.

Versions and dependencies
=========================

I think it's safe to assume no one here uses Vim 7.3 or older anymore, but not
everyone use the bleeding edge version, and some of use are using Neovim. Also,
not everyone are using you plugin. Try not to add things that will break Vim
for other people.

That being said - there is no need to be too strict about this. Worst thing
that can happen - other Vimmers will use an older commit until we get the
conflicts fix.

When such conflicts arise, the preferred ways to solve them are, in that order:

1. It is sometimes possible to use a more common API. If you rely on a newer,
   nicer versions of Vim functions, on or some utility functions from a plugin,
   it may be preferable to use the uglier API. It won't be as elegant, but it
   will actually work for more people. Consult Idan if you are facing trouble.
2. Sometimes it's impossible to do something without some new Vim feature or
   without the actual functionality of a plugin(rewriting huge parts of the
   plugin is not acceptable!). In these cases you should make sure that the
   code does not break existing functionality, and if it does write guards that
   will check for the requirements and prevent the code from running when they
   are not present. It won't work for everyone, but at least it won't break
   their Vim...
3. On rate occasions, detecting if the requirements are missing is impossible
   or expensive. In these cases, use a manual guard - a variable named
   `g:weka_yourFeatureName` - and prevent the feature from running unless that
   variable is set to `1`.

At any rate, document all requirements so that people know what they need to
install to make these features work.
