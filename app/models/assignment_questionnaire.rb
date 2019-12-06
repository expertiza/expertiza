class AssignmentQuestionnaire < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :questionnaire
  has_paper_trail

  scope :retrieve_questionnaire_for_assignment, lambda {|assignment_id|
    joins(:questionnaire).where('assignment_questionnaires.assignment_id = ?', assignment_id)
  }

  def self.get_rounds(assignment_id)
    assignment = self.includes(:assignment).where(assignment_id:assignment_id).last.assignment
    records = self.where(assignment_id:assignment_id)
    rounds = []
    records.each do |record|
      rounds.push record.used_in_round
    end
    return assignment, rounds
  end
end
