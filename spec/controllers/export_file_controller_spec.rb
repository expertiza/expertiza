require 'rails_helper'

describe ExportFileController do
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

    describe '#export' do
        context 'when exporting data for User' do
            let(:csv_string)  { "name,full name,email,role,parent,email on submission,email on review,email on metareview,copy of emails,preference home flag,handle\nabc,abc xyz,abcxyz@gmail.com,true,true,false,true,true,handle\n" }
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
                    @controller.render nothing: true # to prevent a 'missing template' error
                }
                get :export, params: params
            end    
        end    
    end

    describe '#exportdetails' do
        context 'when exporting details for Assignment' do
            let(:csv_string)  { "Assignment Name: test_assignment,Assignment Instructor: abc\nTeam ID / Author ID,Reviewee (Team / Student Name),Reviewer,Question / Criterion,Question ID,Answer / Comment ID,Answer / Comment,Score\n" }
            let(:csv_options) { {type: 'text/csv; charset=iso-8859-1; header=present',
                disposition: "attachment; filename=Assignment843_Details.csv"} }
            it 'exports details csv' do
                stub_current_user(ta, ta.role.name, ta.role)
                params = {
                    "delim_type2"=>"comma", 
                    "other_char2"=>"", 
                    "details"=>{"team_id"=>"true", "team_name"=>"true", "reviewer"=>"true", "question"=>"true", "question_id"=>"true", "comment_id"=>"true", "comments"=>"true", "score"=>"true"}, 
                    "id"=>"843", 
                    "model"=>"Assignment"
                }
                allow(Assignment).to receive(:find).with("843").and_return(assignment)
                allow(User).to receive(:find).with(any_args).and_return(user1)
                expect(@controller).to receive(:send_data).with(csv_string, csv_options) {
                    @controller.render nothing: true # to prevent a 'missing template' error
                }
                get :exportdetails, params: params
            end
        end
        context 'when exporting details for other Models' do
            before(:each) do
                @request.env["HTTP_REFERER"] = start_export_file_index_path
            end    
            it 'should not export details csv' do
                stub_current_user(ta, ta.role.name, ta.role)
                params = {
                    "delim_type2"=>"comma",
                    "other_char2"=>"",
                    "details"=>{"team_id"=>"true", "team_name"=>"true", "reviewer"=>"true", "question"=>"true", "question_id"=>"true", "comment_id"=>"true", "comments"=>"true", "score"=>"true"},
                    "id"=>"1",
                    "model"=>"User"
                }
                get :exportdetails, params: params
                expect(flash[:error]).to be_present
                expect(response).to redirect_to(start_export_file_index_path)
            end
        end    
    end

end

