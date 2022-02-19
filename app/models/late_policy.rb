class LatePolicy < ApplicationRecord
  belongs_to :user

  # has_many :assignments
  has_many :assignments, dependent: :nullify

  validates :policy_name, presence: true
  validates :instructor_id, presence: true
  validates :max_penalty, presence: true
  validates :penalty_per_unit, presence: true
  validates :penalty_unit, presence: true

  validates :max_penalty, numericality: { greater_than: 0 }
  validates :max_penalty, numericality: { less_than: 100 }
  validates :penalty_per_unit, numericality: { greater_than: 0 }

  validates :policy_name, format: { with: /\A[A-Za-z0-9][A-Za-z0-9\s'._-]+\z/i }

  # attr_accessible :penalty_per_unit, :max_penalty, :penalty_unit, :times_used, :policy_name

  # method to check whether the policy name given as a parameter already exists under the current instructor id
  # it return true if there's another policy with the same name under current instructor else false
  def self.check_policy_with_same_name(late_policy_name, instructor_id)
    @policy = LatePolicy.where(policy_name: late_policy_name)
    if @policy.present?
      @policy.each do |p|
        return true if p.instructor_id == instructor_id
      end
    end
    false
  end

  # this method updates all the penalty objects which uses the late policy which is passed as a parameter
  # whenever a policy is updated, all the existing penalty objects needs to be updated according to new policy
  def self.update_calculated_penalty_objects(late_policy)
    @penalty_objs = CalculatedPenalty.all
    @penalty_objs.each do |pen|
      @participant = AssignmentParticipant.find(pen.participant_id)
      @assignment = @participant.assignment
      next unless @assignment.late_policy_id == late_policy.id

      @penalties = calculate_penalty(pen.participant_id)
      @total_penalty = (@penalties[:submission] + @penalties[:review] + @penalties[:meta_review])
      if pen.deadline_type_id.to_i == 1
        # pen.update_attribute(:penalty_points, @penalties[:submission])
        pen.update(penalty_points: @penalties[:submission])
      elsif pen.deadline_type_id.to_i == 2
        # pen.update_attribute(:penalty_points, @penalties[:review])
        pen.update(penalty_points: @penalties[:review])
      elsif pen.deadline_type_id.to_i == 5
        # pen.update_attribute(:penalty_points, @penalties[:meta_review])
        pen.update(penalty_points: @penalties[:meta_review])
      end
    end
  end
end
