class AssignmentQuestionnaire < ApplicationRecord
  belongs_to :assignment
  belongs_to :questionnaire
  belongs_to :sign_up_topic
  has_paper_trail

  scope :retrieve_questionnaire_for_assignment, lambda { |assignment_id|
    joins(:questionnaire).where('assignment_questionnaires.assignment_id = ?', assignment_id)
  }

  # Method to find the most recent created_at record and return that record's assignment and round #
  def self.get_latest_assignment(questionnaire_id)
    record = includes(:assignment).where(questionnaire_id: questionnaire_id).order('assignments.created_at').last
    return record.assignment, record.used_in_round unless record.nil?
  end

  # E2218
  # @param assignment_id [Integer]
  # @return questions corresponding to the assignment_id and review questionnaire questions that are not headers
  def self.get_questions_by_assignment_id(assignment_id)
    AssignmentQuestionnaire.find_by(['assignment_id = ? and questionnaire_id IN (?)',
                                     Assignment.find(assignment_id).id, ReviewQuestionnaire.select('id')])
                           .questionnaire.questions.reject { |q| q.is_a?(QuestionnaireHeader) }
  end
end
