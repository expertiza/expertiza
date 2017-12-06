require 'test_helper'

class SubmissionViewingEventsControllerTest < ActionController::TestCase
  setup do
    @submission_viewing_event = submission_viewing_events(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:submission_viewing_events)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create submission_viewing_event" do
    assert_difference('SubmissionViewingEvent.count') do
      post :create, submission_viewing_event: { end_at: @submission_viewing_event.end_at, link: @submission_viewing_event.link, map_id: @submission_viewing_event.map_id, round: @submission_viewing_event.round, start_at: @submission_viewing_event.start_at }
    end

    assert_redirected_to submission_viewing_event_path(assigns(:submission_viewing_event))
  end

  test "should show submission_viewing_event" do
    get :show, id: @submission_viewing_event
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @submission_viewing_event
    assert_response :success
  end

  test "should update submission_viewing_event" do
    patch :update, id: @submission_viewing_event, submission_viewing_event: { end_at: @submission_viewing_event.end_at, link: @submission_viewing_event.link, map_id: @submission_viewing_event.map_id, round: @submission_viewing_event.round, start_at: @submission_viewing_event.start_at }
    assert_redirected_to submission_viewing_event_path(assigns(:submission_viewing_event))
  end

  test "should destroy submission_viewing_event" do
    assert_difference('SubmissionViewingEvent.count', -1) do
      delete :destroy, id: @submission_viewing_event
    end

    assert_redirected_to submission_viewing_events_path
  end
end
