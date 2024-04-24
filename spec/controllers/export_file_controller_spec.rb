require 'rails_helper'

RSpec.describe ExportFileController do
  let(:user1) do
      User.new name: 'abc', fullname: 'abc xyz', email: 'abcxyz@gmail.com', password: '12345678', password_confirmation: '12345678',
               email_on_submission: 1, email_on_review: 1, email_on_review_of_review: 0, copy_of_emails: 1, handle: 'handle' 
  end
  let(:user) { build(:student, id: 1, name: 'student1') }
  let(:answer_tag) { AnswerTag.new(tag_prompt_deployment_id: 2, answer: an_long, user_id: 1, value: 1)}
  let(:answers) { build(:answers, id: [1, 2])}
  let(:super_admin) { build(:superadmin, id: 1, role_id: 5) }
  let(:instructor1) { build(:instructor, id: 10, role_id: 3, parent_id: 3, name: 'Instructor1') }
  let(:ta) { build(:teaching_assistant, id: 6) }
  let(:student1) { build(:student, id: 21, role_id: 1) }
  let(:assignment) do
      build(:assignment, id: 843, name: 'test_assignment', instructor_id: 6, course_id: 1)
  end
  let(:sign_up_topic) {SignUpTopic.new(id: 1, topic_name: 'test_signup_topic', assignment_id: 843)}
  let(:assignment_team) {Team.new(id: 1, name: 'test_team', parent_id: 843)}
  let(:course) {Course.new(id:230, name:'test_course', instructor_id:6)}
  let(:course_team) {Team.new(id: 2, name: 'test_team', parent_id: 230)}

  describe '#action_allowed?' do
        context 'when someone is logged in' do
        it 'allows certain action for admin' do
            stub_current_user(super_admin, super_admin.role.name, super_admin.role)
            expect(controller.send(:action_allowed?)).to be_truthy
        end
        it 'allows certain action for instructor' do
            stub_current_user(instructor1, instructor1.role.name, instructor1.role)
            expect(controller.send(:action_allowed?)).to be_truthy
        end
        it 'allows certain action for ta' do
            stub_current_user(ta, ta.role.name, ta.role)
            expect(controller.send(:action_allowed?)).to be_truthy
        end
        it 'refuses certain action for student' do
            stub_current_user(student1, student1.role.name, student1.role)
            expect(controller.send(:action_allowed?)).to be_falsey
        end
        end    
        context 'when no one is logged in' do
        it 'refuses certain action' do
            expect(controller.send(:action_allowed?)).to be_falsey
        end
        end
    end

  describe 'Start' do
    context 'with valid parameters' do
      let(:params) { { "model" => "Assignment", "id" => "1028" } }
  
      it 'assigns the correct values' do
        get :start, params: params
        expect(assigns(:model)).to eq(params[:model])
        expect(assigns(:id)).to eq(params[:id])
      end
    end
  
    context 'with invalid parameters' do
      let(:invalid_params) { { "model" => "UnknownModel", "id" => "unknown" } }
      let(:valid_params) { { "model" => "Assignment", "id" => "1028" } }
  
      it 'does not assign the expected model' do
        get :start, params: invalid_params
        expect(assigns(:model)).to be_nil
      end
  
      it 'does not assign the expected id' do
        get :start, params: invalid_params
        expect(assigns(:id)).to be_nil
      end
    end
  end
  describe '#export' do
    context 'when exporting data for User' do
      let(:csv_string)  { "name,full name,email,role,parent,email on submission,email on review,email on metareview,copy of emails,preference home flag,handle\nabc,abc xyz,abcxyz@gmail.com,true,true,false,true,handle\n" }
      let(:csv_options) { {type: 'text/csv; charset=iso-8859-1; header=present',
          disposition: "attachment; filename=User1.csv"} }

      it 'exports a csv file with User model data' do
          stub_current_user(ta, ta.role.name, ta.role)
          params = {
          "delim_type"=>"comma", 
          "other_char"=>"", 
          "options"=>{"personal_details"=>"true", "role"=>"false", "parent"=>"false", "email_options"=>"true", "preference_home_flag"=>"true", "handle"=>"true"},
          "model"=>"User", 
          "id"=>"1"
          }   
          allow(User).to receive(:export_fields).with(any_args).and_return(["name", "full name", "email", "role", "parent", "email on submission", "email on review", "email on metareview", "copy of emails", "preference home flag", "handle"])
          allow(User).to receive(:all).and_return([user1])
          expect(@controller).to receive(:send_data).with(csv_string, csv_options) {
              @controller.head :ok # to prevent a 'missing template' error
          }
          get :export, params: params
      end    
    end
    context 'when exporting data for Assignment' do
      let(:csv_string)  { "Team Name,User ID,Username,Grade for submission,Comment for submission,Maximum review score,Minimum review score,Average review score,Maximum score from teammates,Minimum score from teammates,Average score from teammates\n" }
      let(:csv_options) { {type: 'text/csv; charset=iso-8859-1; header=present',
                          disposition: "attachment; filename=Assignment843.csv"} }

      it 'export grade data for submissions for an assignment into a CSV file' do
        stub_current_user(ta, ta.role.name, ta.role)
        params = {
                "delim_type"=>"comma", 
                "other_char"=>"", 
                "options"=>{"review_score"=>"true", "teammate_review_score"=>"true", "author_feedback_score"=>"false", "metareview_score"=>"false"},
                "model"=>"Assignment", 
                "id"=>"843"
                }
        allow(Assignment).to receive(:find).with("843").and_return(assignment)
        expect(@controller).to receive(:send_data).with(csv_string, csv_options) {
                    @controller.head :ok
                }
        get :export, params: params
      end
    end
    context 'when exporting data for Signup Topic' do
      let(:csv_string)  { "Topic Id,Topic Names,Participants\n" }
      let(:csv_options) { {type: 'text/csv; charset=iso-8859-1; header=present',
                          disposition: "attachment; filename=SignUpTopic843.csv"} }

      it 'export sign up topic data for an assignment into a CSV file' do
        stub_current_user(ta, ta.role.name, ta.role)
        params = {
                "delim_type"=>"comma", 
                "other_char"=>"", 
                "options"=>{"topic_identifier"=>"true", "topic_name"=>"true", "description"=>"false", "participants"=>"true", "num_of_slots"=>"false", "available_slots"=>"false", "num_on_waitlist"=>"false"},
                "model"=>"SignUpTopic", 
                "id"=>"843"
                }
        allow(Assignment).to receive(:find).with(843).and_return(assignment)
        allow(SignUpTopic).to receive(:find).with(1).and_return(sign_up_topic)
        expect(@controller).to receive(:send_data).with(csv_string, csv_options) {
                    @controller.head :ok
                }
        get :export, params: params
      end
    end
    context 'when exporting data for AssignmentTeam' do
      let(:csv_string)  { "Team Name,Team members\n" }
      let(:csv_options) { {type: 'text/csv; charset=iso-8859-1; header=present',
                          disposition: "attachment; filename=AssignmentTeam843.csv"} }

      it 'export assignment teams for an assignment into a CSV file' do
        stub_current_user(ta, ta.role.name, ta.role)
        params = {
                "delim_type"=>"comma", 
                "other_char"=>"", 
                "options"=>{"team_name"=>"false"},
                "model"=>"AssignmentTeam", 
                "id"=>"843"
                }
        allow(Assignment).to receive(:find).with(843).and_return(assignment)
        allow(Team).to receive(:find).with(1).and_return(assignment_team)
        expect(@controller).to receive(:send_data).with(csv_string, csv_options) {
                    @controller.head :ok
                }
        get :export, params: params
      end
    end
    context 'when exporting data for CourseTeam' do
      let(:csv_string)  { "Team Name,Team members\n" }
      let(:csv_options) { {type: 'text/csv; charset=iso-8859-1; header=present',
                          disposition: "attachment; filename=CourseTeam230.csv"} }

      it 'export course teams for a course into a CSV file' do
        stub_current_user(ta, ta.role.name, ta.role)
        params = {
                "delim_type"=>"comma", 
                "other_char"=>"", 
                "options"=>{"team_name"=>"false"},
                "model"=>"CourseTeam", 
                "id"=>"230"
                }
        allow(Course).to receive(:find).with(230).and_return(course)
        allow(Team).to receive(:find).with(2).and_return(course_team)
        expect(@controller).to receive(:send_data).with(csv_string, csv_options) {
                    @controller.head :ok
                }
        get :export, params: params
      end
    end
  end
end

    
