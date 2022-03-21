# SassC [![Build Status](https://travis-ci.org/sass/sassc-ruby.svg?branch=master)](https://travis-ci.org/sass/sassc-ruby) [![Gem Version](https://badge.fury.io/rb/sassc.svg)](http://badge.fury.io/rb/sassc)

Use `sassc-embedded` with SassC Ruby!

This fork removes the deprecated [`libsass`](https://github.com/sass/libsass) and replace it with [`sassc-embedded`](https://github.com/ntkme/sassc-embedded-polyfill-ruby), providing latest sass features and fast gem installation.

This should essentially be a drop in alternative to [sass/sassc-ruby](https://github.com/sass/sassc-ruby).

## Installation

Add these lines to your application's Gemfile:

```ruby
gem 'sassc', github: 'sass/sassc-ruby', ref: "refs/pull/233/head"
gem 'sassc-embedded'
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
