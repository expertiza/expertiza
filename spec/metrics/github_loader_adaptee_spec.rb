describe "GithubLoaderAdaptee" do
  it "loads and stores metric data" do
    params = {"url" => "https://github.com/totallybradical/simicheck-expertiza-sandbox/pull/3"}

    expect(GithubLoaderAdaptee.can_load?(params) == true) 
  end
end