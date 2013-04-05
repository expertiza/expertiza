require File.dirname(__FILE__) + '/../test_helper'

class CourseTest < ActiveSupport::TestCase
  fixtures :course,:participants,:assignments,:users,:roles

  def setup
    @course_participant = participants(:par5)
    @assignment_participant = participants(:par0)
    @assignment = assignments(:assignment0)
    @student1 = users(:student1)
  end

  def test_copy
    assert_difference('@assignment.participants.count') do
      @course_participant.copy(@assignment.id)
      assert_equal 'student6',@assignment.participants.last.handle
    end
  end

  def test_get_course_string
    assert_equal 'CSC110',@course_participant.get_course_string
  end

  def test_import
    assert_difference('CourseParticipant.count') do
      CourseParticipant.import([@student1.name,@student1.fullname,@student1.email,@student1.password],{:user=>users(:superadmin)},courses(:course_e_commerce).id)
    end
    assert_difference('CourseParticipant.count') do
      assert_difference('User.count') do
        CourseParticipant.import(['luke','Luke Skywalker','luke@gmail.com','darthvader'],{:user=>users(:superadmin)},courses(:course_e_commerce).id)
      end
    end
  end

  def test_get_path
    assert_equal RAILS_ROOT + '/pg_data/instructor3/csc110//',@course_participant.get_path
  end

  def test_export
    @csv = Array.new
    CourseParticipant.export(@csv,courses(:course0).id,{"personal_details"=>"true","role" => "true","parent" => "true","email_options" => "true","handle" => "false"})
    assert_equal 4,@csv.length
    assert_equal 8, @csv[0].length
    assert_equal 'student6',@csv[0][0]
  end

  def test_get_export_field
    @fields = CourseParticipant.get_export_fields({"personal_details"=>"true","role" => "true","parent" => "true","email_options" => "true","handle" => "false"})
    assert_equal 8,@fields.length
    assert_equal 'name',@fields[0]
  end
end