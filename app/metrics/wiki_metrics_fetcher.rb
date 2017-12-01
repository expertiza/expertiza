class WikiMetricsFetcher
  require 'open-uri/cached'

  attr_accessor :url
  attr_accessor :text
  attr_accessor :readability
  attr_accessor :loaded

  SOURCE = Rails.configuration.wiki_source

  class << self
    def supports_url?(url)
      if !url.nil?
        params = SOURCE[:REGEX].match(url)
        !params.nil?
      else
        false
      end
    end
  end

  def initialize(params)
    @url = params[:url]
    @loaded = false
  end

  def fetch_content
    @text = parseWiki(@url)
    @readability = analyzeText(@text)
    @loaded = true
  end

  def self.parseWiki(url)
    Nokogiri::HTML(open(url)).css('#bodyContent p').text()
  end

  def self.analyzeText(text)
    Odyssey.analyze_multi(text, ['FleschKincaidRe', 'FleschKincaidGl', 'Ari', 'ColemanLiau', 'GunningFog', 'Smog'], true)
  end
end