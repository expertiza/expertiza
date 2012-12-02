class DeadlineType < ActiveRecord::Base
  has_many :penalties_calculated
end
