
class GithubPullRequestFetcher
  require 'http_request'
  
  class << self
    def supports_url?(url)
      lowerCaseUrl = url.downcase
      ((lowerCaseUrl.include? "github") and
       (/\/pull\/[0-9]+$/.match(lowerCaseUrl) != nil))
    end
  end

  def initialize(params)
    @url = params["url"]
  end

  def fetch_content
    url = @url + ".diff"

    puts "Fetching GitHub pull request: " + url
    res = HttpRequest.get(url)

    if res.is_a? Net::HTTPSuccess
      res.body
    else
      puts "Failed request to GitHub pull request URL: #{@url}, code #{res.code}"
      ""
    end
  end

end

