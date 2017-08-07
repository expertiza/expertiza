class TaMapping < ActiveRecord::Base
  belongs_to :course
  belongs_to :ta
  has_paper_trail
  def self.get_course_id(user_id)
    TaMapping.find_by_ta_id(user_id).course_id
  end

  def self.get_courses(user_id)
    if !user_id.is_a? Integer
      flash[:error] = "Illegal parameter."
    else
      Course.where(["id=?", TaMapping.find_by_ta_id(user_id).course_id])
    end
  end
end
