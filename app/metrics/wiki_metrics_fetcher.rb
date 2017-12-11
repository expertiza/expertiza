class WikiMetricsFetcher
  require 'open-uri/cached'     # Require this gem to open given URL

  attr_accessor :url            # Expertiza wiki URL (String)
  attr_accessor :text           # Text in the expertiza wiki  (String)
  attr_accessor :readability    # Readability analysis result (Hash)

  SOURCE = Rails.configuration.wiki_source

  ##
  # Analyze whether a given URL is a valid expertiza wiki URL
  class << self
    def supports_url?(url)
      if !url.nil?
        # Try to get parameters from given URL by regular expression
        params = SOURCE[:REGEX].match(url)

        # Return whether parameters are successfully parsed
        !params.nil?
      else
        # Return false if no URL is given
        false
      end
    end
  end

  ##
  # Initializer
  def initialize(params)
    @url = params[:url]         # Get URL from given parameter hash
    @loaded = false             # Initialize @loaded status to false
  end

  ##
  # Fetch wiki content and analyze its readability
  def fetch_content
    # Get text from given wiki URL
    @text = Nokogiri::HTML(open(@url)).css('#bodyContent p').text

    # Analyze readability of the wiki text
    @readability = Odyssey.analyze_multi(@text, ['FleschKincaidRe', 'FleschKincaidGl', 'Ari', 'ColemanLiau', 'GunningFog', 'Smog'], true)

    # Set the @loaded status to true
    @loaded = true
  end

  ##
  # Get the @loaded status
  def is_loaded?
    # Return the @loaded status
    @loaded
  end
end