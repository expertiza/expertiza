# E1626
class AssignmentGroup < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :badge_group
end