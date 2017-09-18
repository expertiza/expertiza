describe "GithubPullRequest" do
  it "fetches a pull request from github" do
    params = {"url" => "https://github.com/totallybradical/simicheck-expertiza-sandbox/pull/3"}
    pr = GithubPullRequestFetcher.new(params)
    pr.fetch_content
    expect( pr.is_loaded? == true )
    expect( pr.repo == "simicheck-expertiza-sandbox")
    print pr.to_bar_graph
  end
end
