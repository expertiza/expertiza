require File.dirname(__FILE__) + '/../test_helper'

class DueDateTest < ActiveSupport::TestCase
  fixtures :due_dates
  fixtures :deadline_types
  fixtures :assignments

  # Replace this with your real tests.
  def test_truth
    assert true
  end

  def test_due_date_submit
    duedate1 = DueDate.new
    duedate1.due_at= (Time.now + 100000).strftime("%Y-%m-%d %H:%M:%S")
    duedate1.review_allowed_id= "OK"
    duedate1.submission_allowed_id="OK"
    assert duedate1.valid?
  end

  def test_due_date_review
    duedate2 = DueDate.new
    duedate2.due_at= (Time.now + 100000).strftime("%Y-%m-%d %H:%M:%S")
    duedate2.review_allowed_id= "LATE"
    duedate2.submission_allowed_id="OK"
    assert duedate2.valid?
  end


end
