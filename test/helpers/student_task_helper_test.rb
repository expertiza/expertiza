require 'test_helper'
require './app/helpers/student_task_helper'


class StudentHelperTest < ActiveSupport::TestCase

    include StudentTaskHelper

    setup do
        @participant_with_grade = participants(:one)
        @participant_without_grade = participants(:two)
    end

    test "should get assigned submission grade" do
        submission_grade = StudentTaskHelper.get_submission_grade_info(@participant_with_grade)
        assert_equal('98.4', submission_grade)
    end

    test "should get N/A for submission grade" do
        submission_grade = StudentTaskHelper.get_submission_grade_info(@participant_without_grade)
        assert_equal('N/A', submission_grade)
    end 

end
