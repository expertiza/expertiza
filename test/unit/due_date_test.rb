require File.dirname(__FILE__) + '/../test_helper'
require 'Date'

class DueDateTest < ActiveSupport::TestCase
  fixtures :due_dates, :deadline_types, :assignments

  def setup
    @due_date0 = DueDate.new
    @due_date0.due_at = nil
    @due_date0.deadline_type_id = deadline_types(:deadline_type_review).id
    @due_date0.assignment_id = assignments(:assignment1).id
    @due_date0.submission_allowed_id = 3
    @due_date0.review_allowed_id = 1
    @due_date0.resubmission_allowed_id = 1
    @due_date0.rereview_allowed_id = 1
    @due_date0.review_of_review_allowed_id = 1
    @due_date0.round = 2
    @due_date0.delayed_job_id = 2
    @due_date0.quiz_allowed_id = 0
    @due_date0.save
  end

  def test_update_due_date
    deadline_type = @due_date0.deadline_type_id
    @due_date0.assignment_id= assignments(:assignment7).id

    @due_date0.save
    @due_date0.reload
    assert_equal assignments(:assignment7).id,@due_date0.assignment_id
  end

  def test_create_due_date
    @due_date1 = DueDate.new
    @due_date1.due_at ='2014-05-10 22:23:00'  # nil
    @due_date1.deadline_type_id = deadline_types(:deadline_type_submission).id
    @due_date1.assignment_id = assignments(:assignment1).id
    @due_date1.submission_allowed_id = 3
    @due_date1.review_allowed_id = 1
    @due_date1.resubmission_allowed_id = 1
    @due_date1.rereview_allowed_id = 1
    @due_date1.review_of_review_allowed_id = 1
    @due_date1.round = 2
    @due_date1.delayed_job_id = 2
    @due_date1.quiz_allowed_id = 0
    assert @due_date1.save
  end

  def test_create_due_date_bad_datetime
    @due_date1 = DueDate.new
    @due_date1.due_at = '204-5-10:23:00'
    @due_date1.deadline_type_id = deadline_types(:deadline_type_submission).id
    @due_date1.assignment_id = assignments(:assignment1).id
    @due_date1.submission_allowed_id = 3
    @due_date1.review_allowed_id = 1
    @due_date1.resubmission_allowed_id = 1
    @due_date1.rereview_allowed_id = 1
    @due_date1.review_of_review_allowed_id = 1
    @due_date1.round = 2
    @due_date1.delayed_job_id = 2
    @due_date1.quiz_allowed_id = 0

    assert !@due_date1.save
  end

  def test_create_due_date_bad_assignment
    @due_date1 = DueDate.new
    @due_date1.due_at =nil
    @due_date1.deadline_type_id = deadline_types(:deadline_type_submission).id
    @due_date1.assignment_id = 9001
    @due_date1.submission_allowed_id = 3
    @due_date1.review_allowed_id = 1
    @due_date1.resubmission_allowed_id = 1
    @due_date1.rereview_allowed_id = 1
    @due_date1.review_of_review_allowed_id = 1
    @due_date1.round = 2
    @due_date1.delayed_job_id = 2
    @due_date1.quiz_allowed_id = 0

    begin
      assert !@due_date1.save
      return
    rescue
      assert true
      return
    end
    assert false
  end


  def test_create_due_date_bad_deadline
    @due_date1 = DueDate.new
    @due_date1.due_at = nil
    @due_date1.deadline_type_id = 9001
    @due_date1.assignment_id = assignments(:assignment1).id
    @due_date1.submission_allowed_id = 3
    @due_date1.review_allowed_id = 1
    @due_date1.resubmission_allowed_id = 1
    @due_date1.rereview_allowed_id = 1
    @due_date1.review_of_review_allowed_id = 1
    @due_date1.round = 2
    @due_date1.delayed_job_id = 2
    @due_date1.quiz_allowed_id = 0

    begin
      assert !@due_date1.save
      return
    rescue
      assert true
      return
    end
    assert false
  end

end
