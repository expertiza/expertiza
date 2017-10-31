class TagPromptDeployment < ActiveRecord::Base
  belongs_to :tag_prompt
  belongs_to :assignment
  belongs_to :questionnaire

  def tag_prompt
    return TagPrompt.find(self.tag_prompt_id)
  end

  def get_number_of_taggable_answers(user_id)
    team = Team.joins(:teams_users).where(team_users:{parent_id: self.assignment_id}, user_id:user_id)
    responses = Response.joins(:response_maps).where(response_maps: {reviewed_object_id: self.assignment.id, reviewee_id: team.id})
    questions = Question.where(questionnaire_id: self.questionnaire.id, type: self.question_type)

    if not (responses.empty? or questions.empty?)
      responses_ids = responses.map { |r| r.id }
      questions_ids = questions.map { |q| q.id }

      answers = Answer.where(question_id:questions_ids, response_id: responses_ids)

      if not self.answer_length_threshold.nil?
        answers = answers.where(:conditions => "length(comments) < " + self.answer_length_threshold)
      end
      return answers.count
    end
    return 0
  end

  def assignment_tagging_progress
    teams = Team.where(parent_id: self.assignment_id)
    questions = Question.where(questionnaire_id: self.questionnaire.id, type: self.question_type)
    questions_ids = questions.map { |q| q.id }
    user_answer_tagging = []
    if !(teams.empty? or questions.empty?)
      teams.each do |team|
        responses = Response.joins("JOIN response_maps ON response_maps.id = responses.map_id")
                        .where(response_maps: {reviewed_object_id: self.assignment.id, reviewee_id: team.id})
        responses_ids = responses.map { |r| r.id }
        answers = Answer.where(question_id: questions_ids, response_id: responses_ids)
        if !self.answer_length_threshold.nil?
          answers = answers.where("length(comments) > ?", self.answer_length_threshold.to_s)
        end
        users = TeamsUser.where(team_id: team.id).map { |tu| tu.user }
        users.each do |user|
          tags = AnswerTag.where(tag_prompt_deployment_id: self.id, user_id: user.id)
          tagged_answers_ids = tags.map{ |tag| tag.answer_id }
          percentage = answers.count == 0 ? "-" : sprintf("%.1f", tags.count.to_f / answers.count * 100)
          not_tagged_answers = answers.where.not(id: tagged_answers_ids)
          answer_tagging = VmUserAnswerTagging.new(user, percentage, tags.count, not_tagged_answers.count, answers.count)
          user_answer_tagging.append(answer_tagging)
        end
      end
    end
    return user_answer_tagging
  end
end
