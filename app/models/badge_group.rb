# E1626
class BadgeGroup < ActiveRecord::Base
  belongs_to :badge
  belongs_to :course
end
