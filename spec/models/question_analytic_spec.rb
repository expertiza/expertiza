class DummyClass 
	attr_accessor :txt
	require_relative "/app/models/analytic/question_analytic.rb"
	
	def initialize(txt)
		@txt = txt
	end
 	
 	def unique_character_count
 		unique_character_count
 	end
end

describe QuestionAnalytic do
  describe '#unique_character_count' do
  	it 'counts the number of unique characters - case insensitive' do
  		text = 'Aa'
  		dc = DummyClass.new(text)
  		expect(dc.unique_character_count).to eq(1)
  	end
  	it 'counts the number of unique characters' do
  		text = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  		dc = DummyClass.new(text)
  		expect(dc.unique_character_count).to eq(26)
  	end
  end
end