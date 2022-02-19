class GithubPullRequestFetcher
  require 'http_request'

  class << self
    def supports_url?(url)
      lower_case_url = url.downcase
      (HttpRequest.valid_url?(url) &&
       (lower_case_url.include? 'github') &&
       !%r{/pull/[0-9]+$}.match(lower_case_url).nil?)
    end
  end

  def initialize(params)
    @url = params['url']
  end

  def fetch_content
    url = @url + '.diff'
    res = HttpRequest.get(url)

    if res.is_a? Net::HTTPSuccess
      res.body
    else
      ''
    end
  end
end
