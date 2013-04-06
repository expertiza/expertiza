require File.dirname(__FILE__) + '/../test_helper'

class ResponseTest < ActiveSupport::TestCase
  fixtures :responses

  # Replace this with your real tests.
  def test_truth
    assert true
  end

  # The response is after the latest submission time - so it should be VALID
  def test_response_latest
    response = Response.new

    response.updated_at = Time.parse("2012-12-02 08:00:00 UTC")

    #All resubmission times are before the response time
    #also the response is in current review phase
    latest_review_phase_start_time = Time.parse("2012-12-02 07:00:00 UTC")

    resubmission_time1 = ResubmissionTime.new
    resubmission_time1.resubmitted_at = Time.parse("2012-12-02 04:00:00 UTC")
    resubmission_time2 = ResubmissionTime.new
    resubmission_time2.resubmitted_at = Time.parse("2012-12-02 05:00:00 UTC")
    resubmission_time3 = ResubmissionTime.new
    resubmission_time3.resubmitted_at = Time.parse("2012-12-02 06:00:00 UTC")

    resubmission_times = [resubmission_time3, resubmission_time2, resubmission_time1]

    assert response.is_valid_for_score_calculation?(resubmission_times, latest_review_phase_start_time)
  end

  # One resubmission after the latest response and before review phase start
  # so review should be INVALID
  def test_response_stale
    response = Response.new

    response.updated_at = Time.parse("2012-12-02 06:00:00 UTC")

    #resubmission_time3 after the response time
    #also the response before in current review phase
    latest_review_phase_start_time = Time.parse("2012-12-02 08:00:00 UTC")

    resubmission_time1 = ResubmissionTime.new
    resubmission_time1.resubmitted_at = Time.parse("2012-12-02 04:00:00 UTC")
    resubmission_time2 = ResubmissionTime.new
    resubmission_time2.resubmitted_at = Time.parse("2012-12-02 05:00:00 UTC")
    resubmission_time3 = ResubmissionTime.new
    resubmission_time3.resubmitted_at = Time.parse("2012-12-02 07:00:00 UTC")

    resubmission_times = [resubmission_time3, resubmission_time2, resubmission_time1]

    assert !response.is_valid_for_score_calculation?(resubmission_times, latest_review_phase_start_time)
  end

  # One resubmission after the latest response but after the latest review phase start time
  # so review should be VALID
  # this will become invalid in the next phase
  def test_response_valid_in_this_phase
    response = Response.new

    response.updated_at = Time.parse("2012-12-02 06:00:00 UTC")

    #resubmission_time3 after the response time
    #but it is after the current review phase
    latest_review_phase_start_time = Time.parse("2012-12-02 07:00:00 UTC")

    resubmission_time1 = ResubmissionTime.new
    resubmission_time1.resubmitted_at = Time.parse("2012-12-02 04:00:00 UTC")
    resubmission_time2 = ResubmissionTime.new
    resubmission_time2.resubmitted_at = Time.parse("2012-12-02 05:00:00 UTC")
    resubmission_time3 = ResubmissionTime.new
    resubmission_time3.resubmitted_at = Time.parse("2012-12-02 08:00:00 UTC")

    resubmission_times = [resubmission_time3, resubmission_time2, resubmission_time1]

    assert response.is_valid_for_score_calculation?(resubmission_times, latest_review_phase_start_time)
  end
end
