describe "GithubMetricsFetcher" do
  it "fetches a pull request from github" do
    params = {"url" => "https://github.com/totallybradical/simicheck-expertiza-sandbox/pull/3"}
    pr = GithubMetricsFetcher.new(params)
    pr.fetch_content
    expect( pr.is_loaded? == true )
    expect( pr.repo == "simicheck-expertiza-sandbox")
    puts pr.commits
  end

  it "fetches a project from github" do
    params = {"url" => "https://github.com/zachncst/expertiza"}
    pr = GithubMetricsFetcher.new(params)
    pr.fetch_content
    expect( pr.is_loaded? == true )
    expect( pr.repo == "simicheck-expertiza-sandbox")
    puts pr.commits
  end
end
