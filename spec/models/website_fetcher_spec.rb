require 'rails_helper'

describe "WebsiteFetcher" do

  let(:httprequest) do
    stub_model HttpRequest do |httprequest|
      httprequest.stub(:get) do |url|
        if url == "test.com"
          res = Net::HTTPSuccess
          res.body = "<i>some test text</i>"
          puts "Test"
        else
          res = Net::HTTPServerError
          res.body = ""
          puts "Bogus"
        end
        res
      end
    end
  end

  it "supports any URL" do
    expect(WebsiteFetcher.supports_url?("any url")).to be true
    expect(WebsiteFetcher.supports_url?("")).to be true
    expect(WebsiteFetcher.supports_url?("google.com")).to be true
    expect(WebsiteFetcher.supports_url?("https://github.com/totallybradical/expertiza-simicheck-integration")).to be true
  end

  it "fetches a website and removes all HTML" do
    params = { "url" => "test.com" }
    fetcher = WebsiteFetcher.new(params)
    res = fetcher.fetch_content
    expect(res).to be "some test text"
  end

  it "fetches a bogus website and returns an empty string" do
    params = { "url" => "bogus website" }
    fetcher = WebsiteFetcher.new(params)
    res = fetcher.fetch_content
    expect(res).to be ""
  end

end
