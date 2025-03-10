class Duty < ApplicationRecord
  belongs_to :assignment
  # validates name with format matching regex, length to be at least 3 and
  # same name cannot be assigned to multiple duties in particular assignment.
  validates :name,
            format: { with: /\A[^`!@#\$%\^&*+_=]+\z/,
                      message: 'Please enter a valid role name' },
            length: {
              minimum: 3,
              message: 'Role name is too short (minimum is 3 characters)'
            },
            uniqueness: {
              case_sensitive: false, scope: :assignment,
              message: 'The role "%{value}" is already present for this assignment'
            }
  validates_numericality_of :max_members_for_duty,
                            only_integer: true,
                            greater_than_or_equal_to: 1,
                            message: 'Value for max members for role is invalid'

  # E2147 : check if the duty selected is available for selection in that particular team. Checks whether
  # current duty count in the team is less than the max_members_for_duty set for that particular duty
  def can_be_assigned?(team)
    max_members_for_duty > team.participants.select { |team_member| team_member.duty_id == id }.count
  end
end
