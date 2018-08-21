class BadgeAwardingRule < ActiveRecord::Base
  belongs_to :course_badge
  belongs_to :question
end
