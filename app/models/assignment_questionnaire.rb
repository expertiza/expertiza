class AssignmentQuestionnaire < ApplicationRecord
  belongs_to :assignment
  belongs_to :itemnaire
  belongs_to :sign_up_topic
  has_paper_trail

  scope :retrieve_itemnaire_for_assignment, lambda { |assignment_id|
    joins(:itemnaire).where('assignment_itemnaires.assignment_id = ?', assignment_id)
  }

  # Method to find the most recent created_at record and return that record's assignment and round #
  def self.get_latest_assignment(itemnaire_id)
    record = includes(:assignment).where(itemnaire_id: itemnaire_id).order('assignments.created_at').last
    return record.assignment, record.used_in_round unless record.nil?
  end

  # E2218
  # @param assignment_id [Integer]
  # @return items corresponding to the assignment_id and review itemnaire items that are not headers
  def self.get_items_by_assignment_id(assignment_id)
    AssignmentQuestionnaire.find_by(['assignment_id = ? and itemnaire_id IN (?)',
                                     Assignment.find(assignment_id).id, ReviewQuestionnaire.select('id')])
                           .itemnaire.items.reject { |q| q.is_a?(QuestionnaireHeader) }
  end
end
