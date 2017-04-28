
class SubmissionContentFetcher
  class << self
    def DocFactory(url)
      params = { "url" => url }

      if GoogleDocFetcher.supports_url?(url)
        GoogleDocFetcher.new(params)

      elsif WebsiteFetcher.supports_url?(url) # leave last as catch-all
        WebsiteFetcher.new(params)

      else
        nil
      end
    end

    def CodeFactory(url)
      params = { "url" => url }

      if GithubPullRequestFetcher.supports_url?(url)
        GithubPullRequestFetcher.new(params)
      else
        nil
      end
    end

    # Don't allow this object to be instantiated
    private :new
  end
end

