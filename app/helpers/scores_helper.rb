module ScoresHelper

  def get_scores(questions)
      scores = Hash.new

      scores[:participants] = Hash.new
      self.participants.each{
        | participant |
        scores[:participants][participant.id.to_s.to_sym] = Hash.new
        scores[:participants][participant.id.to_s.to_sym][:participant] = participant
        questionnaires.each{
          | questionnaire |
          scores[:participants][participant.id.to_s.to_sym][questionnaire.symbol] = Hash.new
          scores[:participants][participant.id.to_s.to_sym][questionnaire.symbol][:assessments] = questionnaire.get_assessments_for(participant)
          scores[:participants][participant.id.to_s.to_sym][questionnaire.symbol][:scores] = Score.compute_scores(scores[:participants][participant.id.to_s.to_sym][questionnaire.symbol][:assessments], questions[questionnaire.symbol])
        }
        scores[:participants][participant.id.to_s.to_sym][:total_score] = compute_total_score(scores[:participants][participant.id.to_s.to_sym])
      }

      if self.team_assignment
        scores[:teams] = Hash.new
        index = 0
        self.teams.each{
          | team |
          scores[:teams][index.to_s.to_sym] = Hash.new
          scores[:teams][index.to_s.to_sym][:team] = team
          assessments = TeamReviewResponseMap.get_assessments_for(team)
          scores[:teams][index.to_s.to_sym][:scores] = Score.compute_scores(assessments, questions[:review])
          index += 1
        }
      end
      return scores
    end

    def compute_scores
      scores = Hash.new
      questionnaires = self.questionnaires

      self.participants.each{
        | participant |
        pScore = Hash.new
        pScore[:id] = participant.id


        scores << pScore
      }
    end


# parameterized by questionnaire
  def get_max_score_possible(questionnaire)
    max = 0
    sum_of_weights = 0
    num_questions = 0
    questionnaire.questions.each { |question| #type identifies the type of questionnaire
      sum_of_weights += question.weight
      num_questions+=1
    }
    max = num_questions * questionnaire.max_question_score * sum_of_weights
    return max, sum_of_weights
  end


  # Compute total score for this assignment by summing the scores given on all questionnaires.
  # Only scores passed in are included in this sum.
  def compute_total_score(scores)
    total = 0
    self.questionnaires.each do |questionnaire|
      total += questionnaire.get_weighted_score(self, scores)
    end
    return total
  end


end