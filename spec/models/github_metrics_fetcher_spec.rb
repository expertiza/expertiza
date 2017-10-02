describe "GithubMetricsFetcher" do
  it "fetches a pull request from github" do
    params = {"url" => "https://github.com/totallybradical/simicheck-expertiza-sandbox/pull/3"}
    pr = GithubMetricsFetcher.new(params)
    pr.fetch_content
    expect( pr.is_loaded? == true )
    expect( pr.repo == "simicheck-expertiza-sandbox")
    puts "GITHUB PR"
    puts pr.commits
  end

  it "fetches a project from github" do
    params = {"url" => "https://github.com/zachncst/expertiza"}
    pr = GithubMetricsFetcher.new(params)
    pr.fetch_content
    expect( pr.is_loaded? == true )
    expect( pr.repo == "expertiza")
  end

  it "fetches a project from ncsu github" do
    params = {"url" => "https://github.ncsu.edu/zctaylor/csc517-program-1" }
    pr = GithubMetricsFetcher.new(params)
    pr.fetch_content
    expect(pr.is_loaded? == true )
    expect(pr.repo == "csc517-program-1")
    puts "NCSU GITHUB PROJ"
    puts pr.commits
  end

  it "fetches a pr from ncsu github" do
    params = {"url" => "https://github.ncsu.edu/zctaylor/csc517-program-1/pull/10" }
    pr = GithubMetricsFetcher.new(params)
    pr.fetch_content
    expect(pr.is_loaded? == true )
    expect(pr.repo == "csc517-program-1")
    puts "NCSU GITHUB PR"
    puts pr.commits
  end
end
