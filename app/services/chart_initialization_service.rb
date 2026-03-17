class ChartInitializationService
    attr_reader :reviewer, :num_rounds, :all_reviewers_avg_vol_per_round, :all_reviewers_overall_avg_vol
  
    def initialize(reviewer, num_rounds, all_reviewers_avg_vol_per_round, all_reviewers_overall_avg_vol)
      @reviewer = reviewer
      @num_rounds = num_rounds
      @all_reviewers_avg_vol_per_round = all_reviewers_avg_vol_per_round
      @all_reviewers_overall_avg_vol = all_reviewers_overall_avg_vol
    end
  
    # Initializes chart elements (labels, reviewer data, and all reviewers data)
    def initialize_chart_elements
      round = 0
      labels = []
      reviewer_data = []
      all_reviewers_data = []
  
      # Display avg volume for all reviewers per round
      @num_rounds.times do |rnd|
        next unless @all_reviewers_avg_vol_per_round[rnd] > 0
  
        round += 1
        labels.push round
        reviewer_data.push @reviewer.avg_vol_per_round[rnd]
        all_reviewers_data.push @all_reviewers_avg_vol_per_round[rnd]
      end
  
      labels.push 'Total'
      reviewer_data.push @reviewer.overall_avg_vol
      all_reviewers_data.push @all_reviewers_overall_avg_vol
  
      [labels, reviewer_data, all_reviewers_data]
    end
  end
