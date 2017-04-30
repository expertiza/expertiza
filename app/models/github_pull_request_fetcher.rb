
class GithubPullRequestFetcher
  require 'http_request'
  
  class << self
    def supports_url?(url)
      lowerCaseUrl = url.downcase
      (HttpRequest.is_valid_url(url) and
       (lowerCaseUrl.include? "github") and
       (/\/pull\/[0-9]+$/.match(lowerCaseUrl) != nil))
    end
  end

  def initialize(params)
    @url = params["url"]
  end

  def fetch_content
    url = @url + ".diff"
    res = HttpRequest.get(url)

    if res.is_a? Net::HTTPSuccess
      res.body
    else
      ""
    end
  end
end

