class WikiMetricsFetcher
  require 'open-uri/cached'

  attr_accessor :url
  attr_accessor :text
  attr_accessor :readability

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
    @text = Nokogiri::HTML(open(@url)).css('#bodyContent p').text
    @readability = Odyssey.analyze_multi(@text, ['FleschKincaidRe', 'FleschKincaidGl', 'Ari', 'ColemanLiau', 'GunningFog', 'Smog'], true)
    @loaded = true
  end

  def is_loaded?
    @loaded
  end
end