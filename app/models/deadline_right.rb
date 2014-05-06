class DeadlineRight < ActiveRecord::Base

  validates_length_of :name, :maximum => 32, :allow_blank => false
end
