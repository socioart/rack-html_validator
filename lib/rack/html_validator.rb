require "rack/html_validator/version"
require "w3c_validators"

module Rack
  class HtmlValidator
    class Error < StandardError; end
    CONTENT_TYPE_KEY_PATTERN = /\Acontent-type\z/i.freeze

    class << self
      attr_accessor :enable
    end

    self.enable = true

    def initialize(app)
      @app = app
    end

    def call(env)
      response = @app.call(env)
      return response unless self.class.enable
      return response unless html?(response)
      return response unless (error_response = validate(response))

      [500, {"Content-Type" => "text/plain; charset=utf-8"}, [error_response]]
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

      validator = W3CValidators::NuValidator.new
      results = validator.validate_text(html)
      return if results.errors.empty?

      render_errors(results.errors, response)
    end

    def render_errors(errors, response)
      buffer = "HTML Validation Failed (Rack::HtmlValidator)\n"
      buffer << "==============================================\n"
      buffer << "\n"
      buffer << "# Errors\n"
      buffer << "--\n"
      errors.each do |error|
        buffer << <<~TXT
          Type: #{error.type}
          Line: #{error.line}
          Message: #{error.message}
          Source: #{error.source}
        TXT
        buffer << "--\n"
      end
      buffer << "\n"
      buffer << "# Source\n"
      buffer << "Status: #{response[0]}\n"
      buffer << "Header:\n"
      response[1].each do |k, v|
        buffer << "  #{k}: #{v}\n"
      end
      buffer << "Body:\n"
      buffer << response[2].join
      buffer << "\n"
      buffer
    end
  end
end
