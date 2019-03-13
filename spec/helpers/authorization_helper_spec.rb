describe AuthorizationHelper do

  # E1915 TODO each and every method defined in app/helpers/authorization_helper.rb should be thoroughly tested here

  # Set up some dummy users
  # Inspired by spec/controllers/users_controller_spec.rb
  # Makes use of spec/factories/factories.rb
  # Use create instead of build so that these users get IDs
  # https://stackoverflow.com/questions/41149787/how-do-i-create-an-user-id-for-a-factorygirl-build
  let(:student) { create(:student) }
  let(:teaching_assistant) { create(:teaching_assistant) }
  let(:instructor) { create(:instructor) }
  let(:admin) { create(:admin) }
  let(:superadmin) { create(:superadmin) }
  let(:assignment_team) {create(:assignment_team)}

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

  # OTHER HELPER METHODS

  describe ".current_user_is_assignment_participant?" do
    # Makes use of existing :assignment_team and :participant factories
    # Both factories point to Assignment.first

    it 'returns false if there is no current user' do
      create(:participant, user: session[:user])
      expect(current_user_is_assignment_participant?(assignment_team.id)).to be false
    end

    it 'returns false if an erroneous id is passed in' do
      stub_current_user(student, student.role.name, student.role)
      create(:participant, user: session[:user])
      expect(current_user_is_assignment_participant?(-1)).to be false
    end

    it 'returns false if the current user does not participate in the assignment' do
      stub_current_user(student, student.role.name, student.role)
      expect(current_user_is_assignment_participant?(assignment_team.id)).to be false
    end

    it 'returns true if current user is a student and participates in assignment' do
      stub_current_user(student, student.role.name, student.role)
      create(:participant, user: session[:user])
      expect(current_user_is_assignment_participant?(assignment_team.id)).to be true
    end

    it 'returns true if current user is a TA and participates in assignment' do
      stub_current_user(teaching_assistant, teaching_assistant.role.name, teaching_assistant.role)
      create(:participant, user: session[:user])
      expect(current_user_is_assignment_participant?(assignment_team.id)).to be true
    end

    it 'returns true if current user is an instructor and participates in assignment' do
      stub_current_user(instructor, instructor.role.name, instructor.role)
      create(:participant, user: session[:user])
      expect(current_user_is_assignment_participant?(assignment_team.id)).to be true
    end

    it 'returns true if current user is an admin and participates in assignment' do
      stub_current_user(admin, admin.role.name, admin.role)
      create(:participant, user: session[:user])
      expect(current_user_is_assignment_participant?(assignment_team.id)).to be true
    end

    it 'returns true if current user is a super-admin and participates in assignment' do
      stub_current_user(superadmin, superadmin.role.name, superadmin.role)
      create(:participant, user: session[:user])
      expect(current_user_is_assignment_participant?(assignment_team.id)).to be true
    end

  end

  describe ".current_user_created_bookmark_id?" do

    it 'returns false if there is no current user' do
      create(:bookmark, user: student)
      expect(current_user_created_bookmark_id?(Bookmark.first.id)).to be false
    end

    it 'returns false if there is no bookmark' do
      stub_current_user(student, student.role.name, student.role)
      expect(current_user_created_bookmark_id?(12345678)).to be false
    end

    it 'returns false if the current user did not create the bookmark' do
      stub_current_user(student, student.role.name, student.role)
      create(:bookmark, user: teaching_assistant)
      expect(current_user_created_bookmark_id?(Bookmark.first.id)).to be false
    end

    it 'returns true if the current user did create the bookmark' do
      stub_current_user(student, student.role.name, student.role)
      create(:bookmark, user: student)
      expect(current_user_created_bookmark_id?(Bookmark.first.id)).to be true
    end

  end

end
