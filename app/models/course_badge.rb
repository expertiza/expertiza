class CourseBadge < ActiveRecord::Base
  belongs_to :badge
  belongs_to :assignment
  has_many :nominations
end
