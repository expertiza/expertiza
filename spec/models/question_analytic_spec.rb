describe QuestionAnalytic do
  describe '#unique_character_count' do
  	it 'counts the number of unique characters - case insensitive' do
  		text = 'Aa'
  		include QuestionAnalytic
  		allow(QuestionAnalytic).to receive(:txt).and_return(text)
  		expect(QuestionAnalytic.unique_character_count).to eq(1)
  	end
  	it 'counts the number of unique characters' do
  		text = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  		include QuestionAnalytic
  		allow(QuestionAnalytic).to receive(:txt).and_return(text)
  		expect(QuestionAnalytic.unique_character_count).to eq(26)
  	end
  end
end