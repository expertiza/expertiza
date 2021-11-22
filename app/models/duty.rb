class Duty < ActiveRecord::Base
  belongs_to :assignment

  def can_be_assigned?(team)
    self.max_members_for_role > team.participants.select{|team_member| team_member.duty_id == self.id}.count
  end
end