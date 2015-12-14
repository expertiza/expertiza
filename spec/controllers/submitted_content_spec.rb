require 'rails_helper'
require_relative  'helpers/submitted_content_test_helper.rb'
include LogInHelper
include SubmittedContentTestHelper 

describe SubmittedContentController do
  context 'when student makes a submission' do
    before(:each) do
      #setup fake login
	  SubmittedContentTestHelper.create_assignment
      @user = User.find_by_name('student')
      @role = double('role', :super_admin? => false)
      @partcipant = Participant.find_by(user_id: @user.id)
      ApplicationController.any_instance.stub(:current_user).and_return(@user)
      ApplicationController.any_instance.stub(:current_role_name).and_return('Student')
      ApplicationController.any_instance.stub(:current_role).and_return(@role)
      ApplicationController.any_instance.stub(:undo_link)

      AssignmentParticipant.any_instance.stub(:set_student_directory_num)
    end
   
	it 'should create an event on new hyperlink submission' do
	  hyperlink = 'https://github.com/expertiza/expertiza'
	  SubmissionHistory.should_receive(:create_hyperlink_submission_event).with(@partcipant.id, hyperlink)
	  post :submit_hyperlink, {id: @partcipant.id, submission: hyperlink}
	end

	it 'should create an event on new file submission' do
	  SubmissionHistory.should_receive(:create_file_submission_event)
	  post :submit_file, {id: @partcipant.id, 
	  	   :uploaded_file => Rack::Test::UploadedFile.new
		   						(Rails.root.join("spec/controllers/submitted_content_spec.rb"), 
								"image/jpeg")}
	end
  end
end

