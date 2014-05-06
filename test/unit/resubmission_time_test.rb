require File.dirname(__FILE__) + '/../test_helper'

class ResubmissionTimeTest < ActiveSupport::TestCase
  fixtures :resubmission_times

  # Replace this with your real tests.
  # def test_truth
  #   assert true
  # end

  def test_create
    resubmission_time = ResubmissionTime.new
    assert resubmission_time.valid?
    assert resubmission_time.save
  end

  def test_update
    resubmission_time = ResubmissionTime.new
    resubmission_time.update_attributes(:participant_id => 5)
    resubmission_time.update_attributes(:resubmitted_at => Date.today)
    assert resubmission_time.valid?
    assert resubmission_time.save
  end

  def test_check_foreign_key
    resubmission_time = ResubmissionTime.new
    resubmission_time.participant_id = 9001
    begin
      assert !resubmission_time.save
    rescue
      assert true
      return
    end
    assert false
  end

end
