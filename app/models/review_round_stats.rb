class ReviewRoundStats
  attr_accessor :criteria
  def initialize(criteria_hash, question_id_index_hash)
    @criteria = []
    criteria_hash.each do |question, criterion_hash|
      @criteria[question_id_index_hash[question]] = CriterionStats.new(criterion_hash)
    end

  end
end
