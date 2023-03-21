describe 'HttpRequest' do
  it 'cannot be instantiated' do
    expect { HttpRequest.new }.to raise_error(NoMethodError)
  end

  it 'correctly identifies URLs' do
    expect(HttpRequest.valid_url?('http://www.google.com')).to be_truthy
    expect(HttpRequest.valid_url?('https://www.google.com')).to be_truthy
    expect(HttpRequest.valid_url?('https://www.google.com:80')).to be_truthy

    expect(HttpRequest.valid_url?('http://www.google.com/')).to be_truthy
    expect(HttpRequest.valid_url?('http://www.google.com?')).to be_truthy
    expect(HttpRequest.valid_url?('http://www.google.com?arg1=123&arg2=456')).to be_truthy
    expect(HttpRequest.valid_url?('http://www.google.com/arg1/123/arg2/456')).to be_truthy
  end

  # NOTE: no need to test get() and get_file() since they wrap net/http methods which should have their own tests
end
