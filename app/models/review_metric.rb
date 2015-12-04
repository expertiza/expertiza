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

	@add_comment = Response.find_by_id(self.response_id).additional_comment
	
	if @add_comment
		@answer[0][:comments] = @answer[0][:comments] + ". " + @add_comment
	end

    answers = ""
	(0..@answer.count-1).each do |i|
	    sentences = @answer[i][:comments].split('.')
	    #for each sentence in the comment, count full sentences
	    sentences.each do |sentence|
	        word_count = sentence.scan(/[\w']+/).count
	        if word_count > 7
	        	@complete_count = @complete_count + 1
	        end
	        @total_word_count += word_count
	    end
	    answers = answers + "." + @answer[i][:comments]
	end

	@diff_word_count = answers.scan(/[\w']+/).uniq.count

	#checks for offensive words in the answers by comparing with the offensive_words dictionary
	offensive_words.each { |key, word|
		(0..@answer.count-1).each do |i|
			@answer[i][:comments].scan(/[\w']+/).each do |word|
				if word.eql?key.to_s
					@offensive_count = @offensive_count + 1
				end
			end
		end
			}

	suggestion_words.each { |key, word|
		(0..@answer.count-1).each do |i|
			@temp_val = 0
			@answer[i][:comments].scan(/[\w']+/).each do |word|
				if word.eql?key.to_s
					@temp_val = 1
				end
			end
			if @temp_val == 1
				@suggestion_count = @suggestion_count + 1
			end
		end
	}

	error_words.each { |key, word|
		(0..@answer.count-1).each do |i|
			@temp_val = 0
			@answer[i][:comments].scan(/[\w']+/).each do |word|
				if word.eql?key.to_s
					@temp_val = 1
				end
			end
			if @temp_val == 1
				@error_count = @error_count + 1
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
