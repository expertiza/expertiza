class AssignmentBadge < ActiveRecord::Base
  belongs_to :badge, foreign_key: :badge_id
  belongs_to :assignment, foreign_key: :assignment_id
end
