class GithubProject
  #< Metric
  attr_accessor :url
  attr_accessor :number
  attr_accessor :user
  attr_accessor :repo
  attr_accessor :commits

  def initialize(fetcher)
    if not fetcher.is_loaded?
      fetcher.fetch_content
    end

    @url = fetcher.url
    @number = fetcher.number
    @repo = fetcher.repo
    @commits = fetcher.commits
    @user = fetcher.user
  end
end