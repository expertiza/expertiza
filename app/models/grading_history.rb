class GradingHistory < ActiveRecord::Base
  belongs_to :instructor
  belongs_to :assignment
end