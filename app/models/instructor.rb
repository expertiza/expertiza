
class Instructor < User

  QUESTIONNAIRE = [['My questionnaires','list_mine'],
                   ['All public questionnaires','list_all']]

  SIGNUPSHEET = [['My signups','list_mine'],
                 ['All public signups','list_all']]

  ASSIGNMENT = [['My assignments','list_mine'],
                ['All public assignments','list_all']]

  def list_all(object_type, user_id)
    object_type.where(["instructor_id = ? OR private = 0", user_id])
  end

  def list_mine(object_type, user_id)
    object_type.where(["instructor_id = ?", user_id])
  end

  def get(object_type, id, user_id)
    object_type.where(["id = ? AND (instructor_id = ? OR private = 0)", id, user_id]).first
  end

  def self.get_my_tas(instructor_id)
    instructor = Instructor.find(instructor_id)
    courses = Course.where(instructor_id: instructor_id)
    ta_ids = Array.new
    courses.each do |course|
      ta_mappings = TaMapping.where(course_id: course.id)
      ta_mappings.each { |mapping| ta_ids << mapping.ta_id } if !ta_mappings.empty?
    end
    ta_ids
  end

end
