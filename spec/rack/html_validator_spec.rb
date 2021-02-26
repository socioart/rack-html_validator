require "spec_helper"

RSpec.describe Rack::HtmlValidator do
  let(:app) {
    rack = Rack::Builder.new
    rack.use(Rack::HtmlValidator)
    rack.run(
      -> (_env) { [200, headers, body] },
    )
    rack.to_app
  }

  it "has a version number" do
    expect(Rack::HtmlValidator::VERSION).not_to be nil
  end

  context "content-type header does not exist" do
    let(:headers) { {"X-Foo" => "foo"} }
    let(:body) { ["body"] }

    it "should return original response" do
      get "/"

      expect(last_response.status).to eq 200
      expect(last_response.headers).to eq(headers)
      expect(last_response.body).to eq("body")
    end
  end

  context "content-type is not html" do
    let(:headers) { {"Content-Type" => "text/plain"} }
    let(:body) { ["body"] }

    it "should return original response" do
      get "/"

      expect(last_response.status).to eq 200
      expect(last_response.headers).to eq(headers)
      expect(last_response.body).to eq("body")
    end
  end

  context "content-type is html" do
    let(:headers) { {"Content-Type" => "text/html; charset=utf-8"} }

    context "valid html" do
      let(:body) { ["<!doctype html><title>title</title><p>body"] }
      it "should return original response" do
        get "/"

        expect(last_response.status).to eq 200
        expect(last_response.headers).to eq(headers)
        expect(last_response.body).to eq(body.join)
      end
    end

    context "invalid html" do
      let(:body) { ["<!doctype html><title>title</title><foo>body"] }
      it "should response validation error" do
        get "/"

        expect(last_response.status).to eq 500
        expect(last_response.headers).to eq("Content-Type" => "text/plain; charset=utf-8")
        expect(last_response.body).to eq <<~ERRORS
          HTML Validation Failed (Rack::HtmlValidator)
          ==============================================

          # Errors
          --
          Type: error
          Line: 1
          Message: Element “foo” not allowed as child of element “body” in this context. (Suppressing further errors from this subtree.)
          Source: le</title><foo>body
          --
          Type: error
          Line: 1
          Message: End of file seen and there were open elements.
          Source: e><foo>body
          --
          Type: error
          Line: 1
          Message: Unclosed element “foo”.
          Source: le</title><foo>body
          --

          # Source
          Status: 200
          Header:
            Content-Type: text/html; charset=utf-8
          Body:
          <!doctype html><title>title</title><foo>body
        ERRORS
      end
    end
  end
end
