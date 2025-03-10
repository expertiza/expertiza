describe 'WebsiteFetcher' do
  it 'supports any valid URL' do
    expect(WebsiteFetcher.supports_url?('http://www.google.com')).to be_truthy
    expect(WebsiteFetcher.supports_url?('https://github.com/totallybradical/expertiza-simicheck-integration')).to be_truthy
  end

  it 'fetches a website and removes all HTML' do
    http_setup_get_request_mock_success

    params = { 'url' => 'test.com' }
    fetcher = WebsiteFetcher.new(params)
    res = fetcher.fetch_content
    expect(res).to eql(http_mock_success_text(false))
  end

  it 'fetches a bogus website and returns an empty string' do
    http_setup_get_request_mock_error

    params = { 'url' => 'test.com' }
    fetcher = WebsiteFetcher.new(params)
    res = fetcher.fetch_content
    expect(res).to eql('')
  end
end
