class ReviewRoundStats
  attr_accessor :criteria

  def initialize(criteria_hash, question_id_index_hash)
    @criteria = []
    criteria_hash.each do |question, criterion_hash|
      @criteria[question_id_index_hash[question]] = CriterionStats.new(criterion_hash) unless question.nil? || question_id_index_hash[question].nil?
    end
  end

  def means
    @criteria.map(&:mean)
  end

  def medians
    @criteria.map(&:median)
  end

  def number_of_criteria
    @criteria.length
  end
end
