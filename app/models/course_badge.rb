class CourseBadge < ActiveRecord::Base
  belongs_to :badge
  belongs_to :course
end
