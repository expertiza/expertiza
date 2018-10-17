class TagPromptDeployment < ActiveRecord::Base
  belongs_to :tag_prompt
  belongs_to :assignment
  belongs_to :questionnaire

  def tag_prompt
    TagPrompt.find(self.tag_prompt_id)
  end

  def get_number_of_taggable_answers(user_id)
    team = Team.joins(:teams_users).where(team_users: {parent_id: self.assignment_id}, user_id: user_id)
    responses = Response.joins(:response_maps).where(response_maps: {reviewed_object_id: self.assignment.id, reviewee_id: team.id})
    questions = Question.where(questionnaire_id: self.questionnaire.id, type: self.question_type)

    unless responses.empty? or questions.empty?
      responses_ids = responses.map(&:id)
      questions_ids = questions.map(&:id)

      answers = Answer.where(question_id: questions_ids, response_id: responses_ids)

      answers = answers.where(conditions: "length(comments) < " + self.answer_length_threshold) unless self.answer_length_threshold.nil?
      return answers.count
    end
    0
  end

  def assignment_tagging_progress
    teams = Team.where(parent_id: self.assignment_id)
    questions = Question.where(questionnaire_id: self.questionnaire.id, type: self.question_type)
    questions_ids = questions.map(&:id)
    user_answer_tagging = []
    unless teams.empty? or questions.empty?
      teams.each do |team|
        if self.assignment.varying_rubrics_by_round?
          responses = []
          for round in 1..self.assignment.rounds_of_reviews
            responses += ReviewResponseMap.get_responses_for_team_round(team, round)
          end
        else
          responses = ResponseMap.get_assessments_for(team)
        end
        responses_ids = responses.map(&:id)
        answers = Answer.where(question_id: questions_ids, response_id: responses_ids)
        answers = answers.where("length(comments) > ?", self.answer_length_threshold.to_s) unless self.answer_length_threshold.nil?
        answers_ids = answers.map(&:id)
        users = TeamsUser.where(team_id: team.id).map(&:user)
        users.each do |user|
          tags = AnswerTag.where(tag_prompt_deployment_id: self.id, user_id: user.id, answer_id: answers_ids)
          tagged_answers_ids = tags.map(&:answer_id)
          percentage = answers.count == 0 ? "-" : format("%.1f", tags.count.to_f / answers.count * 100)
          not_tagged_answers = answers.where.not(id: tagged_answers_ids)
          answer_tagging = VmUserAnswerTagging.new(user, percentage, tags.count, not_tagged_answers.count, answers.count)
          user_answer_tagging.append(answer_tagging)
        end
      end
    end
    user_answer_tagging
  end
end
