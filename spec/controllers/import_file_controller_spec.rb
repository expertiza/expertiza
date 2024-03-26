describe ImportFileController do
  let(:admin) { build(:admin) }
  let(:instructor) { build(:instructor, id: 3) }
  let(:instructor2) { build(:instructor, id: 33) }
  let(:ta) { build(:teaching_assistant, id: 8) }
  let(:student) { build(:student) }

  describe '#action_allowed?' do
    context 'when params action is edit or update' do
      before(:each) do
        controller.params = {id: '1', action: 'edit'}
      end

      context 'when the role name of current user is super admin or admin' do
        it 'allows certain action' do
          stub_current_user(admin, admin.role.name, admin.role)
          expect(controller.send(:action_allowed?)).to be true
        end
      end

      context 'when the role name of current user is ta' do
        it 'allows certain action' do
          stub_current_user(ta, ta.role.name, ta.role)
          expect(controller.send(:action_allowed?)).to be true
        end
      end

      context 'when the role name of current user is instructor' do
        it 'allows certain action' do
          stub_current_user(instructor, instructor.role.name, instructor.role)
          expect(controller.send(:action_allowed?)).to be true
        end
      end

      context 'when the role name of current user is student' do
        it 'does not allow certain action' do
          stub_current_user(student, student.role.name, student.role)
          expect(controller.send(:action_allowed?)).to be false
        end
      end
    end
  end

  describe '#start' do
    it 'initializes variables to passed parameters' do
      params = {id: 1, model: 'ReviewResponseMap', title: 'Reviewer Mappings'}
      session = {user: instructor}
      get :start, params: params, session: session
      expect(controller.instance_variable_get(:@id)).to eq 1.to_s
      expect(controller.instance_variable_get(:@model)).to eq 'ReviewResponseMap'
      expect(controller.instance_variable_get(:@title)).to eq 'Reviewer Mappings'
    end
  end

  describe '#show' do
    let(:file_content) { "user, First Last, email@site.edu" }

    it 'expects show to render' do
      params = {
        id: 1,
        model: 'User',
        delim_type: 'comma',
        has_header: 'false',
        file: file_content
      }
      session = { user: instructor }

      get :show, params: params, session: session

      expect(response).to render_template(:show)
      expect(assigns(:id)).to eq "1"
      expect(assigns(:model)).to eq "User"
      expect(assigns(:has_header)).to eq "false"
      expect(assigns(:selected_fields)).to be_truthy
      expect(assigns(:field_count)).to eq 3
      contents_hash = assigns(:contents_hash)
      expect(contents_hash[:header]).to be_nil
      expect(contents_hash[:body]).to eq [["user", "First Last", "email@site.edu"]]
    end
  end


end