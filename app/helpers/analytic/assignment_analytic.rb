require 'assignment_team_analytic'
module AssignmentAnalytic
  #====== helper functions ========#
  #return students that are participating in the assignment
  #assumptions: all team_participant for all of the teams are in assignment participant
  def students
    students = Array.new
    self.participants.each do |participant|
      if participant.user.role_id == Role.student.id
        students << participant
      end
    end
    student
  end

  #return all questionnaire types associated this assignment
  def questionnaire_types
    questionnaire_type_list = Array.new
    self.questionnaires.each do |questionnaire|
      if !questionnaires.include?(questionnaire.type)
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
    self.all.each do |assignment|
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





  #====== general statistics ======#
  def num_participants
    self.participants.count
  end

  def num_students
    self.students.count
  end

  def num_teams
    self.teams.count
  end

  def num_team_reviews
    sum = 0
    self.teams.each do |team|
      sum += team.num_reviews
    end
    sum
  end

  #===== questionnaire related methods ====#
  def num_questions_in_questionnaire
    if questionnaire_types.include?("ReviewQuestionnaire")
      return questionnaire_of_type("ReviewQuestionnaire").questions.count
    else
      return 0
    end
  end

  #======== score related methods =========#
  def team_review_scores
    scores = Array.new
    self.teams.each do |team|
      scores << (team.review_scores.inject(:+)/team.responses.count)
    end
    scores
  end

  def average_team_review_score
    self.team_review_scores.inject(:+).to_f/num_teams
  end

  def max_review_score
    self.team_review_scores.max
  end

  def min_review_score
    self.team_review_scores.min
  end

  #===== total review word count related methods ====#
  def average_review_word_count

  end

  def max_review_word_count

  end

  def min_review_word_count

  end





end
