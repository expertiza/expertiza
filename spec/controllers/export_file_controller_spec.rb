describe  do
    describe "#action_allowed?" do
      context "when the current user has TA privileges" do
        it "returns true" do
          # Test body
        end
      end
    
      context "when the current user does not have TA privileges" do
        it "returns false" do
          # Test body
        end
      end
    end
    describe 'start' do
      context 'when given valid parameters' do
        it 'sets the model parameter' do
          # Test body
        end
    
        it 'sets the title parameter based on the model' do
          # Test body
        end
    
        it 'sets the id parameter' do
          # Test body
        end
      end
    
      context 'when given invalid parameters' do
        it 'does not set the model parameter' do
          # Test body
        end
    
        it 'does not set the title parameter' do
          # Test body
        end
    
        it 'does not set the id parameter' do
          # Test body
        end
      end
    end
    describe 'find_delim_filename' do
      context 'when delim_type is "comma"' do
        it 'returns a filename with .csv extension and delimiter as comma' do
          # test body
        end
      end
    
      context 'when delim_type is "space"' do
        it 'returns a filename with .csv extension and delimiter as space' do
          # test body
        end
      end
    
      context 'when delim_type is "tab"' do
        it 'returns a filename with .csv extension and delimiter as tab' do
          # test body
        end
      end
    
      context 'when delim_type is "other"' do
        it 'returns a filename with .csv extension and delimiter as other_char' do
          # test body
        end
      end
    end
    describe '#exportdetails' do
      context 'when the delimiter type is specified' do
        it 'exports details to a CSV file with the specified delimiter' do
          # Test setup
          params = { delim_type2: 'comma', other_char2: '', model: 'Assignment', id: 1, details: 'all' }
    
          # Test execution
          exportdetails(params)
    
          # Test expectations
          expect(response).to have_http_status(:success)
          expect(response.content_type).to eq('text/csv')
          expect(response.headers['Content-Disposition']).to include('attachment')
          expect(response.headers['Content-Disposition']).to include('_Details.csv')
        end
      end
    
      context 'when the delimiter type is not specified' do
        it 'returns an error flash message and redirects back' do
          # Test setup
          params = { delim_type2: '', other_char2: '', model: 'Assignment', id: 1, details: 'all' }
    
          # Test execution
          exportdetails(params)
    
          # Test expectations
          expect(flash[:error]).to eq("This operation is not supported for Assignment")
          expect(response).to redirect_to(:back)
        end
      end
    
      context 'when the model is not allowed' do
        it 'returns an error flash message and redirects back' do
          # Test setup
          params = { delim_type2: 'comma', other_char2: '', model: 'User', id: 1, details: 'all' }
    
          # Test execution
          exportdetails(params)
    
          # Test expectations
          expect(flash[:error]).to eq("This operation is not supported for User")
          expect(response).to redirect_to(:back)
        end
      end
    end
    describe '#export' do
      context 'when the delimiter type is specified' do
        it 'sets the delimiter type based on the provided parameter' do
          # Test body
        end
    
        it 'finds the filename and delimiter based on the delimiter type and other character parameter' do
          # Test body
        end
      end
    
      context 'when the model is allowed' do
        it 'generates CSV data with the specified delimiter' do
          # Test body
        end
    
        it 'exports the specified model data to the CSV' do
          # Test body
        end
      end
    
      it 'sends the generated CSV data as a file attachment' do
        # Test body
      end
    end
    describe "#export_advices" do
      context "when delim_type is specified" do
        it "exports advices to a CSV file with specified delimiter" do
          # Test setup
          params = { delim_type: "comma", other_char: nil, model: "Question", options: { include_header: true }, id: 1 }
          allow(Object).to receive(:const_get).with("QuestionAdvice").and_return(double(export_fields: ["field1", "field2"], export: nil))
          allow(CSV).to receive(:generate).and_return("csv_data")
          allow(controller).to receive(:send_data)
    
          # Test execution
          controller.export_advices
    
          # Test expectations
          expect(CSV).to have_received(:generate).with(col_sep: ",")
          expect(Object).to have_received(:const_get).with("QuestionAdvice")
          expect(Object.const_get("QuestionAdvice")).to have_received(:export_fields).with({ include_header: true })
          expect(Object.const_get("QuestionAdvice")).to have_received(:export).with("csv_data", 1, { include_header: true })
          expect(controller).to have_received(:send_data).with("csv_data", type: 'text/csv; charset=iso-8859-1; header=present', disposition: "attachment; filename=filename")
        end
      end
    
      context "when delim_type is not specified" do
        it "exports advices to a CSV file with default delimiter" do
          # Test setup
          params = { delim_type: nil, other_char: nil, model: "Question", options: { include_header: true }, id: 1 }
          allow(Object).to receive(:const_get).with("QuestionAdvice").and_return(double(export_fields: ["field1", "field2"], export: nil))
          allow(CSV).to receive(:generate).and_return("csv_data")
          allow(controller).to receive(:send_data)
    
          # Test execution
          controller.export_advices
    
          # Test expectations
          expect(CSV).to have_received(:generate).with(col_sep: ";")
          expect(Object).to have_received(:const_get).with("QuestionAdvice")
          expect(Object.const_get("QuestionAdvice")).to have_received(:export_fields).with({ include_header: true })
          expect(Object.const_get("QuestionAdvice")).to have_received(:export).with("csv_data", 1, { include_header: true })
          expect(controller).to have_received(:send_data).with("csv_data", type: 'text/csv; charset=iso-8859-1; header=present', disposition: "attachment; filename=filename")
        end
      end
    
      context "when model is not allowed" do
        it "does not export advices" do
          # Test setup
          params = { delim_type: "comma", other_char: nil, model: "Answer", options: { include_header: true }, id: 1 }
          allow(Object).to receive(:const_get).with("QuestionAdvice").and_return(double(export_fields: ["field1", "field2"], export: nil))
          allow(CSV).to receive(:generate)
          allow(controller).to receive(:send_data)
    
          # Test execution
          controller.export_advices
    
          # Test expectations
          expect(CSV).not_to have_received(:generate)
          expect(Object).not_to have_received(:const_get)
          expect(controller).not_to have_received(:send_data)
        end
      end
    end
    RSpec.describe "export_tags" do
      context "when given names parameter" do
        it "should find user ids based on the names" do
          # Test code
        end
    
        it "should find students' answer tags based on the user ids" do
          # Test code
        end
    
        it "should generate CSV data with specified attributes" do
          # Test code
        end
    
        it "should set the filename for the CSV file" do
          # Test code
        end
    
        it "should send the CSV data as a file attachment" do
          # Test code
        end
      end
    end
    
    end


    ####################################################################
    ###Additional Test cases
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

