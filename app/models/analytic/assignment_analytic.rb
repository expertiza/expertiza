require 'analytic/assignment_team_analytic'
module AssignmentAnalytic
  #====== general statistics ======#
  def num_participants
    participants.count
  end

  def num_teams
    teams.count
  end

  #==== number of team reviews ====#
  def total_num_team_reviews
    team_review_counts.inject(:+)
  end

  def average_num_team_reviews
    if num_teams == 0
      0
    else
      total_num_team_reviews.to_f / num_teams
    end
  end

  def max_num_team_reviews
    team_review_counts.max
  end

  def min_num_team_reviews
    team_review_counts.min
  end

  #=========== score ==============#
  def average_team_score
    if num_teams == 0
      0
    else
      team_scores.inject(:+).to_f / num_teams
    end
  end

  def max_team_score
    team_scores.max
  end

  def min_team_score
    team_scores.min
  end

  def team_review_counts
    list = []
    teams.each do |team|
      list << team.num_reviews
    end

    if list.empty?
      [0]
    else
      list
    end
  end

  def team_scores
    list = []
    teams.each do |team|
      list << team.average_review_score
    end
    if list.empty?
      [0]
    else
      list
    end
  end

  # return all questionnaire types associated this assignment
  def questionnaire_types
    questionnaire_type_list = []
    questionnaires.each do |questionnaire|
      questionnaire_type_list << questionnaire.type unless questionnaires.include?(questionnaire.type)
    end
    questionnaire_type_list
  end

  # return questionnaire of a type related to the assignment
  # assumptions: only 1 questionnaire of each type exist which should be the case
  def questionnaire_of_type(type_name_in_string)
    questionnaires.each do |questionnaire|
      return questionnaire if questionnaire.type == type_name_in_string
    end
  end

  # helper function do to verify the assumption made above
  def self.questionnaire_unique?
    find_each do |assignment|
      assignment.questionnaire_types.each do |questionnaire_type|
        questionnaire_list = []
        assignment.questionnaires.each do |questionnaire|
          questionnaire_list << questionnaire if questionnaire.type == questionnaire_type
          return false if questionnaire_list.count > 1
        end
      end
    end
    true
  end

  def has_review_questionnaire?
    questionnaire_types.include?('ReviewQuestionnaire')
  end

  def review_questionnaire
    questionnaire_of_type('ReviewQuestionnaire')
  end
end
