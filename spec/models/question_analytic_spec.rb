class DummyClass 
	attr_accessor :txt
	include 'analytic/question_analytic'
	
	def initialize(txt)
		@txt = txt
	end
 	
 	def uni_character_count
 		QuestionAnalytic.unique_character_count
 	end
end

describe QuestionAnalytic do
  describe '#unique_character_count' do
  	it 'counts the number of unique characters - case insensitive' do
  		text = 'Aa'
  		dc = DummyClass.new(text)
  		expect(dc.uni_character_count).to eq(1)
  	end
  	it 'counts the number of unique characters' do
  		text = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  		dc = DummyClass.new(text)
  		expect(dc.uni_character_count).to eq(26)
  	end
  end
end