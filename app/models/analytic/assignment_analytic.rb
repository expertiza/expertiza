require 'analytic/assignment_team_analytic'
module AssignmentAnalytic
  #====== general statistics ======#
  def num_participants
    self.participants.count
  end

  def num_teams
    self.teams.count
  end

  #==== number of team reviews ====#
  def total_num_team_reviews
    team_review_counts.inject(:+)
  end

  def average_num_team_reviews
    if num_teams == 0
      0
    else
      total_num_team_reviews.to_f/num_teams
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
      self.team_scores.inject(:+).to_f/num_teams
    end
  end

  def max_team_score
    self.team_scores.max
  end

  def min_team_score
    self.team_scores.min
  end


  def team_review_counts
    list = Array.new
    self.teams.each do |team|
      list << team.num_reviews
    end

    if (list.empty?)
      [0]
    else
      list
    end
  end

  def team_scores
    list = Array.new
    self.teams.each do |team|
      list << team.average_review_score
    end
    if (list.empty?)
      [0]
    else
      list
    end
  end


  #return students that are participating in the assignment
  #assumptions: all team_participant for all of the teams are in assignment participant
  #def students
  #  list = Array.new
  #  self.participants.each do |participant|
  #    if participant.user.role_id == Role.student.id
  #      list << participant
  #    end
  #  end
  #  list
  #end

  #return all questionnaire types associated this assignment
  def questionnaire_types
    questionnaire_type_list = Array.new
    self.questionnaires.each do |questionnaire|
      if !self.questionnaires.include?(questionnaire.type)
        questionnaire_type_list << questionnaire.type
      end
    end
    questionnaire_type_list
  end

  #return questionnaire of a type related to the assignment
  #assumptions: only 1 questionnaire of each type exist which should be the case
  def questionnaire_of_type(type_name_in_string)
    self.questionnaires.each do |questionnaire|
      if questionnaire.type == type_name_in_string
        return questionnaire
      end
    end
  end

  #helper function do to verify the assumption made above
  def self.questionnaire_unique?
    self.find_each do |assignment|
      assignment.questionnaire_types.each do |questionnaire_type|
        questionnaire_list = Array.new
        assignment.questionnaires.each do |questionnaire|
          if questionnaire.type == questionnaire_type
            questionnaire_list << questionnaire
          end
          if questionnaire_list.count > 1
            return false
          end
        end
      end
    end
    return true
  end

  def has_review_questionnaire?
    questionnaire_types.include?("ReviewQuestionnaire")
  end

  def review_questionnaire
    questionnaire_of_type("ReviewQuestionnaire")
  end


  #====unused in version 1=========#
  #========== word count ==========#
  #def review_word_counts
  #  list = Array.new
  #  self.teams.each do |team|
  #    list << team.total_word_count
  #  end
  #  if (list.empty?)
  #    [0]
  #  else
  #    list
  #  end
  #end
  #
  #def total_review_word_count
  #  review_word_counts.inject(:+)
  #end
  #
  #def average_review_word_count
  #  if num_teams == 0
  #    0
  #  end
  #  total_review_word_count.to_f/num_teams
  #end
  #
  #def max_review_word_count
  #  review_word_counts.max
  #end
  #
  #def min_review_word_count
  #  review_word_counts.min
  #end

  #========== character count ==========#
  #def review_character_counts
  #  list = Array.new
  #  self.teams.each do |team|
  #    list << team.total_character_count
  #  end
  #  if (list.empty?)
  #    [0]
  #  else
  #    list
  #  end
  #end
  #
  #def total_review_character_count
  #  review_character_counts.inject(:+)
  #end
  #
  #def average_review_character_count
  #  if num_teams == 0
  #    0
  #  end
  #  total_review_character_count.to_f/num_teams
  #end
  #
  #def max_review_character_count
  #  review_character_counts.max
  #end
  #
  #def min_review_character_count
  #  review_character_counts.min
  #end

  #def num_students
  #  self.students.count
  #end

end
