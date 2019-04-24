class CriterionStats
  attr_accessor :mean, :median

  def initialize(criterion_hash)
    criterion_hash[:scores].sort!
    s = criterion_hash[:scores]
    @median = (s[s.length / 2].to_f + s[(s.length - 1) / 2].to_f) / 2.0
    mean = s.inject(&:+).to_f / s.length # {|sum, el| sum + el }.to_f / s.length
    max = criterion_hash[:max_score]
    min = criterion_hash[:min_score]
    normalized_mean = (mean - min.to_f) / (max.to_f - min.to_f)
    @mean = normalized_mean * 100
  end
end
