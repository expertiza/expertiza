require 'rspec'

describe 'Parse wiki content' do
  text = Metric.parseWiki('http://wiki.expertiza.ncsu.edu/index.php/CSC/ECE_517_Fall_2017/E1790_Text_metrics')
  it 'should parse wiki from given URL' do
    expect(text).not_to be_nil
  end

  it 'should be a valid string' do
    expect(text).to be_a_kind_of(String)
  end
end

describe 'Analyze text readability' do
  result = Metric.analyzeText('In this final project “Text Metric”, first, we will integrate a couple of external sources such as Github, Trello to fetch information. Second, we will introduce the idea of "Readability." To get the level of readability, we will import the content of write-ups written by students, split the sentences to get the number of sentences, the number of words, etc., and then we calculate the indices by using these numbers and formulas.')
  it 'should analyze the given text and return a hash' do
    expect(result).not_to be_nil
    expect(result).to be_a_kind_of(Hash)
  end

  it 'should contain a scores hash' do
    expect(result["scores"]).not_to be_nil
    expect(result["scores"]).to be_a_kind_of(Hash)
    expect(result["scores"].empty?).to be_falsey
  end

  it 'should contain valid scores' do
    result["scores"].each_pair{|k, v|
      expect(k).to be_a_kind_of(String)
      expect(v).to be_a_kind_of(Numeric)
    }
  end
end