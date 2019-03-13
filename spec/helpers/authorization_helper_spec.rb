describe AuthorizationHelper do

  # E1915 TODO each and every method defined in app/helpers/authorization_helper.rb should be thoroughly tested here

  # Set up some dummy users
  # Inspired by spec/controllers/users_controller_spec.rb
  # Makes use of spec/factories/factories.rb
  let(:student) { build(:student) }
  let(:teaching_assistant) { build(:teaching_assistant) }
  let(:instructor) { build(:instructor) }
  let(:admin) { build(:admin) }
  let(:superadmin) { build(:superadmin) }

  # The global before(:each) in spec/spec_helper.rb establishes roles before each test runs

  # TESTS

  # HAS PRIVILEGES (Super Admin --> Admin --> Instructor --> TA --> Student)

  describe ".current_user_has_super_admin_privileges?" do

    it 'returns false if there is no current user' do
      expect(current_user_has_super_admin_privileges?).to be false
    end

    it 'returns false for a student' do
      stub_current_user(student, student.role.name, student.role)
      expect(current_user_has_super_admin_privileges?).to be false
    end

    it 'returns false for a TA' do
      stub_current_user(teaching_assistant, teaching_assistant.role.name, teaching_assistant.role)
      expect(current_user_has_super_admin_privileges?).to be false
    end

    it 'returns false for an instructor' do
      stub_current_user(instructor, instructor.role.name, instructor.role)
      expect(current_user_has_super_admin_privileges?).to be false
    end

    it 'returns false for an admin' do
      stub_current_user(admin, admin.role.name, admin.role)
      expect(current_user_has_super_admin_privileges?).to be false
    end

    it 'returns true for a super admin' do
      stub_current_user(superadmin, superadmin.role.name, superadmin.role)
      expect(current_user_has_super_admin_privileges?).to be true
    end

  end

  describe ".current_user_has_admin_privileges?" do

    it 'returns false if there is no current user' do
      expect(current_user_has_admin_privileges?).to be false
    end

    it 'returns false for a student' do
      stub_current_user(student, student.role.name, student.role)
      expect(current_user_has_admin_privileges?).to be false
    end

    it 'returns false for a TA' do
      stub_current_user(teaching_assistant, teaching_assistant.role.name, teaching_assistant.role)
      expect(current_user_has_admin_privileges?).to be false
    end

    it 'returns false for an instructor' do
      stub_current_user(instructor, instructor.role.name, instructor.role)
      expect(current_user_has_admin_privileges?).to be false
    end

    it 'returns true for an admin' do
      stub_current_user(admin, admin.role.name, admin.role)
      expect(current_user_has_admin_privileges?).to be true
    end

    it 'returns true for a super admin' do
      stub_current_user(superadmin, superadmin.role.name, superadmin.role)
      expect(current_user_has_admin_privileges?).to be true
    end

  end

  describe ".current_user_has_instructor_privileges?" do

    it 'returns false if there is no current user' do
      expect(current_user_has_instructor_privileges?).to be false
    end

    it 'returns false for a student' do
      stub_current_user(student, student.role.name, student.role)
      expect(current_user_has_instructor_privileges?).to be false
    end

    it 'returns false for a TA' do
      stub_current_user(teaching_assistant, teaching_assistant.role.name, teaching_assistant.role)
      expect(current_user_has_instructor_privileges?).to be false
    end

    it 'returns true for an instructor' do
      stub_current_user(instructor, instructor.role.name, instructor.role)
      expect(current_user_has_instructor_privileges?).to be true
    end

    it 'returns true for an admin' do
      stub_current_user(admin, admin.role.name, admin.role)
      expect(current_user_has_instructor_privileges?).to be true
    end

    it 'returns true for a super admin' do
      stub_current_user(superadmin, superadmin.role.name, superadmin.role)
      expect(current_user_has_instructor_privileges?).to be true
    end

  end

  describe ".current_user_has_ta_privileges?" do

    it 'returns false if there is no current user' do
      expect(current_user_has_ta_privileges?).to be false
    end

    it 'returns false for a student' do
      stub_current_user(student, student.role.name, student.role)
      expect(current_user_has_ta_privileges?).to be false
    end

    it 'returns true for a TA' do
      stub_current_user(teaching_assistant, teaching_assistant.role.name, teaching_assistant.role)
      expect(current_user_has_ta_privileges?).to be true
    end

    it 'returns true for an instructor' do
      stub_current_user(instructor, instructor.role.name, instructor.role)
      expect(current_user_has_ta_privileges?).to be true
    end

    it 'returns true for an admin' do
      stub_current_user(admin, admin.role.name, admin.role)
      expect(current_user_has_ta_privileges?).to be true
    end

    it 'returns true for a super admin' do
      stub_current_user(superadmin, superadmin.role.name, superadmin.role)
      expect(current_user_has_ta_privileges?).to be true
    end

  end

  describe ".current_user_has_student_privileges?" do

    it 'returns false if there is no current user' do
      expect(current_user_has_student_privileges?).to be false
    end

    it 'returns true for a student' do
      stub_current_user(student, student.role.name, student.role)
      expect(current_user_has_student_privileges?).to be true
    end

    it 'returns true for a TA' do
      stub_current_user(teaching_assistant, teaching_assistant.role.name, teaching_assistant.role)
      expect(current_user_has_student_privileges?).to be true
    end

    it 'returns true for an instructor' do
      stub_current_user(instructor, instructor.role.name, instructor.role)
      expect(current_user_has_student_privileges?).to be true
    end

    it 'returns true for an admin' do
      stub_current_user(admin, admin.role.name, admin.role)
      expect(current_user_has_student_privileges?).to be true
    end

    it 'returns true for a super admin' do
      stub_current_user(superadmin, superadmin.role.name, superadmin.role)
      expect(current_user_has_student_privileges?).to be true
    end

  end

end
