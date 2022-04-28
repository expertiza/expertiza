require 'tempfile'

describe ImportFileController do
  let(:super_admin) { build(:superadmin, id: 1, role_id: 5) }
  let(:instructor1) { build(:instructor, id: 10, role_id: 3, parent_id: 3, name: 'Instructor1') }
  let(:ta) { build(:teaching_assistant, id: 6) }
  let(:student1) { build(:student, id: 21, role_id: 1) }

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



  describe '#show' do
    context 'when trying to display uploaded csv for User model' do
      it 'renders show template after parsing contents of csv' do
        stub_current_user(ta, ta.role.name, ta.role)
        params = {
          "delim_type"=>"comma", 
          "has_header"=>"true", 
          "file"=>Rack::Test::UploadedFile.new("#{Rails.root}/spec/fixtures/User.csv"), 
          "model"=>"User", 
          "id"=>""
        }

        get :show, params: params
        # puts controller.instance_variable_get('@contents_grid')
        # puts controller.instance_variable_get('@contents_hash')
        expect(response).to render_template(:show)
      end
    end

    context 'when trying to display uploaded csv for SignupTopic model' do
      it 'renders show template after parsing contents of csv' do
        stub_current_user(ta, ta.role.name, ta.role)
        params = {
          "delim_type"=>"comma", 
          "has_header"=>"true", 
          "file"=>Rack::Test::UploadedFile.new("#{Rails.root}/spec/fixtures/SignUpTopic.csv"), 
          "model"=>"SignUpTopic", 
          "id"=>"",
          "category"=>"true",
          "description"=>"true",
          "link"=>"true"
        }

        get :show, params: params
        # puts controller.instance_variable_get('@contents_grid')
        # puts controller.instance_variable_get('@contents_hash')
        expect(response).to render_template(:show)
      end
    end
  end


  describe '#import' do
    context 'when import data for User model succeeds' do
      it 'redirects to user list page' do
        stub_current_user(ta, ta.role.name, ta.role)
        params = {
          "contents_hash"=>"{:header=>[\"name\", \"full name\", \"email\"], :body=>[[\"super_admin_chi\", \"2, super_administrator\", \"super_admin_chi@mailinator.com\"], [\"instr_chi\", \"3, instructor\", \"instr_chi@mailinator.com\"], [\"stud_chi\", \"8, student\", \"stud_chi@mailinator.com\"]]}", 
          "has_header"=>"true", 
          "model"=>"User"
        }

        allow(User).to receive(:import).with(any_args).and_return(nil)
        get :import, params: params, session: {return_to: list_users_path}

        expect(response).to redirect_to(list_users_path)
      end
    end

    context 'when import data for User model fails and raises exception' do
      it 'redirects to user list page after flashing error message' do
        stub_current_user(ta, ta.role.name, ta.role)
        params = {
          "contents_hash"=>"{:header=>[\"name\", \"full name\", \"email\"], :body=>[[\"super_admin_chi\", \"2, super_administrator\", \"super_admin_chi@mailinator.com\"], [\"instr_chi\", \"3, instructor\", \"instr_chi@mailinator.com\"], [\"stud_chi\", \"8, student\", \"stud_chi@mailinator.com\"]]}", 
          "has_header"=>"true", 
          "model"=>"User"
        }

        expect(User).to receive(:import).and_raise(ActiveRecord::RecordInvalid)
        get :import, params: params, session: {return_to: list_users_path}
        expect(flash[:error]).to be_present
        expect(response).to redirect_to(list_users_path)
      end
    end

    context 'when import data for SignUpTopic model succeeds with no optional parameters' do
      it 'redirects to user Asignments/:id page' do
        stub_current_user(ta, ta.role.name, ta.role)
        params = {
          "contents_hash"=>"{:header=>nil, :body=>[[\"E2000\", \"Refactor stage deadlines in assignment.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2001\", \"Refactor questionnaires_controller.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2002\", \"Refactor impersonate_controller.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2003\", \"Refactor and improve assessment360_controller.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2004\", \"Refactor assignment_controller.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2005\", \"Bookmark enhancements\", \"1\"], [\"\", \"\", \"\"], [\"E2006\", \"Refactor tree_display_controller.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2007\", \"Add test cases to review_mapping_helper.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2008\", \"Refactor summary_helper.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2009\", \"Refactor assignment.rb??\", \"1\"], [\"\", \"\", \"\"], [\"E2010\", \"Refactor criterion.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2011\", \"Refactor assignment_creation_spec.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2012\", \"Refactor lottery_controller.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2013\", \"Refactor tree_display.js\", \"1\"], [\"\", \"\", \"\"], [\"E2014\", \"Refactor date_time_picker.js\", \"1\"], [\"\", \"\", \"\"], [\"M2000\", \"Implement the ImageBitmap web API\", \"1\"], [\"\", \"\", \"\"], [\"M2001\", \"Implement charset prescanning for the HTML parser\", \"1\"], [\"\", \"\", \"\"], [\"M2002\", \"Implement support for WebWorker module scripts\", \"1\"]]}", 
          "has_header"=>"false", 
          "model"=>"SignUpTopic",
          "optional_count"=>"0",
          "select1"=>"topic_identifier", 
          "select2"=>"topic_name", 
          "select3"=>"max_choosers",
          "id"=>"843"
        }

        allow(SignUpTopic).to receive(:import).with(any_args).and_return(nil)
        get :import, params: params, session: {return_to: "/assignments/843"}

        expect(response).to redirect_to assignment_path "843"
      end
    end

    context 'when import data for SignUpTopic model succeeds with one (category) optional parameters' do
      it 'redirects to user Asignments/:id page' do
        stub_current_user(ta, ta.role.name, ta.role)
        params = {
          "contents_hash"=>"{:header=>nil, :body=>[[\"E2000\", \"Refactor stage deadlines in assignment.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2001\", \"Refactor questionnaires_controller.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2002\", \"Refactor impersonate_controller.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2003\", \"Refactor and improve assessment360_controller.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2004\", \"Refactor assignment_controller.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2005\", \"Bookmark enhancements\", \"1\"], [\"\", \"\", \"\"], [\"E2006\", \"Refactor tree_display_controller.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2007\", \"Add test cases to review_mapping_helper.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2008\", \"Refactor summary_helper.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2009\", \"Refactor assignment.rb??\", \"1\"], [\"\", \"\", \"\"], [\"E2010\", \"Refactor criterion.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2011\", \"Refactor assignment_creation_spec.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2012\", \"Refactor lottery_controller.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2013\", \"Refactor tree_display.js\", \"1\"], [\"\", \"\", \"\"], [\"E2014\", \"Refactor date_time_picker.js\", \"1\"], [\"\", \"\", \"\"], [\"M2000\", \"Implement the ImageBitmap web API\", \"1\"], [\"\", \"\", \"\"], [\"M2001\", \"Implement charset prescanning for the HTML parser\", \"1\"], [\"\", \"\", \"\"], [\"M2002\", \"Implement support for WebWorker module scripts\", \"1\"]]}", 
          "has_header"=>"false", 
          "model"=>"SignUpTopic",
          "optional_count"=>"1",
          "select1"=>"topic_identifier", 
          "select2"=>"topic_name", 
          "select3"=>"max_choosers",
          "select4"=>"category",
          "id"=>"843"
        }

        allow(SignUpTopic).to receive(:import).with(any_args).and_return(nil)
        get :import, params: params, session: {return_to: "/assignments/843"}

        expect(response).to redirect_to assignment_path "843"
      end
    end

    context 'when import data for SignUpTopic model succeeds with two (category, description) optional parameters' do
      it 'redirects to user Asignments/:id page' do
        stub_current_user(ta, ta.role.name, ta.role)
        params = {
          "contents_hash"=>"{:header=>nil, :body=>[[\"E2000\", \"Refactor stage deadlines in assignment.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2001\", \"Refactor questionnaires_controller.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2002\", \"Refactor impersonate_controller.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2003\", \"Refactor and improve assessment360_controller.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2004\", \"Refactor assignment_controller.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2005\", \"Bookmark enhancements\", \"1\"], [\"\", \"\", \"\"], [\"E2006\", \"Refactor tree_display_controller.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2007\", \"Add test cases to review_mapping_helper.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2008\", \"Refactor summary_helper.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2009\", \"Refactor assignment.rb??\", \"1\"], [\"\", \"\", \"\"], [\"E2010\", \"Refactor criterion.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2011\", \"Refactor assignment_creation_spec.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2012\", \"Refactor lottery_controller.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2013\", \"Refactor tree_display.js\", \"1\"], [\"\", \"\", \"\"], [\"E2014\", \"Refactor date_time_picker.js\", \"1\"], [\"\", \"\", \"\"], [\"M2000\", \"Implement the ImageBitmap web API\", \"1\"], [\"\", \"\", \"\"], [\"M2001\", \"Implement charset prescanning for the HTML parser\", \"1\"], [\"\", \"\", \"\"], [\"M2002\", \"Implement support for WebWorker module scripts\", \"1\"]]}", 
          "has_header"=>"false", 
          "model"=>"SignUpTopic",
          "optional_count"=>"2",
          "select1"=>"topic_identifier", 
          "select2"=>"topic_name", 
          "select3"=>"max_choosers",
          "select4"=>"category",
          "select5"=>"description",
          "id"=>"843"
        }

        allow(SignUpTopic).to receive(:import).with(any_args).and_return(nil)
        get :import, params: params, session: {return_to: "/assignments/843"}

        expect(response).to redirect_to assignment_path "843"
      end
    end

     context 'when import data for SignUpTopic model succeeds with all (category, description, link) optional parameters' do
      it 'redirects to user Asignments/:id page' do
        stub_current_user(ta, ta.role.name, ta.role)
        params = {
          "contents_hash"=>"{:header=>nil, :body=>[[\"E2000\", \"Refactor stage deadlines in assignment.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2001\", \"Refactor questionnaires_controller.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2002\", \"Refactor impersonate_controller.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2003\", \"Refactor and improve assessment360_controller.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2004\", \"Refactor assignment_controller.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2005\", \"Bookmark enhancements\", \"1\"], [\"\", \"\", \"\"], [\"E2006\", \"Refactor tree_display_controller.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2007\", \"Add test cases to review_mapping_helper.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2008\", \"Refactor summary_helper.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2009\", \"Refactor assignment.rb??\", \"1\"], [\"\", \"\", \"\"], [\"E2010\", \"Refactor criterion.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2011\", \"Refactor assignment_creation_spec.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2012\", \"Refactor lottery_controller.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2013\", \"Refactor tree_display.js\", \"1\"], [\"\", \"\", \"\"], [\"E2014\", \"Refactor date_time_picker.js\", \"1\"], [\"\", \"\", \"\"], [\"M2000\", \"Implement the ImageBitmap web API\", \"1\"], [\"\", \"\", \"\"], [\"M2001\", \"Implement charset prescanning for the HTML parser\", \"1\"], [\"\", \"\", \"\"], [\"M2002\", \"Implement support for WebWorker module scripts\", \"1\"]]}", 
          "has_header"=>"false", 
          "model"=>"SignUpTopic",
          "optional_count"=>"3",
          "select1"=>"topic_identifier", 
          "select2"=>"topic_name", 
          "select3"=>"max_choosers",
          "select4"=>"category",
          "select5"=>"description",
          "select6"=>"link",
          "id"=>"843"
        }

        allow(SignUpTopic).to receive(:import).with(any_args).and_return(nil)
        get :import, params: params, session: {return_to: "/assignments/843"}

        expect(response).to redirect_to assignment_path "843"
      end
    end

    context 'when import data for SignUpTopic model fails and raises exception' do
      it 'redirects to Asignments/:id page after flashing error message' do
        stub_current_user(ta, ta.role.name, ta.role)
        params = {
          "contents_hash"=>"{:header=>nil, :body=>[[\"E2000\", \"Refactor stage deadlines in assignment.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2001\", \"Refactor questionnaires_controller.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2002\", \"Refactor impersonate_controller.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2003\", \"Refactor and improve assessment360_controller.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2004\", \"Refactor assignment_controller.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2005\", \"Bookmark enhancements\", \"1\"], [\"\", \"\", \"\"], [\"E2006\", \"Refactor tree_display_controller.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2007\", \"Add test cases to review_mapping_helper.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2008\", \"Refactor summary_helper.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2009\", \"Refactor assignment.rb??\", \"1\"], [\"\", \"\", \"\"], [\"E2010\", \"Refactor criterion.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2011\", \"Refactor assignment_creation_spec.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2012\", \"Refactor lottery_controller.rb\", \"1\"], [\"\", \"\", \"\"], [\"E2013\", \"Refactor tree_display.js\", \"1\"], [\"\", \"\", \"\"], [\"E2014\", \"Refactor date_time_picker.js\", \"1\"], [\"\", \"\", \"\"], [\"M2000\", \"Implement the ImageBitmap web API\", \"1\"], [\"\", \"\", \"\"], [\"M2001\", \"Implement charset prescanning for the HTML parser\", \"1\"], [\"\", \"\", \"\"], [\"M2002\", \"Implement support for WebWorker module scripts\", \"1\"]]}", 
          "has_header"=>"false", 
          "model"=>"SignUpTopic",
          "optional_count"=>"0",
          "select1"=>"topic_identifier", 
          "select2"=>"topic_name", 
          "select3"=>"max_choosers",
          "id"=>"843"
        }

        expect(SignUpTopic).to receive(:import).and_raise(ActiveRecord::RecordInvalid)
        get :import, params: params, session: {return_to: "/assignments/843"}
        expect(flash[:error]).to be_present
        expect(response).to redirect_to assignment_path "843"
      end
    end
  end
end