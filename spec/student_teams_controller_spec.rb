require 'rails_helper'

describe StudentTeamsController do
  let (:student_teams_controller) {StudentTeamsController.new}
  let(:student) {double "student"}
  describe '#view' do
    it 'sets the student' do
      AssignmentParticipant.should_receive(:find).with('12345').and_return student
      student_teams_controller.stub(:current_user_id?)
      student_teams_controller.stub(:params).and_return({student_id: '12345'})
      student.stub(:user_id)
      student_teams_controller.view
    end
  end
end
