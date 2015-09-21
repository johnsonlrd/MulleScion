1852.0

### API change 

Redesigned the "convenience interface". Sorry but I just disliked the
proliferation of code, that separated **NSURL** and **NSString** by type. I used the
power of ObjC and simplified this without having to resort to degenerics ;)
In other words the` +descriptionWithTemplateURL:` method family is gone, just use
`+descriptionWithTemplateFile:` with either NSString or NSURL.

### LANGUAGE change 

I apparently goofed up the documentation in 1851 and made an incompatible change
so that **mulle-scion** choked up on its own documentation templates. Ahem. That
has been fixed, so that MulleScion now skips all scion tags, that are
immediately _followed_ by a backtick ` or a backquote \. This ought to be
harmless in my opinion, but results may vary.


1851.0

*** BIG CHANGE!!! FILTER REDESIGNED ***

I decided to convert the documentation from ASCII into markdown. For that I
needed a markdown filter. As it turns out, none of the libraries I found are
able to do incremental rendering (bummer). This meant, that the markdown filter
had to buffer all incoming strings until the endfilter was reached.
That broke a lot of stuff.

On a positive note, you can now nest filters and can tweak them a little with
optional parameters.


*** BIG CHANGE!!! ELSEFOR INSTEAD OF ELSE IN FOR-ENDFOR ***

I messed up, when I "designed" aka hacked in the {% for else endfor %} feature
it doesn't work, when there is a {% if else endif %} contained in the loop.
So else needs to be renamed to elsefor in this case.

To keep in sync with the archive version, the version nr. has been bumped to
1851.


Improved the dependencyTable generation, by ignoring syntax errors.

The documentation is now in markdown format. With some hacking effort
the builtin webserver can now show the "Results" much nicer.

Stole a CSS to make it look more nicey, nicey.

Improved the LICENSE detail.

Made it more possible to call a macro from a macro, which failed in some cases.

There is now a hidden convert feature on includes, which allows to preprocess
the data. convert > parse > print > filter


1848.11

*** This can break archived templates on iOS, regenerate them ***

* mulle-scion has now a -z option to output compiled templates. While testing
I found out, that when I use NSKeyedArchiver it's actually slower than parsing
plain text and uses more space - even compressed.

Compile plaintext * 100
-rw-r--r--  1 nat  _lpoperator  198016 Oct  9 17:00 big.scion

real	0m8.528s

Compile unkeyed * 100
-rw-r--r--  1 nat  wheel  75983 Oct  9 17:25 /tmp/unkeyed.scionz
real	0m8.680s

Compile keyed * 100
-rw-r--r--  1 nat  wheel  750347 Oct  9 17:25 /tmp/keyed.scionz
real	0m25.497s

If you are on iOS it's most likely better to not use archives and caching!

Fix erroneous trace output, which was always happening.

Fix bug, where "for i in nil" would iterate once

Fix bug, where MulleScionNull was passed as invocation argument


1848.10

*** This can break currently working templates, that contain unnoticed 
    syntax errors! ***

* the parser doesn't allow garbage inside mulle-scion tags anymore. It
  used to parse {{ x = #<%$/&> }} because everything after "x " was
  ignored, but it was just too confusing in real life use.
 
* simplified expansion of function functionality a bit. 
  added NSStringFromRange to builtin-functions

* added some NSURL methods for opening templates, which is more convenient on
iOS

* made built-in function in principle expandable to support user-written
functions


1848.9

* added a podspec


1848.8

* allow # comments within {% %}

* added log command for debugging

* mulle-scion now builds into /usr/local/bin in Release setting

* the demo webserver root is now /tmp/MulleScionDox

* fixed requires dox

* made requires a single line command, like include or extends, just because
it "felt right"

* remove some extraneous debug output and runtime warnings

* new scheme "Show Documentation in Browser"

* updated documentation a bit regarding multi-line commands


v1848.7

* outsourced NSObject+MulleGraphviz because I need it in other code
too and the dependency on MulleScion was annoying.

* fixed some bad code in commandline tool, that reads the property list


v1848.6

* add __ARGV__ parsage to mulle-scion. Now you can use mulle-scion as an awk 
replacement in other shell scripts, if you so desire.


v1848.5

* bunch of fixes. Added an example how to write a non-plist datasource, in this
case using CoreData.

* added a requires keyword for dynamic loading of bundles from within a scion
script (experimental)


v1848.4

* renamed to MulleScion, because now it's more than just a template engine, it's
also somewhat useful as a little standalone Obj-C interpreter. Also 
MulleScionTemplates was just too long.

* The MulleScionConvenience has been renamed to just MulleScion.

* There is now some rudimentary tracing support available. Just going to become
better over time.

* {{ }} can now be placed inside {% %} which makes templates with a lot of logic
and little output that much more managable.

* used google-toolbox-code for htmlEscapedString, which now adds some Apache2 Licensing
terms to this project. Or say #define NO_APACHE_LICENSE and get the old crufty
functionality back.

* the repository on github will be only pushed to for "releases" the continous
development is going to happen on Mulle kybernetiK.

<blockquote>mulle:  http://www.mulle-kybernetik.com/software/git/MulleScionTemplates/<br>
github: https://github.com/mulle-nat/MulleScionTemplates/
</blockquote>


v1848.3  !!**massive changes**!!

* your compiled scionz files are incompatible now. Throw them away
and rebuild your caches

* you used to be able to have random trash after valid scion code, which was nice
for documentation. That doesn't work anymore in most cases

* you can now write multiline scripts, but some keywords need still to be 
enclosed as singles in {% %} like macro, block, endblock, extends and maybe
some others

* there are the beginnings of a test suite, check out the tests folder. there is
a simple shellscript that runs the tests

* lots of smaller fixes, whose content one might glean from the git comments


v1848.2

* your scionz files are incompatible now. Throw them away
and rebuild the caches