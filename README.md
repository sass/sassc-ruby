# Dart Sass for Ruby

[![build](https://github.com/tablecheck/dartsass-ruby/actions/workflows/build.yml/badge.svg)](https://github.com/tablecheck/dartsass-ruby/actions/workflows/build.yml)
[![gem](https://badge.fury.io/rb/dartsass-ruby.svg)](https://rubygems.org/gems/dartsass-ruby)

Use [dart-sass](https://sass-lang.com/dart-sass) with Ruby and Sprockets.

This gem is a fork of [sass/sassc-ruby](https://github.com/sass/sassc-ruby)
which maintains API compatibility but delegates to the
[sass-embedded gem](https://github.com/ntkme/sass-embedded-host-ruby)
which provides native binaries for Dart Sass (instead of the libsass
C implmentation.)

For ease of upgrading, the root namespace `::SassC` is still used by this gem,
although it is now a misnomer. This is planned to be migrated in a future
major version.

### Upgrading to Dart Sass

The interface of [sassc-ruby](https://github.com/sass/sassc-ruby) is largely unchanged, however:

1. Option `style: :nested` and `style: :compact` behave as `style: :expanded`. Use `style: :compressed` for minification.
2. Option `:precision` is ignored.
3. Option `:line_comments` is ignored.
4. `Sass2Scss` functionality has been removed.

See [the dart-sass documentation](https://github.com/sass/dart-sass#behavioral-differences-from-ruby-sass) for other differences.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dartsass-ruby'
```

Rails/Sprockets users should additionally add [sassc-rails](https://github.com/sass/sassc-rails):

```ruby
gem 'sassc-rails'
```

## Usage

This library utilizes [dart-sass](https://github.com/sass/dart-sass) to compile
SCSS or SASS syntax to CSS. To compile, use a `SassC::Engine`, e.g.:

```ruby
SassC::Engine.new(".klass1, .klass2 { color: :red; }", style: :compressed).render
```

## Alternatives

* [dartsass-rails](https://github.com/rails/dartsass-rails): Rails organization
maintains its own wrapper for Dart Sass. Unlike this gem, dartsass-rails does
not support Sprockets.

## Credits

* This gem is maintained and used in production by [TableCheck](https://www.tablecheck.com/en/join). (We'd be very glad if the Sass organization could take over maintainership in the future!)
* Kudos to [@ntkme](https://github.com/ntkme) for dart-sass support.
* Credit to [Ryan Boland](https://ryanboland.com) and the authors of the original sassc-rails gem.
* See our [awesome contributors](https://github.com/tablecheck/sassc-ruby/graphs/contributors).

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

## Contributing

### Project Setup

1. Clone repo
1. Install dependencies - `bundle install`
1. Run the tests - `bundle exec rake test`

### Code Changes

1. Fork it ([https://github.com/sass/sassc-ruby/fork](https://github.com/sass/sassc-ruby/fork))
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`) - try to include tests
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
