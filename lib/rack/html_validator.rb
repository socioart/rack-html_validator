require "rack/html_validator/version"
require "w3c_validators"
require "erb"

module Rack
  class HtmlValidator
    include ERB::Util

    class Error < StandardError; end
    CONTENT_TYPE_KEY_PATTERN = /\Acontent-type\z/i.freeze
    ERROR_PAGE_TEMPLATE = ::File.read("#{__dir__}/error_page_template.html.erb")

    class << self
      attr_accessor :enable
    end

    attr_reader :app, :validator_uri, :async, :skip_if

    self.enable = true

    def initialize(app, validator_uri, **options)
      @app = app
      @validator_uri = validator_uri
      @async = options.fetch(:async, false)
      @skip_if = options[:skip_if]
    end

    def call(env)
      response = @app.call(env)
      return response unless self.class.enable
      return response unless html?(response)
      return response if skip_if&.call(env, response)

      if async
        response_duprecated = response.deep_dup
        Thread.new do
          error_response = validate(response_duprecated)
          if error_response
            f = Tempfile.new(["html_validator", ".html"])
            f.write(error_response)
            f.close
            system("open", f.path)
          end
        end

        response
      else
        return response unless (error_response = validate(response))

        [500, {"Content-Type" => "text/html; charset=utf-8"}, [error_response]]
      end
    end

    private
    def html?(response)
      headers = response[1]
      _, content_type = headers.find {|k, _v| k =~ CONTENT_TYPE_KEY_PATTERN }
      return false unless content_type

      content_type.start_with?("text/html")
    end

    def validate(response)
      body = response[2]
      html = ""
      body.each {|chunk| html << chunk }
      response[2] = [html]

      validator = W3CValidators::NuValidator.new(validator_uri: validator_uri)
      results = validator.validate_text(html)
      return if results.errors.empty?

      render_errors(results.errors, response)
    end

    def render_errors(errors, response)
      ERB.new(ERROR_PAGE_TEMPLATE, trim_mode: "-").result(binding)
    end
  end
end
