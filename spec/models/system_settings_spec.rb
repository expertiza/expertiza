describe SystemSettings do
  before :all do
  	@system_settings = SystemSettings.new
  	@student_role = build(:role_of_student, id: 1, name: "Student_role_test", description: '', parent_id: nil, default_page_id: nil)
  	@system_settings.public_role = @student_role
  	@markup_style = MarkupStyle.new(name: 'Header for Question')
  end
  it 'returns table name' do
    expect(SystemSettings.table_name).to eq('system_settings')
  end
  it 'returns role' do
    expect(@system_settings.public_role).to be(@student_role)
  end
  context 'when there is no markup style set' do
    it 'returns a new one' do
    	allow(@system_settings).to receive(:default_markup_style_id).and_return(false)
      expect(@system_settings.default_markup_style.name).to eq('(None)')
    end
  end
  context 'when there is a markup style set' do
    it 'returns it' do
    	allow(@system_settings).to receive(:default_markup_style_id).and_return(1)
    	allow(MarkupStyle).to receive(:find).with(1).and_return(@markup_style)
    	expect(@system_settings.default_markup_style).to eq(@markup_style)
    end
  end
end