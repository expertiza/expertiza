# E1626
class Badge < ActiveRecord::Base
  has_many :badge_groups, :class_name => 'BadgeGroup', :foreign_key => 'badge_id'

end
