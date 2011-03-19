# Minify

Minify is a rails gem to allow for easy handling of js/css minification and
caching. I wrote it with the following limitations in mind:

* It must not rely on generating files on production.
  * Heroku uses a read only file system (as well as other cloud providers).
  * Don't want to cause any delays on first hit (like the built in Rails mechanisms).
  * Don't want to install any extra programs on production servers.
* I love the idea of a config/assets.yml that stores a list of all js and css
  files used. This comes from the
  [Jammit](http://documentcloud.github.com/jammit/) library which provided lots
  of inspiration.
* I want to use the YUI compressor for now (this can be abstracted later).
* I want to include rake and cap tasks for inclusion in deploy scripts.
* I want to have no extra steps at all when working in the dev environment.
* I use [Slim](http://slim-lang.com/) for my templating and
  [Less](http://lesscss.org/) for css work.
  * Development should use the client side less.js
  * Production should rely on pre-deployment creation of compiled, compressed
    and compacted code.

## Usage

### Assets.yml

Just like Jammit you need to create an assets.yml file. For now this file only
taks your list of javascript and stylesheet files. You can not glob here. You
have to list all of the files. Here is an example file:

    stylesheets:
      robotpuffin:
        - reset.css
        - robotpuffin.less
    javascripts:
      robotpuffin:
        - jquery.js
        - rails.js

In this example (for a small simple site) I have two css files. One is Eric
Meyer's [reset.css](http://meyerweb.com/eric/tools/css/reset/) and the other is
a less css file for my robotpuffin site. I then have two javascript files,
jquery.js and the rails.js jquery adapter. I put both css and js files into a
group named `robotpuffin`. All of these files are listed relative to
`public/stylesheets` and `public/javascripts`.

### Folder Layout

Minify puts it's final collected files into `public/stylesheets/minify` and
`public/javascripts/minify`. When you use less files they get compiled as css
files into `public/stylesheets/minify/lessc`. After YUI compression files get
places into `public/stylesheets/minify/yui` and `public/javascripts/minify/yui`.

In the above example, after running the rake tasks we would have the following
files:

    public/
      stylesheets/
        |- reset.css           - Original raw reset.css
        |- robotpuffin.less    - Original raw robotpuffin.less
        minify/
          |- robotpuffin.css   - Group file containing both reset.css and robotpuffin.less
          lessc/
            |- robotpuffin.css - Compiled robotpuffin.less
          yui/
            |- reset.css       - YUI Compressed reset.css
            |- robotpuffin.css - YUI Compressed robotpuffin.css
      javascripts/
        |- jquery.js           - Original raw jquery.js
        |- rails.js            - Original raw rails.js
        minify/
          |- robotpuffin.js    - Group file containing both jquery.js and rails.js
          yui/
            |- jquery.js       - YUI Compressed jquery.js
            |- rails.js        - YUI Compressed rails.js

#### Git Ignoring Intermediate Files

If you want to keep the intermediate files out of git just add this to
`.gitignore`:

    public/stylesheets/minify/lessc
    public/stylesheets/minify/yui
    public/javascripts/minify/yui

You can add these lines to .gitignore by running:

    rake minify:gitignore

### Compiling and Compressing Files

To have minify compile, compress and collect your assets just run:

    rake minify:build

To remove all of these files just run:

    rake minify:clean

### Rails Helpers

To include these files in your rails layouts you can use the following two
helpers:

    minify_stylesheets :robotpuffin
    minify_javascripts :robotpuffin

If you do want to include both css and javascript with the same group names you
can just use the simple version:

    minify :robotpuffin

In production all these do is link to the group files

## Required Gems

Minify does not require these gems in case you don't want them to exist on the
server. It will use what it can and ignore the rest. For example, if you don't
have the command line version of lessc installed or the javascript less file,
it just won't use these features.

### Installing YUI

In order to make Minify use YUI to compress both js and css files just include
the gem in your development group. This will make sure that it exists for your
rake tasks but will not be installed on the server (where it isn't needed).

In your Gemfile add:

    gem 'yui-compressor', :group => :development

or

    group :development do
        gem 'yui-compressor'
    end

### Installing lesscss

In order to use less in development modes you need the less.js file available.
Head over to the [lesscss website](http://lesscss.org/) to download `less.js`
and place it in `public/javascripts/less.js`. As long as this file exists
Minify will directly link to less files and include this javascript file
automatically when in development mode.

In order to use less files in production and testing you need to compile the
less files to their css counterparts. In order to do this you need access to
the lessc binary.

I use [Homebrew](http://mxcl.github.com/homebrew/) on my mac
to install opensource software. You can install the following things without
homebrew of course but I would highly recommend looking into this method.

1. Install [node.js](http://nodejs.org/)

    `brew install node`

2. Install [npm](http://npmjs.org/)

    `curl http://npmjs.org/install.sh | sh`

3. Install [less](http://lesscss.org/)

    `npm install less`

## Problems

The biggest problem so far is that this method requires a new commit on
production releases. I'm still trying to think of ways around this but honestly
I'm not going to worry about it for now since it's a nessecary evil for
managing some of the other features.

## Copyright
 
Copyright (c) 2011 Christopher Giroir. See LICENSE.txt for further details.
