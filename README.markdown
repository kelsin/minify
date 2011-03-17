# Minify

Minify is a rails gem to allow for easy handling of js/css minification and
caching. I wrote it with the following limitations in mind:

* It must not rely on generating files on production.
  * Heroku uses a read only file system (as well as other cloud providers).
  * Don't want to cause any delays on first hit (like the built in Rails mechanisms).
  * Don't want to install any java and other programs on the server
* I love the idea of a config/assets.yml that stores a list of all js and css files
  used. This comes from the jammit library which provided lots of inspiration.
* I want to use the YUI compressor for now (this can be abstracted later).
* I want to include rake and cap tasks for inclusion in deploy scripts.
* I want to have no extra steps at all when working in the dev environment.
* I use slim for my templating and lesscss for css work.
  * Development should use the client side less.js
  * Production should compile less scripts

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
I'm not going to worrya bout it for now since it's a nessecary evil for
managing some of the other features.

## Copyright
 
Copyright (c) 2011 Christopher Giroir. See LICENSE.txt for further details.
