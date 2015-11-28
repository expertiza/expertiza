class ReviewMetric < ActiveRecord::Base

  def calulate_metric
	self.total_word_count = 0
	self.diff_word_count = 0
	self.suggestion_count = 0
	self.error_count = 0
	self.offensive_count = 0
	self.complete_count = 0
	self.save
  end

end
