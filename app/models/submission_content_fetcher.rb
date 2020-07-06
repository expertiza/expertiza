
class SubmissionContentFetcher
  class << self
    def doc_factory(url)
      return nil unless GoogleDocFetcher.supports_url?(url) || WebsiteFetcher.supports_url?(url)

      params = {"url" => url}

      return GoogleDocFetcher.new(params) if GoogleDocFetcher.supports_url?(url)
      return WebsiteFetcher.new(params) if WebsiteFetcher.supports_url?(url) # leave as catch-all
    end

    def code_factory(url)
      params = {"url" => url}

      return GithubPullRequestFetcher.new(params) if GithubPullRequestFetcher.supports_url?(url)
      nil
    end

    # Don't allow this object to be instantiated
    private :new
  end
end
