describe SystemSettings do
  before :all do
    @system_settings = SystemSettings.new
    @system_settings1 = SystemSettings.new
    @student_role = build(:role_of_student, id: 1, name: 'Student_role_test', description: '', parent_id: nil, default_page_id: nil)
    @system_settings.public_role = @student_role
    @markup_style = MarkupStyle.new(name: 'Header for Question')
    @site_default_page = ContentPage.new(name: 'Site Default')
    @not_found_page = ContentPage.new(name: 'Not Found')
    @permission_denied_page = ContentPage.new(name: 'Permission Denied')
    @session_expired_page = ContentPage.new(name: 'Session Expired')
  end
  it 'returns table name' do
    expect(SystemSettings.table_name).to eq('system_settings')
  end
  it 'returns role' do
    expect(@system_settings.public_role).to be(@student_role)
  end
  context 'when there is no markup style set' do
    it 'returns a new one' do
      allow(@system_settings1).to receive(:default_markup_style_id).and_return(nil)
      expect(@system_settings1.default_markup_style.name).to eq('(None)')
    end
  end
  context 'when there is a markup style set' do
    it 'returns it' do
      allow(@system_settings).to receive(:default_markup_style_id).and_return(1)
      allow(MarkupStyle).to receive(:find).with(1).and_return(@markup_style)
      expect(@system_settings.default_markup_style).to eq(@markup_style)
    end
  end
  it 'returns site default page' do
    allow(ContentPage).to receive(:find).with(1).and_return(@site_default_page)
    allow(@system_settings).to receive(:site_default_page_id).and_return(1)
    expect(@system_settings.site_default_page).to eq(@site_default_page)
  end
  it 'returns not found page' do
    allow(ContentPage).to receive(:find).with(2).and_return(@not_found_page)
    allow(@system_settings).to receive(:not_found_page_id).and_return(2)
    expect(@system_settings.not_found_page).to eq(@not_found_page)
  end
  it 'returns permission denied page' do
    allow(ContentPage).to receive(:find).with(3).and_return(@permission_denied_page)
    allow(@system_settings).to receive(:permission_denied_page_id).and_return(3)
    expect(@system_settings.permission_denied_page).to eq(@permission_denied_page)
  end
  it 'returns session expired page page' do
    allow(ContentPage).to receive(:find).with(4).and_return(@session_expired_page)
    allow(@system_settings).to receive(:session_expired_page_id).and_return(4)
    expect(@system_settings.session_expired_page).to eq(@session_expired_page)
  end
  it 'returns nil when the pageid does not match the denied pages' do
    allow(@system_settings).to receive(:site_default_page_id).and_return(1)
    allow(@system_settings).to receive(:not_found_page_id).and_return(2)
    allow(@system_settings).to receive(:permission_denied_page_id).and_return(3)
    allow(@system_settings).to receive(:session_expired_page_id).and_return(4)
    expect(@system_settings.system_pages(5)).to be_nil
  end
  it 'returns the name of the page when the pageid matches the denied pages' do
    allow(@system_settings).to receive(:site_default_page_id).and_return(1)
    allow(@system_settings).to receive(:not_found_page_id).and_return(2)
    allow(@system_settings).to receive(:permission_denied_page_id).and_return(3)
    allow(@system_settings).to receive(:session_expired_page_id).and_return(4)
    expect(@system_settings.system_pages(3)).to eq(['Permission denied page'])
  end
end
