describe "GithubPullRequest" do
  it "fetches a pull request from github" do
    params = {"url" => "https://github.com/totallybradical/simicheck-expertiza-sandbox/pull/3"}
    pr = GithubPullRequest.new(params)
    pr.fetch_content
    expect(! pr.data.empty?)
  end
end
