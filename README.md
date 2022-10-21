# SassC [![Build Status](https://travis-ci.org/sass/sassc-ruby.svg?branch=master)](https://travis-ci.org/sass/sassc-ruby) [![Gem Version](https://badge.fury.io/rb/sassc.svg)](http://badge.fury.io/rb/sassc)

Use `sassc-embedded` with SassC Ruby!

This fork removes the deprecated [`libsass`](https://github.com/sass/libsass) and replace it with [`sassc-embedded`](https://github.com/ntkme/sassc-embedded-polyfill-ruby), providing latest sass features and fast gem installation.

This should essentially be a drop in alternative to [sass/sassc-ruby](https://github.com/sass/sassc-ruby).












# Embedded Sass Shim for SassC Ruby

[![build](https://github.com/ntkme/sassc-embedded-shim-ruby/actions/workflows/build.yml/badge.svg)](https://github.com/ntkme/sassc-embedded-shim-ruby/actions/workflows/build.yml)
[![gem](https://badge.fury.io/rb/sassc-embedded.svg)](https://rubygems.org/gems/sassc-embedded)

Use `sass-embedded` with SassC Ruby!

This library shims [`sassc`](https://github.com/sass/sassc-ruby) with the [`sass-embedded`](https://github.com/ntkme/sass-embedded-host-ruby) implementation.

It has been tested with:

- [`sassc`](https://github.com/sass/sassc-ruby)
- [`sassc-rails`](https://github.com/sass/sassc-rails)
- [`sprockets`](https://github.com/rails/sprockets)
- [`sprockets-rails`](https://github.com/rails/sprockets-rails)

## Install

Add these lines to your application's Gemfile:

``` ruby
gem 'sassc', github: 'sass/sassc-ruby', ref: 'refs/pull/233/head'
gem 'sassc-embedded'
```

And then execute:

``` sh
bundle
```

Or install it yourself as:

``` sh
gem install sassc-embedded
```

## Usage

This shim utilizes `sass-embedded` to allow you to compile SCSS or SASS syntax to CSS. To compile, use a `SassC::Engine`, e.g.:

``` ruby
require 'sassc-embedded'

SassC::Engine.new(sass, style: :compressed).render
```

See [rubydoc.info/gems/sassc](https://rubydoc.info/gems/sassc) for full API documentation.

## Behavioral Differences from SassC Ruby

1. Option `:style => :nested` and `:style => :compact` behave as `:style => :expanded`.

2. Option `:precision` is ignored.

3. Option `:line_comments` is ignored.

See [the dart-sass documentation](https://github.com/sass/dart-sass#behavioral-differences-from-ruby-sass) for other differences.





## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rails-sass-embedded'
```

And then execute:

```bash
bundle
```

## Usage

This library utilizes `libsass` to allow you to compile SCSS or SASS syntax
to CSS.  To compile, use a `SassC::Engine`, e.g.:

```ruby
SassC::Engine.new(sass, style: :compressed).render
```

**Note**:  If you want to use this library with Rails/Sprockets, check out
[sassc-rails](https://github.com/bolandrm/sassc-rails).

Additionally, you can use `SassC::Sass2Scss` to convert Sass syntax to Scss syntax.

## Credits

This gem is maintained by [Ryan Boland](https://ryanboland.com)
and [awesome contributors](https://github.com/bolandrm/sassc-ruby/graphs/contributors).

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

## Contributing

### Project Setup

1. Clone repo
1. Install dependencies - `bundle install`
1. Run the tests - `bundle exec rake test`

### Code Changes

1. Fork it ( https://github.com/sass/sassc-ruby/fork )
1. Create your feature branch (`git checkout -b my-new-feature`)
1. Commit your changes (`git commit -am 'Add some feature'`) - try to include tests
1. Push to the branch (`git push origin my-new-feature`)
1. Create a new Pull Request
