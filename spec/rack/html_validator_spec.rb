require "spec_helper"

RSpec.describe Rack::HtmlValidator do
  let(:app) {
    rack = Rack::Builder.new
    rack.use(Rack::HtmlValidator, "http://localhost:8888/")
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
        expect(last_response.headers).to eq("Content-Type" => "text/html; charset=utf-8")
        expect(last_response.body).to eq <<~HTML
          <!doctype html>
          <head>
            <title>HTML Validation Failed (Rack::HtmlValidator)</title>
            <style>
              body {
                font-size: 12px;
                padding: 2em;
                max-width: 1024px;
                margin: 0 auto;
              }
              body, pre {
                font-family: "Monaco", monospace;
              }
              pre {
                white-space: pre-wrap;
              }
              table {
                border-collapse: collapse;
                border: 1px solid #ccc;
                margin-bottom: 1em;
                width: 100%;
              }
              th, td {
                border-top: 1px solid #ccc;
                padding: 0.5em;
                vertical-align: top;
                text-align: left;
              }
            </style>
          </head>
          <h1>HTML Validation Failed (Rack::HtmlValidator)</h1>
          <h2>Errors</h2>
            <table>
              <tbody>
                <tr>
                  <th>Type:</th>
                  <td>error</td>
                </tr>
                <tr>
                  <th>Line:</th>
                  <td>1</td>
                </tr>
                <tr>
                  <th>Message:</th>
                  <td>Element “foo” not allowed as child of element “body” in this context. (Suppressing further errors from this subtree.)</td>
                </tr>
                <tr>
                  <th>Source:</th>
                  <td><pre>le&lt;/title&gt;&lt;foo&gt;body</pre></td>
                </tr>
              </tbody>
            </table>
            <table>
              <tbody>
                <tr>
                  <th>Type:</th>
                  <td>error</td>
                </tr>
                <tr>
                  <th>Line:</th>
                  <td>1</td>
                </tr>
                <tr>
                  <th>Message:</th>
                  <td>End of file seen and there were open elements.</td>
                </tr>
                <tr>
                  <th>Source:</th>
                  <td><pre>e&gt;&lt;foo&gt;body</pre></td>
                </tr>
              </tbody>
            </table>
            <table>
              <tbody>
                <tr>
                  <th>Type:</th>
                  <td>error</td>
                </tr>
                <tr>
                  <th>Line:</th>
                  <td>1</td>
                </tr>
                <tr>
                  <th>Message:</th>
                  <td>Unclosed element “foo”.</td>
                </tr>
                <tr>
                  <th>Source:</th>
                  <td><pre>le&lt;/title&gt;&lt;foo&gt;body</pre></td>
                </tr>
              </tbody>
            </table>
          <h2>Source</h2>
          <table>
            <tbody>
              <tr>
                <th>Status</td>
                <td>200</td>
              </tr>
              <tr>
                <th>Header</td>
                <td>
                  <ul>
                      <li>Content-Type: text/html; charset=utf-8</li>
                  </ul>
                </td>
              </tr>
              <tr>
                <th>Body</td>
                <td><pre>&lt;!doctype html&gt;&lt;title&gt;title&lt;/title&gt;&lt;foo&gt;body</pre></td>
              </tr>
            </tbody>
          <table>
        HTML
      end
    end
  end
end
