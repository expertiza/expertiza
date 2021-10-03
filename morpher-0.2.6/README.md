morpher
=======

[![Build Status](https://secure.travis-ci.org/mbj/morpher.png?branch=master)](http://travis-ci.org/mbj/morpher)
[![Dependency Status](https://gemnasium.com/mbj/morpher.png)](https://gemnasium.com/mbj/morpher)
[![Code Climate](https://codeclimate.com/github/mbj/morpher.png)](https://codeclimate.com/github/mbj/morpher)

Morpher is a data transformation algebra with optional tracked evaluation.

It can be used at various places:

* Domain to JSON and vice versa, for building rest style APIS
* Domain to document db and vice versa, for building mappers
* Form processing
* ...

Status
------

This library is in "moving to MDD from spike mode".

### Mutation coverage

I use so called "implicit coverage". A term that was invented by the [rom](https://github.com/rom-rb)-team
during mutation testing. Later when this library is not under steady flux anymore I'll switch to explicit coverage.

Installation
------------

Install the gem `morpher` via your preferred method.

Examples
--------

See specs, Public Evaluator API is stable and there are ongoing 0.x.y releases for early adopters.

Credits
-------

* [mbj](https://github.com/mbj)

Contributing
------------

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with Rakefile or version
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

License
-------

See LICENSE file.
