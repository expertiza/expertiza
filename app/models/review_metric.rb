class ReviewMetric < ActiveRecord::Base

  def calulate_metric
	
	@answer = Answer.where ("response_id = #{self.response_id}")
	@count = 0 	
	(0..@answer.count-1).each do |i|
	@count += @answer[i][:comments].split.count
	end
	self.total_word_count = @count
	self.diff_word_count = 0
	self.suggestion_count = 0
	self.error_count = 0
	self.offensive_count = 0
	self.complete_count = 0
	self.save
  end

end
