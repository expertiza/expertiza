class Duty < ActiveRecord::Base
  belongs_to :assignment
  validates :duty_name, format: { with: /\A[^0-9`!@#\$%\^&*+_=]+\z/ }, length: { minimum: 3 }, presence: true
  validates_numericality_of :max_members_for_role, :only_integer => true, :greater_than_or_equal_to => 1, presence: true

  # E2147 : check if the duty selected is available for selection in that particular team. Checks whether current duty count in
  # the team is less than the max_members_for_role set for that particular duty
  def can_be_assigned?(team)
    self.max_members_for_role > team.participants.select{|team_member| team_member.duty_id == self.id}.count
  end
end