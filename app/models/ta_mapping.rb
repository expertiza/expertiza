class TaMapping < ActiveRecord::Base
  belongs_to :course
  belongs_to :ta
  def self.get_course_id(user_id)
    TaMapping.find_by_ta_id(user_id).course_id
  end
end
