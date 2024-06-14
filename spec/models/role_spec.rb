describe Role do
  before :all do
    @student_role = build(:role_of_student, id: 1, name: 'Student_role_test', description: '', parent_id: nil, default_page_id: nil)
    @instructor_role = build(:role_of_instructor, id: 2, name: 'Instructor_role_test', description: '', parent_id: nil, default_page_id: nil)
    @admin_role = build(:role_of_administrator, id: 3, name: 'Administrator_role_test', description: '', parent_id: nil, default_page_id: nil)
    @invalid_role = build(:role_of_student, id: 1, name: nil, description: '', parent_id: nil, default_page_id: nil)
  end

  it 'role instance to be invalid scenario' do
    expect(@invalid_role).to be_invalid
  end

  it 'role instance to be valid scenario for student' do
    expect(@student_role).to be_valid
  end

  it 'role instance to be valid scenario for instructor' do
    expect(@instructor_role).to be_valid
  end

  it 'role instance to be valid scenario for admin' do
    expect(@admin_role).to be_valid
  end
end
