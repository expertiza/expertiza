describe 'GoogleDocFetcher' do
  it 'supports any valid URL' do
    expect(GoogleDocFetcher.supports_url?('https://drive.google.com/open?id=1Ngds9Fr4vas8n0cA-uvZDOU7VMarMfGytbC9VLc0IYI')).to be_truthy
    expect(GoogleDocFetcher.supports_url?('https://docs.google.com/document/d/1-waDJtPB8VGLyubb40-X951PF9R3jdhm6Kb4ga__S0E/edit')).to be_truthy
  end

  it 'fetches a google doc export' do
    http_setup_get_request_mock_success

    params = { 'url' => 'https://docs.google.com/document/d/1-waDJtPB8VGLyubb40-X951PF9R3jdhm6Kb4ga__S0E/edit' }
    fetcher = GoogleDocFetcher.new(params)
    res = fetcher.fetch_content
    expect(!res.empty?)
  end

  it 'fetch gives error and returns an empty string' do
    http_setup_get_request_mock_error

    params = { 'url' => 'https://docs.google.com/document/d/1Ngds9Fr4vas8n0cA-uvZDOU7VMarMfGytbC9VLc0IYI/edit' }
    fetcher = GoogleDocFetcher.new(params)
    res = fetcher.fetch_content
    expect(res.empty?)
  end
end
