class ReviewMetric < ActiveRecord::Base

  def calulate_metric
	
	@answer = Answer.where ("response_id = #{self.response_id}")
	offensive_words = {:anal => "offensive", :anus => "offensive", :arse => "offensive",:ass => "offensive", :ballsack => "offensive"}
	suggestion_words = {:should => "suggestion", :advise => "suggestion", :recommend => "suggestion", :recommendable => "suggestion", :recommendation => "suggestion", :try => "suggestion" }
	error_words = {:wrong => "error", :error => "error", :problem => "error", :issue => "error", :problematic => "error", :incorrect => "error"}
	@total_word_count = 0
	@offensive_count = 0
	@suggestion_count = 0
	@diff_word_count = 0
	@error_count = 0
	@complete_count = 0


	(0..@answer.count-1).each do |i|
	@sentence_count = @answer[i][:comments].split.count
		if @sentence_count > 8 and @answer[i][:comments][-1,1].eql?"."
			@complete_count = @complete_count + 1
		end
	@total_word_count += @sentence_count
	end

	#checks for offensive words in the answers by comparing with the offensive_words dictionary
	offensive_words.each { |key, word|
		(0..@answer.count-1).each do |i|
			@answer[i][:comments].split.each do |word|
				if word.eql?key.to_s
					@offensive_count = @offensive_count + 1
				end
				@diff_word_count = @answer[i][:comments].split.uniq.count
			end
		end
			}

	suggestion_words.each { |key, word|
		(0..@answer.count-1).each do |i|
			@answer[i][:comments].split.each do |word|
				if word.eql?key.to_s
					@suggestion_count = @suggestion_count + 1
				end
				end
		end
	}

	error_words.each { |key, word|
		(0..@answer.count-1).each do |i|
			@answer[i][:comments].split.each do |word|
				if word.eql?key.to_s
				@error_count = @error_count + 1
				end
			end
		end
	}


	self.total_word_count = @total_word_count
	self.diff_word_count = @diff_word_count
	self.suggestion_count = @suggestion_count
	self.error_count = @error_count
	self.offensive_count = @offensive_count
	self.complete_count = @complete_count
	self.save
  end

end
