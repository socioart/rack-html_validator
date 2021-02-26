# Rack::HtmlValidator

Rack::HtmlValidator is Rack middleware validates all HTML response. This is useful, but too slow... (eg. 35ms -> 800ms).


## Installation

Add this line to your application's Gemfile:

```ruby
group :development, :test do
  gem "rack-html_validator", require: false, git: "https://github.com/socioart/rack-html_validator.git"
end
```

And then execute:

    $ bundle install

## Usage

For Rails application, create `config/initializers/rack-html_validator.rb`.

```ruby
# rubocop:disable Naming/FileName
case Rails.env
when "development", "test"
    require "rack/html_validator"
    Rails.application.middleware.use Rack::HtmlValidator
end
# rubocop:enable Naming/FileName
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/labocho/rack-html_validator.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
