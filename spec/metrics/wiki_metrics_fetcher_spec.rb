require 'rspec'

describe 'WikiMetricsFetcher before fetch' do
  params = { :url => "http://wiki.expertiza.ncsu.edu/index.php/CSC/ECE_517_Fall_2017/E1790_Text_metrics"}
  pr = WikiMetricsFetcher.new(params)
  it "should not be loaded before fetch" do
    expect(pr.is_loaded?).to be false
  end

  it "should support a valid url" do
    expect(WikiMetricsFetcher.supports_url?(params[:url])).to be true
  end

  it "should not support an invalid url" do
    expect(WikiMetricsFetcher.supports_url?("https://trello.com/b/rU4qGAt4/517-test-board")).to be false
  end
end

describe 'WikiMetricsFetcher after fetch' do
  params = { :url => "http://wiki.expertiza.ncsu.edu/index.php/CSC/ECE_517_Fall_2017/E1790_Text_metrics"}
  pr = WikiMetricsFetcher.new(params)
  pr.fetch_content
  it "should be loaded after fetch" do
    expect(pr.is_loaded?).to be true
  end

  it 'should parse wiki from given URL' do
    expect(pr.text).not_to be_nil
  end

  it 'should get a valid string as text' do
    expect(pr.text).to be_a_kind_of(String)
  end

  it 'should analyze the given text and return a hash' do
    expect(pr.readability).not_to be_nil
    expect(pr.readability).to be_a_kind_of(Hash)
  end

  it 'should contain a scores hash' do
    expect(pr.readability["scores"]).not_to be_nil
    expect(pr.readability["scores"]).to be_a_kind_of(Hash)
    expect(pr.readability["scores"].empty?).to be_falsey
  end

  it 'should contain valid scores' do
    pr.readability["scores"].each_pair{|k, v|
      expect(k).to be_a_kind_of(String)
      expect(v).to be_a_kind_of(Numeric)
    }
  end
end