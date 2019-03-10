describe AuthorizationHelper do

  # E1915 TODO each and every method defined in app/helpers/authorization_helper.rb should be thoroughly tested here
  # E1915 TODO look at spec/controllers/assignments_controller_spec.rb for how to stub_current_user

  # Set up some dummy users
  # Inspired by spec/controllers/users_controller_spec.rb
  # Makes use of spec/factories/factories.rb
  let(:student) { build(:student) }
  let(:teaching_assistant) { build(:teaching_assistant) }
  let(:instructor) { build(:instructor) }
  let(:admin) { build(:admin) }
  let(:superadmin) { build(:superadmin) }

  # Before EACH test
  # Clear out any dummy users from the session
  # Set up some roles
  #   The helper we are testing depends on roles actually existing
  #   These are not explicitly used in the test
  #   But they must exist in memory for the helper to work correctly
  before(:each) do
    session[:user] = nil
    create(:role_of_student)
    create(:role_of_teaching_assistant)
    create(:role_of_instructor)
    create(:role_of_administrator)
    create(:role_of_superadministrator)
  end

  # TESTS

  describe ".current_user_has_ta_privileges?" do

    it 'returns false if there is no current user' do
      expect(current_user_has_ta_privileges?).to be false
    end

    it 'returns false for a student' do
      session[:user] = student
      expect(current_user_has_ta_privileges?).to be false
    end

    it 'returns true for a TA' do
      session[:user] = teaching_assistant
      expect(current_user_has_ta_privileges?).to be true
    end

    it 'returns true for an instructor' do
      session[:user] = instructor
      expect(current_user_has_ta_privileges?).to be true
    end

    it 'returns true for an admin' do
      session[:user] = admin
      expect(current_user_has_ta_privileges?).to be true
    end

    it 'returns true for a super admin' do
      session[:user] = superadmin
      expect(current_user_has_ta_privileges?).to be true
    end

  end

end
