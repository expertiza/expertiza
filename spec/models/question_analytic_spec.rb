class DummyClass 
	attr_accessor :txt
	require 'analytic/question_analytic'
	include QuestionAnalytic
	
	def initialize(txt)
		@txt = txt
	end
 	
 	def uni_character_count
 	  unique_character_count
 	end

 	def char_count
 		character_count
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
  describe '#character_count' do
  	it 'counts the number of characters in a string' do
  		text = 'ABCABCabcabc'
  		dc = DummyClass.new(text)
  		expect(dc.char_count).to eq(18)
  	end
  end
end