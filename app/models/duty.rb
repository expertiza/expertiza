class Duty < ActiveRecord::Base
  validates :duty_name , :presence => true
end
