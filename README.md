# SassC [![Build Status](https://travis-ci.org/bolandrm/sassc-ruby.svg?branch=master)](https://travis-ci.org/bolandrm/sassc-ruby) [![Gem Version](https://badge.fury.io/rb/sassc.svg)](http://badge.fury.io/rb/sassc)

Use `libsass` with Ruby!

This gem combines the speed of `libsass`, the [Sass C implementation](https://github.com/sass/libsass), with the easy of use of the original [Ruby Sass](https://github.com/sass/sass) library.

### libsass Version

[3.2.2](https://github.com/sass/libsass/releases/tag/3.2.2)

## Usage

This library utilizes `libsass` to allow you to compile SCSS or SASS syntax
to CSS.  To compile, use a `SassC::Engine`.

**Note**:  If you want to use this library with Rails/Sprockets, check out
[sassc-rails](https://github.com/bolandrm/sassc-rails).

Additionally, you can use `SassC::Sass2Scss` to convert Sass syntax to Scss syntax.

## Contributing

### Project Setup

1. Clone repo
2. Install dependencies - `bundle install`
3. Initialize the libsass submodule - `bundle exec rake submodule`
4. Run the tests - `bundle exec rake test`

### Code Changes

1. Fork it ( https://github.com/[my-github-username]/sassc/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`) - try to include tests
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
