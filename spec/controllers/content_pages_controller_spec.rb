describe ContentPagesController do
  let(:instructor) { build(:instructor, id: 6) }
  let(:content_page_home) { build(:content_page, id: 1) }
  let(:superadmin) { create(:superadmin) }

  before(:each) do
    stub_current_user(instructor, instructor.role.name, instructor.role)
    @markup_style = MarkupStyle.new(name: 'Markdown')
    @permission = Permission.new(name: 'administrator')
  end

  describe '#view' do
    context 'when ContentPage found' do
      it 'retrieves ContentPage by page_name and render content_pages#view page' do
        allow(ContentPage).to receive(:find_by).with(name: 'home').and_return(content_page_home)
        params = { page_name: 'home' }
        get :view, params
        expect(controller.instance_variable_get(:@content_page).title).to eq('Expertiza Home')
        expect(response).to render_template(:view)
      end

      it 'retrieves ContentPage by settings not_found_page_id and render content_pages#view page' do
        controller.instance_variable_set(:@settings, SystemSettings.new(not_found_page_id: 1))
        allow(ContentPage).to receive(:find).with(1).and_return(content_page_home)
        params = { page_name: 'unknown' }
        get :view, params
        expect(controller.instance_variable_get(:@content_page).title).to eq('Expertiza Home')
        expect(response).to render_template(:view)
      end
    end

    context 'when no content page found' do
      it 'creates new ContentPage object with id=nil and render ontent_pages#view page' do
        params = { page_name: 'not found' }
        get :view, params
        expect(controller.instance_variable_get(:@content_page).content).to eq('(no such page)')
        expect(response).to render_template(:view)
      end
    end
  end

  describe '#edit' do
    it 'renders grades#edit page' do
      stub_current_user(superadmin, superadmin.role.name, superadmin.role)
      allow(ContentPage).to receive(:find).with('1').and_return(content_page_home)
      allow(MarkupStyle).to receive(:order).with('name').and_return([@markup_style])
      allow(Permission).to receive(:order).with('name').and_return([@permission])
      allow(MenuItem).to receive_message_chain(:order, :where).and_return(MenuItem.new(content_page_id: 1))
      controller.instance_variable_set(:@settings, SystemSettings.new(site_default_page_id: 1))
      allow(controller.instance_variable_get(:@settings)).to receive(:system_pages).with(1).and_return(['Site default page'])
      params = { id: 1 }
      get :edit, params
      expect(response).to render_template(:edit)
    end
  end

  describe '#action_allowed' do
    context 'when user does not have superadmin privileges' do
      it 'returns false' do
        params = { action: 'edit' }
        controller.params = params
        expect(controller.action_allowed?).to eq(false)
      end

      it 'return true for view' do
        params = { action: 'view' }
        controller.params = params
        expect(controller.action_allowed?).to eq(true)
      end

      it 'return true for view_default' do
        params = { action: 'view_default' }
        controller.params = params
        expect(controller.action_allowed?).to eq(true)
      end
    end

    context 'when user does have superadmin privileges' do
      it 'returns true for #edit' do
        stub_current_user(superadmin, superadmin.role.name, superadmin.role)
        params = { action: 'edit' }
        controller.params = params
        expect(controller.action_allowed?).to eq(true)
      end
    end
  end
end
