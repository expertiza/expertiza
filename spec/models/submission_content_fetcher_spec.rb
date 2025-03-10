describe 'SubmissionContentFetcher' do
  it 'cannot be instantiated' do
    expect { SubmissionContentFetcher.new }.to raise_error(NoMethodError)
  end

  it 'creates factory for wiki documentation' do
    url = 'http://wiki.expertiza.ncsu.edu/index.php/CSC/ECE_517_Spring_2016/E1738_Integrate_Simicheck_Web_Service'
    fetcher = SubmissionContentFetcher.doc_factory(url)
    expect(fetcher).to be_instance_of(WebsiteFetcher)
    expect(fetcher.instance_variable_get(:@url)).to eql(url)
  end

  it 'creates factory for google docs edit URL documentation' do
    url = 'https://docs.google.com/document/d/1-waDJtPB8VGLyubb40-X951PF9R3jdhm6Kb4ga__S0E/edit'
    fetcher = SubmissionContentFetcher.doc_factory(url)
    expect(fetcher).to be_instance_of(GoogleDocFetcher)
    expect(fetcher.instance_variable_get(:@url)).to eql(url)
  end

  it 'creates factory for google docs drive URL documentation' do
    url = 'https://drive.google.com/open?id=1Ngds9Fr4vas8n0cA-uvZDOU7VMarMfGytbC9VLc0IYI'
    fetcher = SubmissionContentFetcher.doc_factory(url)
    expect(fetcher).to be_instance_of(GoogleDocFetcher)
    expect(fetcher.instance_variable_get(:@url)).to eql(url)
  end

  it 'creates factory for github pull request code' do
    url = 'https://github.com/totallybradical/simicheck-expertiza-sandbox/pull/3'
    fetcher = SubmissionContentFetcher.code_factory(url)
    expect(fetcher).to be_instance_of(GithubPullRequestFetcher)
    expect(fetcher.instance_variable_get(:@url)).to eql(url)
  end

  it 'does not create for a bogus URL' do
    expect(SubmissionContentFetcher.doc_factory('bogus URL')).to be_nil
    expect(SubmissionContentFetcher.code_factory('another bogus URL')).to be_nil
  end
end
