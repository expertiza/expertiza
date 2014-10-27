require 'spec_helper'

describe StudentTeamsController do
  let (:student_teams_controller) {StudentTeamsController.new}
  describe 'set student should be called when view is called'
    Student.should_receive(:find).with('12345')
    student_teams_controller.stub(:view)
    post :view, {student_id: 12345}
end