describe "GithubMetricsFetcher" do
  it "fetches a pull request from github" do
    params = { :url => "https://github.com/totallybradical/simicheck-expertiza-sandbox/pull/3"}
    pr = GithubMetricsFetcher.new(params)
    pr.fetch_content
    expect(pr.is_loaded?).to be true
    expect(pr.repo).to eq "simicheck-expertiza-sandbox"
    puts pr.commits
  end

  it "fetches a project from github" do
    params = { :url => "https://github.com/zachncst/expertiza"}
    pr = GithubMetricsFetcher.new(params)
    pr.fetch_content
    expect(pr.is_loaded?).to be true
    expect(pr.repo).to eq "expertiza"
  end

  it "fetches a project from ncsu github" do
    params = { :url => "https://github.ncsu.edu/zctaylor/csc517-program-1" }
    pr = GithubMetricsFetcher.new(params)
    pr.fetch_content
    expect(pr.is_loaded?).to be true
    expect(pr.repo).to eq "csc517-program-1"
  end

  it "fetches a pr from ncsu github" do
    params = { :url => "https://github.ncsu.edu/zctaylor/csc517-program-1/pull/10" }
    pr = GithubMetricsFetcher.new(params)
    pr.fetch_content
    expect(pr.is_loaded?).to be true
    expect(pr.repo).to eq "csc517-program-1"
  end
end
