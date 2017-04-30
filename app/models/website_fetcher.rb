
class WebsiteFetcher
  require 'http_request'
  
  class << self
    def supports_url?(url)
      HttpRequest.is_valid_url(url)
    end
  end

  def initialize(params)
    @url = params["url"]
  end

  def fetch_content
    puts "Fetching from website URL: " + @url
    res = HttpRequest.get(@url)

    if res.is_a? Net::HTTPSuccess
      sanitize(res.body)
    else
      puts "Failed request to website content URL: #{@url}, code #{res.code}"
      ""
    end
  end

  private
  def sanitize(html_string)
    # https://apidock.com/rails/ActionView/Helpers/SanitizeHelper/strip_tags
    ActionController::Base.helpers.strip_tags(html_string)
  end

end

