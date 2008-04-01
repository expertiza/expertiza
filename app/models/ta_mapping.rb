class TaMapping < ActiveRecord::Base
  belongs_to :course
  belongs_to :ta
end
