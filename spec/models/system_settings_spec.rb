describe SystemSettings do
  before :all do
  	@system_settings = SystemSettings.new
  	@student_role = build(:role_of_student, id: 1, name: "Student_role_test", description: '', parent_id: nil, default_page_id: nil)
  	@system_settings.public_role = @student_role
  end
  describe 'test some basic equalities' do
    it 'returns table name' do
      expect(SystemSettings.table_name).to eq('system_settings')
    end
  end
  describe '#public_role' do
    expect(@system_settings.public_role).to be(@student_role)
  end
end