class Duty < ActiveRecord::Base
  belongs_to :assignment
  validates :duty_name, format: { with: /\A[^0-9`!@#\$%\^&*+_=]+\z/ }, length: { minimum: 3 }, presence: true
  validates_numericality_of :max_duty_limit, :only_integer => true, :greater_than_or_equal_to => 1, presence: true

  def can_be_assigned?(team)
    self.max_duty_limit > team.participants.select{|team_member| team_member.duty_id == self.id}.count
  end
end