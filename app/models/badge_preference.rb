class BadgePreference < ActiveRecord::Base
  validates :instructor_id, :presence => true, length: {minimum: 11, maximum: 11}
  validates :preference, :presence => true
end
