module AssignmentStatsHelper
  def avg_data(assignment_stats)
    rounds = []
    assignment_stats.rounds.each do |r|
      criteria = []
      r.criteria.each do |c|
        criteria << c.mean
      end
      rounds << criteria
    end
    rounds
  end

  def med_data(assignment_stats)
    rounds = []
    assignment_stats.rounds.each do |r|
      criteria = []
      r.criteria.each do |c|
        criteria << c.median
      end
      rounds << criteria
    end
    rounds
  end

  def criteria_names(assignment_stats)
    rounds = []
    assignment_stats.rounds.each do |r|
      criteria = []
      (1..r.criteria.length).each do |c|
        criteria << "Criterion #{c}"
      end
      rounds << criteria
    end
    rounds
  end
  def round_names(assignment_stats)
    names = []
    (1..assignment_stats.rounds.length).each do |r|
      names << "Round #{r}"
    end
    names
  end
end