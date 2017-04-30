require 'rails_helper'

describe "WebsiteFetcher" do

  it "supports any valid URL" do
    expect(WebsiteFetcher.supports_url?("any url")).to be_falsey
    expect(WebsiteFetcher.supports_url?("")).to be_falsey
    expect(WebsiteFetcher.supports_url?("http://www.google.com")).to be_truthy
    expect(WebsiteFetcher.supports_url?("https://github.com/totallybradical/expertiza-simicheck-integration")).to be_truthy
  end

  it "fetches a website and removes all HTML" do
    text = "some test text"
    HttpRequestTestHelper.setup_mock((Net::HTTPSuccess, "<img /><i>#{text}</i>")

    params = { "url" => "test.com" }
    fetcher = WebsiteFetcher.new(params)
    res = fetcher.fetch_content
    expect(res).to eql(text)
  end

  it "fetches a bogus website and returns an empty string" do
    HttpRequestTestHelper.setup_mock((Net::HTTPServerError, "Internal Server Error")

    params = { "url" => "test.com" }
    fetcher = WebsiteFetcher.new(params)
    res = fetcher.fetch_content
    expect(res).to eql("")
  end

end
