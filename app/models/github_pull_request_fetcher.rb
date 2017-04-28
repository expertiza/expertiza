
class GithubPullRequestFetcher
  require 'http_request'
  
  class << self
    def SupportsUrl?(url)
      lowerCaseUrl = url.downcase
      ((lowerCaseUrl.include? "github") and
       (/\/pull\/[0-9]+$/.match(lowerCaseUrl) != nil))
    end
  end

  def initialize(params)
    @url = params["url"]
  end

  def FetchContent
    url = @url + ".diff"

    puts "Fetching GitHub pull request: " + url
    res = HttpRequest.Get(url)

    if res.is_a? Net::HTTPSuccess
      res.body
    else
      puts "Failed request to GitHub pull request URL: #{@url}, code #{res.code}"
      ""
    end
  end

end

