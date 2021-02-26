require_relative "lib/rack/html_validator/version"

Gem::Specification.new do |spec|
  spec.name          = "rack-html_validator"
  spec.version       = Rack::HtmlValidator::VERSION
  spec.authors       = ["labocho"]
  spec.email         = ["labocho@penguinlab.jp"]

  spec.summary       = "Rack middleware to validate html response"
  spec.description   = "Rack middleware to validate html response"
  spec.homepage      = "https://github.com/socioart/rack-html_validator"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/socioart/rack-html_validator"
  spec.metadata["changelog_uri"] = "https://github.com/socioart/rack-html_validator/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject {|f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r(^exe/)) {|f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rack", "~> 2.2"
  spec.add_dependency "w3c_validators", "~> 1.3"
end
