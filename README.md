## SassC Has Reached End-of-Life

The `sassc` gem should no longer be used, and will no longer be receiving any updates.

The [`sass-embedded`](https://rubygems.org/gems/sass-embedded) gem is the recommended way to move away from `sassc`. It bundles the [Dart Sass](https://sass-lang.com/dart-sass/) command-line executable, and uses the [Embedded Sass Protocol](https://github.com/sass/sass/blob/HEAD/spec/embedded-protocol.md) to provide a [Modern Ruby API](https://rubydoc.info/gems/sass-embedded/Sass) for compiling Sass and defining custom importers and functions.

If you find it difficult migrating to the Modern Ruby API, the [`sassc-embedded`](https://rubygems.org/gems/sassc-embedded) gem is a drop-in replacement for the `sassc` gem. It provides the same [Legacy Ruby API](https://github.com/sass-contrib/sassc-embedded-shim-ruby/blob/HEAD/README.md#usage), but internally runs `sass-embedded` instead of `libsass`.

You can also use the [`dartsass-rails`](https://rubygems.org/gems/dartsass-rails) gem, a basic command-line integration with the Dart Sass executable from the `sass-embedded` gem; or [`dartsass-sprockets`](https://rubygems.org/gems/dartsass-sprockets) gem, an advanced sprockets integration with the Legacy Ruby API from the `sassc-embedded` gem, to plug smoothly into Ruby on Rails.

Alternately, you can explore using a JS build system with Dart Sass as a [JavaScript library](https://sass-lang.com/dart-sass/#java-script-library).

# SassC [![Build Status](https://travis-ci.org/sass/sassc-ruby.svg?branch=master)](https://travis-ci.org/sass/sassc-ruby) [![Gem Version](https://badge.fury.io/rb/sassc.svg)](http://badge.fury.io/rb/sassc)

Use `libsass` with Ruby!

This gem combines the speed of `libsass`, the [Sass C implementation](https://github.com/sass/libsass), with the ease of use of the original [Ruby Sass](https://github.com/sass/ruby-sass) library.

### libsass Version

[3.6.1](https://github.com/sass/libsass/releases/3.6.1)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sassc'
```

And then execute:

```bash
bundle
```

Or install it yourself as:

```bash
gem install sassc
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
