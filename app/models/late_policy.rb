class LatePolicy < ActiveRecord::Base

  belongs_to :user

  has_many :assignments

  validates_presence_of :policy_name
  validates_presence_of :instructor_id
  validates_presence_of :max_penalty
  validates_presence_of :penalty_per_unit

  validates_numericality_of :max_penalty, :greater_than => 0
  validates_numericality_of :max_penalty, :less_than => 50
  validates_numericality_of :penalty_per_unit, :greater_than => 0

  validates_format_of :policy_name, :with => /^[A-Za-z0-9][A-Za-z0-9\s'._-]+$/i

end
