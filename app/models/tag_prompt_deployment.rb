class TagPromptDeployment < ActiveRecord::Base
  belongs_to :tag_prompt
  belongs_to :assignment
  belongs_to :questionnaire

  require "time"

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
        responses_ids = team.all_responses.map(&:id)
        answers = Answer.where(question_id: questions_ids, response_id: responses_ids)
        answers = answers.where("length(comments) > ?", self.answer_length_threshold.to_s) unless self.answer_length_threshold.nil?
        answers_inferred_by_ml = answers.select {|answer| ReviewMetricsQuery.confident?(self.id, answer.id) }
        taggable_answers = answers - answers_inferred_by_ml
        users = TeamsUser.where(team_id: team.id).map(&:user)
        users.each do |user|
          tags = AnswerTag.where(tag_prompt_deployment_id: self.id, user_id: user.id, answer_id: taggable_answers.map(&:id))

          # E2082 Track_Time_Between_Successive_Tag_Assignments
          # Extract time where each tag is generated / modified
          tag_updated_times = tags.map(&:updated_at)
          # tag_updated_times.sort_by{|time_string| Time.parse(time_string)}.reverse
          tag_updated_times.sort_by {|time_string| time_string }.reverse
          tag_update_intervals = []
          tag_updated_times.each_index do |i|
            next if i.zero?
            tag_update_intervals.append(tag_updated_times[i] - tag_updated_times[i - 1])
          end

          percentage = taggable_answers.count.zero? ? "-" : format("%.1f", tags.count.to_f / taggable_answers.count * 100)
          not_tagged_answers = taggable_answers.reject {|a| tags.map(&:answer_id).include?(a.id) }
          answer_tagging = VmUserAnswerTagging.new(user, answers.count, answers_inferred_by_ml.count, taggable_answers.count, tags.count, not_tagged_answers.count, percentage, tag_update_intervals)
          user_answer_tagging.append(answer_tagging)
        end
      end
    end
    user_answer_tagging
  end
end
