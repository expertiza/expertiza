require 'rails_helper'

describe "WebsiteFetcher" do

  # let(:httprequest) do
  #   stub_model HttpRequest do |httprequest|
  #     httprequest.stub(:get) do |url|
  #       if url == "test.com"
  #         res = Net::HTTPSuccess
  #         res.body = "<i>some test text</i>"
  #         puts "Test"
  #       else
  #         res = Net::HTTPServerError
  #         res.body = ""
  #         puts "Bogus"
  #       end
  #       res
  #     end
  #   end
  # end

  # http://stackoverflow.com/questions/13755452/how-to-mock-nethttppost
  before do
    # http = double
    # allow(Net::HTTP).to receive(:start).and_yield http
    # allow(Net::HTTP).to receive(:closed?).and_return(true)
    # allow(http).to receive(:request).with(an_instance_of(Net::HTTP::Get)).and_return(Net::HTTPSuccess.new("1.1", 200, "OK"))
    # allow(Net::HTTPSuccess).to receive(:body).and_return("<i>some test text</i>")
    # allow(Net::HTTPSuccess).to receive(:code).and_return("200")

    h = class_double("HttpRequest") #.as_stubbed_const
    allow(h).to receive(:get).and_return(Net::HTTPSuccess.new("1.1", 200, "OK"))

    #allow(HttpRequest).to receive(:get).and_return(Net::HTTPSuccess.new("1.1", 200, "OK"))
    #allow(Net::HTTPSuccess).to receive(:body).and_return("<i>some test text</i>")

  end

  it "supports any valid URL" do
    expect(WebsiteFetcher.supports_url?("any url")).to be_falsey
    expect(WebsiteFetcher.supports_url?("")).to be_falsey
    expect(WebsiteFetcher.supports_url?("http://www.google.com")).to be_truthy
    expect(WebsiteFetcher.supports_url?("https://github.com/totallybradical/expertiza-simicheck-integration")).to be_truthy
  end

  it "fetches a website and removes all HTML" do

    #allow(HttpRequest).to receive(:get).and_return(Net::HTTPSuccess)

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
