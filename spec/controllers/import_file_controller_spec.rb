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

        get :show, params
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
        get :import, params, {return_to: list_users_path}

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
        get :import, params, {return_to: list_users_path}
        expect(flash[:error]).to be_present
        expect(response).to redirect_to(list_users_path)
      end
    end
  end

  



end