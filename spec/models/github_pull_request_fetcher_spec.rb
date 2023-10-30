describe 'GithubPullRequestFetcher' do
  it 'supports any valid URL' do
    expect(GithubPullRequestFetcher.supports_url?('https://github.com/totallybradical/simicheck-expertiza-sandbox/pull/3')).to be_truthy
  end

  it 'fetches a pull request diff' do
    http_setup_get_request_mock_success

    params = { 'url' => 'https://github.com/totallybradical/simicheck-expertiza-sandbox/pull/3' }
    fetcher = GithubPullRequestFetcher.new(params)
    res = fetcher.fetch_content
    expect(!res.empty?)
  end

  it 'fetch gives error and returns an empty string' do
    http_setup_get_request_mock_error

    params = { 'url' => 'https://github.com/totallybradical/simicheck-expertiza-sandbox/pull/3' }
    fetcher = GithubPullRequestFetcher.new(params)
    res = fetcher.fetch_content
    expect(res.empty?)
  end
end
