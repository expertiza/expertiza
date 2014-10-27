# == Schema Information
#
# Table name: late_policies
#
#  id               :integer          not null, primary key
#  penalty_per_unit :float
#  max_penalty      :integer          default(0), not null
#  penalty_unit     :string(255)      not null
#  times_used       :integer          default(0), not null
#  instructor_id    :integer          not null
#  policy_name      :string(255)      not null
#

class LatePolicy < ActiveRecord::Base
  belongs_to :due_date
end
