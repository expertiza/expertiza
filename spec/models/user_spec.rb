describe User do
  let(:user) do
    User.new name: 'abc', fullname: 'abc xyz', email: 'abcxyz@gmail.com', password: '12345678', password_confirmation: '12345678',
             email_on_submission: 1, email_on_review: 1, email_on_review_of_review: 0, copy_of_emails: 1, handle: 'handle'
  end
  let(:user1) { User.new name: 'abc', fullname: 'abc bbc', email: 'abcbbc@gmail.com', password: '123456789', password_confirmation: '123456789' }
  let(:user2) { User.new name: 'abc', fullname: 'abc bbc', email: 'abcbbe@gmail.com', password: '123456789', password_confirmation: '123456789' }

  describe '#name' do
    it 'returns the name of the user' do
      expect(user.name).to eq('abc')
    end
    it 'Validate presence of name which cannot be blank' do
      expect(user).to be_valid
      user.name = '  '
      expect(user).not_to be_valid
    end
    it 'Validate that name is always unique' do
      expect(user1).to validate_uniqueness_of(:name)
    end
    it 'Validate that the name does not contain white spaces' do
      expect(user).to be_valid
      user.name = 'abc def'
      expect(user).not_to be_valid
    end
  end

  describe '#fullname' do
    it 'returns the full name of the user' do
      expect(user.fullname).to eq('abc xyz')
    end

    it 'Validate presence of fullname which cannot be blank' do
      user.fullname = '  '
      expect(user).not_to be_valid
    end

    it 'Validate the email format correctness' do
      user.fullname = 'John Bumgardner'
      expect(user).to be_valid
    end
  end

  describe '#email' do
    it 'returns the email of the user' do
      expect(user.email).to eq('abcxyz@gmail.com')
    end

    it 'Validate presence of email which cannot be blank' do
      user.email = '  '
      expect(user).not_to be_valid
    end

    it 'Validate the email format' do
      user.email = 'a@x'
      expect(user).not_to be_valid
    end

    it 'Validate the email format' do
      user.email = 'ax.com'
      expect(user).not_to be_valid
    end

    it 'Validate the email format' do
      user.email = 'axc'
      expect(user).not_to be_valid
    end

    it 'Validate the email format' do
      user.email = '123'
      expect(user).not_to be_valid
    end

    it 'Validate the email format correctness' do
      user.email = 'a@x.com'
      expect(user).to be_valid
    end
  end

  describe '#salt_first?' do
    it 'will always return true' do
      expect(user.salt_first?).to be true
    end
  end

  describe '#get_available_users' do
    before(:each) do
      role = Role.new
    end
    it 'returns the first 10 visible users' do
      allow(user).to receive_message_chain(:role, :get_parents).and_return(['Student'])
      allow(user1).to receive(:role).and_return('Student')
      allow(user2).to receive(:role).and_return('Student')
      expect(user.role.get_parents).to eq(['Student'])
      allow(User).to receive(:all).with(conditions: ['name LIKE ?', 'abc%'], limit: 20).and_return([user1, user2])
      expect(user.get_available_users(user.name)).to eq([user1, user2])
    end
  end

  describe '#can_impersonate?' do
    it 'can impersonate target user if current user is super admin' do
      allow(user).to receive_message_chain(:role, :super_admin?).and_return(true)
      expect(user.can_impersonate?(user1)).to be true
    end

    it 'can impersonate target user if current user is the TA of target user' do
      allow(user).to receive_message_chain(:role, :super_admin?).and_return(false)
      allow(user).to receive(:teaching_assistant_for?).with(user1).and_return(true)
      expect(user.can_impersonate?(user1)).to be true
    end

    it 'can impersonate target user if current user is the recursively parent of target user' do
      allow(user).to receive_message_chain(:role, :super_admin?).and_return(false)
      allow(user).to receive(:teaching_assistant_for?).with(user1).and_return(false)
      allow(user).to receive(:recursively_parent_of).with(user1).and_return(true)
      expect(user.can_impersonate?(user1)).to be true
    end

    it 'cannot impersonate target user if current user does not satisfy all requirements' do
      allow(user).to receive_message_chain(:role, :super_admin?).and_return(false)
      allow(user).to receive(:teaching_assistant_for?).with(user1).and_return(false)
      allow(user).to receive(:recursively_parent_of).with(user1).and_return(false)
      expect(user.can_impersonate?(user1)).to be false
    end
  end

  describe '#recursively_parent_of' do
    context 'when the parent of target user (user) is nil' do
      it 'returns false' do
        allow(user).to receive(:parent).and_return(nil)
        expect(user1.recursively_parent_of(user)).to be false
      end
    end

    context 'when the parent of target user (user) is current user (user1)' do
      it 'returns true' do
        allow(user).to receive(:parent).and_return(user1)
        expect(user1.recursively_parent_of(user)).to be true
      end
    end

    context 'when the parent of target user (user) is not current user (user1), but super admin (user2)' do
      it 'returns false' do
        allow(user).to receive(:parent).and_return(user2)
        allow(user2).to receive_message_chain(:role, :super_admin?).and_return(true)
        expect(user1.recursively_parent_of(user)).to be false
      end
    end
  end

  describe '#get_user_list' do
    before(:each) do
      allow(user).to receive_message_chain('role.super_admin?') { false }
      allow(user).to receive_message_chain('role.instructor?') { false }
      allow(user).to receive_message_chain('role.ta?') { false }
      allow(SuperAdministrator).to receive(:get_user_list).and_return([user1, user2])
      allow(Instructor).to receive(:get_user_list).and_return([user1, user2])
      allow(Ta).to receive(:get_user_list).and_return([user1, user2])
    end

    context 'when current user is super admin' do
      it 'fetches all users' do
        allow(user).to receive_message_chain('role.super_admin?') { true }
        expect(user.get_user_list).to eq([user1, user2])
      end
    end

    context 'when current user is an instructor' do
      it 'fetches all users in his/her course/assignment' do
        allow(user).to receive_message_chain('role.instructor?') { true }
        expect(user.get_user_list).to eq([user1, user2])
      end
    end

    context 'when current user is a TA' do
      it 'fetches all users in his/her courses' do
        allow(user).to receive_message_chain('role.ta?') { true }
        expect(user.get_user_list).to eq([user1, user2])
      end
    end
  end

  describe '#super_admin?' do
    it 'returns true if role name is Super-Administrator' do
      allow(user).to receive(:role).and_return(double(:role, name: 'Super-Administrator'))
      expect(user.super_admin?).to be true
    end

    it 'returns false if role name is not Super-Administrator' do
      allow(user).to receive(:role).and_return(double(:role, name: 'Student'))
      expect(user.super_admin?).to be false
    end
  end

  describe '#creator_of?' do
    it 'returns true of current user (user) is the creator of target user (user1)' do
      allow(user1).to receive(:creator).and_return(user)
      expect(user.creator_of?(user1)).to be true
    end

    it 'returns false of current user (user) is not the creator of target user (user1)' do
      allow(user1).to receive(:creator).and_return(user2)
      expect(user.creator_of?(user1)).to be false
      expect(user2.creator_of?(user1)).to be true
    end
  end

  describe '.import' do
    it 'raises error if import column does not equal to 3' do
      row = { 'name' => 'abc', 'fullname' => 'abc xyz' }
      expect { User.import(row, nil, nil, nil) }.to raise_error(ArgumentError)
    end

    it 'updates an existing user with info from impor file' do
      create(:student, name: 'abc')
      row = { name: 'abc', fullname: 'test, test', email: 'test@gmail.com' }
      allow(user).to receive(:id).and_return(6)
      User.import(row, nil, { user: user }, nil)
      updated_user = User.find_by(name: 'abc')
      expect(updated_user.email).to eq 'test@gmail.com'
      expect(updated_user.fullname).to eq 'test, test'
      expect(updated_user.parent_id).to eq 6
    end
  end

  describe '.yesorno' do
    it 'returns yes when input is true' do
      expect(User.yesorno(true)).to eq 'yes'
    end

    it 'returns no when input is false' do
      expect(User.yesorno(false)).to eq 'no'
    end

    it 'returns empty string when input is other content' do
      expect(User.yesorno('other')).to eq ''
    end
  end

  describe '.find_by_login' do
    context 'when user\'s email is stored in DB' do
      it 'finds user by email' do
        allow(User).to receive(:find_by).with(email: 'abcxyz@gmail.com').and_return(user)
        expect(User.find_by_login('abcxyz@gmail.com')).to eq(user)
      end
    end

    context 'when user\'s email is not stored in DB' do
      it 'finds user by email if the local part of email is the same as username' do
        allow(User).to receive(:find_by).with(email: 'abc@gmail.com').and_return(nil)
        allow(User).to receive(:where).with('name = ?', 'abc').and_return([user])
        expect(User.find_by_login('abc@gmail.com')).to eq(user)
      end
    end
  end

  describe '#get_instructor' do
    it 'gets the instructor id' do
      user.id = 6
      expect(user.get_instructor).to eq 6
    end
  end

  describe '#instructor_id' do
    before(:each) { user.id = 1 }
    it 'returns id when role of current user is a super admin' do
      allow(user).to receive_message_chain(:role, :name).and_return('Super-Administrator')
      expect(user.instructor_id).to eq 1
    end

    it 'returns id when role of current user is an Administrator' do
      allow(user).to receive_message_chain(:role, :name).and_return('Administrator')
      expect(user.instructor_id).to eq 1
    end

    it 'returns id when role of current user is an Instructor' do
      allow(user).to receive_message_chain(:role, :name).and_return('Instructor')
      expect(user.instructor_id).to eq 1
    end

    it 'returns instructor_id when role of current user is a TA' do
      allow(user).to receive_message_chain(:role, :name).and_return('Teaching Assistant')
      allow(Ta).to receive(:get_my_instructor).and_return(6)
      expect(user.instructor_id).to eq 6
    end

    it 'raise an error when role of current user is other type' do
      allow(user).to receive_message_chain(:role, :name).and_return('Student')
      expect { user.instructor_id }.to raise_error(NotImplementedError, /for role Student/)
    end
  end

  describe '.export' do
    before(:each) do
      allow(User).to receive(:all).and_return([user])
      allow(user).to receive_message_chain(:role, :name).and_return('Student')
      allow(user).to receive_message_chain(:parent, :name).and_return('Instructor')
    end

    it 'exports all information setting in options' do
      @csv = []
      User.export(@csv, nil, 'personal_details' => 'true', 'role' => 'true', 'parent' => 'true', 'email_options' => 'true', 'handle' => 'true')
      expect(@csv).to eq([['abc', 'abc xyz', 'abcxyz@gmail.com', 'Student', 'Instructor', true, true, false, true, 'handle']])
    end

    it 'exports only personal_details' do
      @csv = []
      User.export(@csv, nil, 'personal_details' => 'true')
      expect(@csv).to eq([['abc', 'abc xyz', 'abcxyz@gmail.com']])
    end

    it 'exports only current role and parent' do
      @csv = []
      User.export(@csv, nil, 'role' => 'true', 'parent' => 'true')
      expect(@csv).to eq([%w[Student Instructor]])
    end

    it 'exports only email_options' do
      @csv = []
      User.export(@csv, nil, 'email_options' => 'true')
      expect(@csv).to eq([[true, true, false, true]])
    end

    it 'exports only handle' do
      @csv = []
      User.export(@csv, nil, 'handle' => 'true')
      expect(@csv).to eq([['handle']])
    end
  end

  describe '.export_fields' do
    it 'exports all information setting in options' do
      expect(User.export_fields('personal_details' => 'true', 'role' => 'true', 'parent' => 'true', 'email_options' => 'true', 'handle' => 'true'))
        .to eq(['name', 'full name', 'email', 'role', 'parent', 'email on submission', 'email on review', 'email on metareview', 'copy of emails', 'handle'])
    end

    it 'exports only personal_details' do
      expect(User.export_fields('personal_details' => 'true'))
        .to eq(['name', 'full name', 'email'])
    end

    it 'exports only current role and parent' do
      expect(User.export_fields('role' => 'true', 'parent' => 'true'))
        .to eq(%w[role parent])
    end

    it 'exports only email_options' do
      expect(User.export_fields('email_options' => 'true'))
        .to eq(['email on submission', 'email on review', 'email on metareview', 'copy of emails'])
    end

    it 'exports only handle' do
      expect(User.export_fields('handle' => 'true'))
        .to eq(['handle'])
    end
  end

  describe '.from_params' do
    it 'returns user by user_id fetching from params' do
      allow(User).to receive(:find).with(1).and_return(user)
      expect(User.from_params(user_id: 1)).to eq(user)
    end

    it 'returns user by user name fetching from params' do
      allow(User).to receive(:find_by).with(name: 'abc').and_return(user)
      expect(User.from_params(user: { name: 'abc' })).to eq(user)
    end

    it 'raises an error when Expertiza cannot find user' do
      allow_any_instance_of(Object).to receive(:url_for).with(controller: 'users', action: 'new').and_return('users/new/1')
      expect { User.from_params(user: {}) }.to raise_error(RuntimeError, %r{a href='users/new/1'>create an account</a> for this user to continue})
    end
  end

  describe '#teaching_assistant_for?' do
    it 'returns false if current user is not a TA' do
      allow(user).to receive(:teaching_assistant?).and_return(false)
      expect(user.teaching_assistant_for?(user1)).to be false
      expect(user.teaching_assistant_for?(user2)).to be false
    end

    it 'returns false if current user is a TA, but target user is not a student' do
      allow(user).to receive(:teaching_assistant?).and_return(true)
      allow(user1).to receive_message_chain(:role, :name).and_return('Instructor')
      expect(user.teaching_assistant_for?(user1)).to be false
    end

    it 'returns true if current user is a TA of target user' do
      allow(user).to receive(:teaching_assistant?).and_return(true)
      allow(user1).to receive_message_chain(:role, :name).and_return('Student')
      allow(user2).to receive_message_chain(:role, :name).and_return('Student')
      user.id = 1
      allow(Ta).to receive(:find).with(1).and_return(user)
      course = double('Course')
      allow(user).to receive(:courses_assisted_with).and_return([course])
      allow(course).to receive_message_chain(:assignments, :map, :flatten, :map).and_return([2, 3])
      user1.id = 2
      user2.id = 4
      expect(user.teaching_assistant_for?(user1)).to be true
      expect(user.teaching_assistant_for?(user2)).to be nil
    end
  end

  describe '#teaching_assistant?' do
    it 'returns true if current user is a TA' do
      allow(user).to receive_message_chain(:role, :ta?).and_return(true)
      expect(user.teaching_assistant?).to be true
    end

    it 'returns false if current user is not a TA' do
      allow(user).to receive_message_chain(:role, :ta?).and_return(false)
      expect(user.teaching_assistant?).to be nil
    end
  end

  # E1991 : tests for anonymized view helper function
  describe '#anonymized_view?' do
    it 'returns true when anonymized view is set' do
      allow(user).to receive(:anonymized_view?).and_return(true)
      expect(user.anonymized_view?).to be true
    end

    it 'returns false when anonymized view is set' do
      allow(user).to receive(:anonymized_view?).and_return(false)
      expect(user.anonymized_view?).to be false
    end
  end

  # E1991 : checking whether anonymized view names functionality works
  describe '#anonymized_view' do
    it 'returns anonymized name when anonymized view is set' do
      student = create(:student)
      allow(User).to receive(:anonymized_view?).and_return(true)
      expect(student.name).to eq 'Student ' + student.id.to_s
    end

    it 'returns real name when anonymized view is not set' do
      student = create(:student)
      allow(User).to receive(:anonymized_view?).and_return(false)
      expect(student.name).not_to eq 'Student ' + student.id.to_s
    end

    # this test case is applicable to impersonate mode
    it 'returns correct real name from anonymized name' do
      student = create(:student)
      expect(student.name).not_to eq 'Student' + student.id.to_s
      real_student = User.real_user_from_anonymized_name(student.name)
      expect(student.name).to eq real_student.name
      expect(student).to eq real_student
    end
  end

  describe '.search_users' do
    let(:role) { Role.new }

    before(:each) do
      allow(User).to receive_message_chain(:order, :where).with('(role_id in (?) or id = ?) and name like ?', role.get_available_roles, @user_id, '%name%')
      allow(User).to receive_message_chain(:order, :where).with('(role_id in (?) or id = ?) and fullname like ?', role.get_available_roles, @user_id, '%fullname%')
      allow(User).to receive_message_chain(:order, :where).with('(role_id in (?) or id = ?) and email like ?', role.get_available_roles, @user_id, '%email%')
      user_id = double
    end

    it 'when the search_by is 1' do
      search_by = '1'
      allow(User).to receive_message_chain(:order, :where).and_return(user)
      expect(User.search_users(role, @user_id, 'name', search_by)).to eq user
    end

    it 'when the search_by is 2' do
      search_by = '2'
      allow(User).to receive_message_chain(:order, :where).and_return(user)
      expect(User.search_users(role, @user_id, 'fullname', search_by)).to eq user
    end

    it 'when the search_by is 3' do
      search_by = '3'
      allow(User).to receive_message_chain(:order, :where).and_return(user)
      expect(User.search_users(role, @user_id, 'email', search_by)).to eq user
    end

    it 'when the search_by is default value' do
      search_by = nil
      allow(User).to receive_message_chain(:order, :where).and_return(user)
      expect(User.search_users(role, @user_id, '', search_by)).to eq user
    end
  end
end
