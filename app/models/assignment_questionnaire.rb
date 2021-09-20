class AssignmentQuestionnaire < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :questionnaire
  belongs_to :sign_up_topic
  has_paper_trail

  scope :retrieve_questionnaire_for_assignment, lambda {|assignment_id|
    joins(:questionnaire).where('assignment_questionnaires.assignment_id = ?', assignment_id)
  }

  #Method to find the most recent created_at record and return that record's assignment and round #
  def self.get_latest_assignment(questionnaire_id)
    record = self.includes(:assignment).where(questionnaire_id: questionnaire_id).order("assignments.created_at").last
    unless record.nil?
      return record.assignment, record.used_in_round
    end
  end
end
