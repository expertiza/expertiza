class AssignmentBadge < ActiveRecord::Base
  belongs_to :badge
  belongs_to :assignment
end
