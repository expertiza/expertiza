include Rails.application.routes.url_helpers
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
  end

  describe '#fullname' do
    it 'returns the full name of the user' do
      expect(user.fullname).to eq('abc xyz')
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
      all_users = double
      user_mock1 = double(:role=>'Instructor')
      user_mock2 = double(:role=>'Administrator')
      user_mock3 = double(:role=>'Student')
      allow(@role).to receive(:get_parents).and_return(['Instructor','Administrator'])
      allow(User).to receive(:all).and_return([user_mock1,user_mock2,user_mock3])
      allow(all_users).to receive(:select).and_yield(user_mock2).and_yield(user_mock2).and_yield(user_mock3)
      expect(user.get_available_users("abc")).to eq ([user_mock1,user_mock2])
    end
  end

  describe '#can_impersonate?' do
    it 'can impersonate target user if current user is super admin' do
      allow(user1).to receive_message_chain("role.super_admin?"){true}
      expect(user1.can_impersonate?(user)).to be true
    end
    it 'can impersonate target user if current user is the TA of target user'do
      allow(user1).to receive_message_chain("role.super_admin?"){false}
      allow(user1).to receive(:teaching_assistant_for?).and_return(user)
      expect(user1.can_impersonate?(user)).to be true

    end
    it 'can impersonate target user if current user is the recursively parent of target user'do
      allow(user1).to receive_message_chain("role.super_admin?"){true}
      allow(user1).to receive(:recursively_parent_of).and_return(user)
      expect(user1.can_impersonate?(user)).to be true
    end
    it 'cannot impersonate target user if current user does not satisfy all requirements'do
      allow(user1).to receive_message_chain("role.super_admin?"){false}
      allow(user1).to receive_message_chain("role.ta?"){false}
      expect(user1.can_impersonate?(user)).to be false
    end
  end

  describe '#recursively_parent_of' do
    context 'when the parent of target user (user) is nil' do
      it 'returns false' do
        allow(user).to receive(:parent).and_return(nil)
        expect(user1.recursively_parent_of(user)).to eq false
      end
    end

    context 'when the parent of target user (user) is current user (user1)' do
      it 'returns true' do
        allow(user).to receive(:parent).and_return(user1)
        expect(user1.recursively_parent_of(user)).to eq true
      end
    end

    context 'when the parent of target user (user) is not current user (user1), but super admin (user2)' do
      it 'returns false' do
        allow(user).to receive(:parent).and_return(user2)
        allow(user2).to receive_message_chain("role.super_admin?") { true }
        expect(user1.recursively_parent_of(user)).to eq false
      end
    end
  end

  describe '#get_user_list' do
    context 'when current user is super admin' do
      it 'fetches all users' do
        allow(user).to receive_message_chain("role.super_admin?"){ true }
        allow(user).to receive_message_chain("role.instructor?"){ false }
        allow(user).to receive_message_chain("role.ta?"){false}
        allow(SuperAdministrator).to receive(:get_user_list).and_return([user1,user2])
        expect(user.get_user_list).to eq ([user1,user2])
      end
  end
    context 'when current user is an instructor' do
      it 'fetches all users in his/her course/assignment' do
        allow(user).to receive_message_chain("role.super_admin?"){ false }
        allow(user).to receive_message_chain("role.instructor?"){ true }
        allow(user).to receive_message_chain("role.ta?"){false}
        allow(Instructor).to receive(:get_user_list).and_return([user1,user2])
        expect(user.get_user_list).to eq ([user1,user2])
      end
    end

    context 'when current user is a TA' do
      it 'fetches all users in his/her courses'do
        allow(user).to receive_message_chain("role.super_admin?"){ false }
        allow(user).to receive_message_chain("role.ta?"){ true }
        allow(user).to receive_message_chain("role.instructor?"){ false }
        allow(Ta).to receive(:get_user_list).and_return([user1,user2])
        expect(user.get_user_list).to eq ([user1,user2])
    end
    end
  end

  describe '#super_admin?' do
    it 'returns ture if role name is Super-Administrator' do
      allow(user).to receive_message_chain("role.name"){'Super-Administrator'}
      expect(user.super_admin?).to be_truthy
    end

    it 'returns false if role name is not Super-Administrator' do
      allow(user).to receive_message_chain("role.name"){'CAt'}
      expect(user.super_admin?).to be_falsey
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
      row = ["abc","abc xyz"]
      _row_header = double
      seesion = {:user=>user}
      _id = double
      expect { User.import(row, _row_header,seesion,_id) }.to raise_error("Not enough items: expect 3 columns: your login name, your full name (first and last name, not seperated with the delimiter), and your email.")
    end
    it 'updates an existing user with info from impor file' do
      row = ["abc","abc xyz","abcxyz@gamil.com"]
      _row_header = double
      seesion = {:user=>user}
      _id = double
      allow(User).to receive(:find_by).and_return(user)
      allow_any_instance_of(User).to receive(:nil?).and_return(false)
      allow_any_instance_of(User).to receive(:id).and_return(1)
      expect_any_instance_of(User).to receive(:save)
      User.import(row,_row_header,seesion,_id)
    end

  end

  describe '.yesorno' do
    it 'returns yes when input is true' do
      expect(User.yesorno(true)).to eq "yes"
    end
    it 'returns no when input is false' do
      expect(User.yesorno(false)).to eq "no"
    end
    it 'returns empty string when input is other content' do
      content = "TEXT"
      expect(User.yesorno(content)).to eq ""
    end
  end

  describe '.find_by_login' do
    context 'when user\'s email is stored in DB' do
      it 'finds user by email' do
        email = 'abcxyz@gmail.com'
        allow(User).to receive(:find_by).and_return(user)
        expect(User.find_by_login(email)).to eq user
      end
    end

    context 'when user\'s email is not stored in DB' do
      it 'finds user by email if the local part of email is the same as username' do
        allow(User).to receive(:find_by).and_return(nil)
        allow(User).to receive(:where).and_return([{name: 'abc', fullname: 'abc bbc'}])
        expect(User.find_by_login('abcxyz@gmail.com')).to eq ({:name=>"abc", :fullname=>"abc bbc"})
      end
    end
  end

  describe '#get_instructor' do
    it 'gets the instructor id' do
      allow(user).to receive(:id).and_return(123)
      expect(user.get_instructor).to eq(123)
      end
  end

  describe '#instructor_id' do
    it 'returns id when role of current user is a super admin' do
      allow(user).to receive_message_chain(:role,:name).and_return('Super-Administrator')
      allow(user).to receive(:id).and_return(1)
      expect(user.instructor_id).to eq(1)
    end

    it 'returns id when role of current user is an Administrator' do
      allow(user).to receive_message_chain(:role,:name).and_return('Administrator')
      allow(user).to receive(:id).and_return(2)
      expect(user.instructor_id).to eq(2)
    end

    it 'returns id when role of current user is an Instructor' do
      allow(user).to receive_message_chain(:role,:name).and_return('Instructor')
      allow(user).to receive(:id).and_return(3)
      expect(user.instructor_id).to eq(3)
    end

    it 'returns instructor_id when role of current user is a TA' do
      allow(user).to receive_message_chain(:role,:name).and_return('Teaching Assistant')
      allow(Ta).to receive(:get_my_instructor).and_return(4)
      expect(user.instructor_id).to eq(4)
    end

    it 'raise an error when role of current user is other type' do
      allow(user).to receive_message_chain(:role,:name).and_return('abc')
      expect{user.instructor_id}.to raise_error(NotImplementedError,"for role abc")
    end

  end

  describe '.export' do
    before(:each) do
      allow(user).to receive_message_chain(:role,:name).and_return('abc')
      allow(user).to receive_message_chain(:parent,:name).and_return('abc')
      allow(User).to receive(:all).and_return([user])
      allow_any_instance_of(User).to receive(:each).and_yield(user)
    end

    it 'exports all information setting in options' do
      options={"personal_details"=>"true", "role"=>"true","parent"=>"true","email_options"=>"true","handle"=>"true"}
      csv=[]
      User.export(csv,0 , options)
      expect(csv).to eq([[user.name,user.fullname,user.email,
                                                 user.role.name,user.parent.name,user.email_on_submission, user.email_on_review,
                                                 user.email_on_review_of_review, user.copy_of_emails,user.handle]])
    end

    it 'exports only personal_details'do
      options={"personal_details"=>"true", "role"=>"false","parent"=>"false","email_options"=>"false","handle"=>"false"}
      csv=[]
      User.export(csv,0 , options)
      expect(csv).to eq([[user.name,user.fullname,user.email]])
    end

    it 'exports only current role and parent' do
      options={"personal_details"=>"false", "role"=>"true","parent"=>"true","email_options"=>"false","handle"=>"false"}
      csv=[]
      User.export(csv,0 , options)
      expect(csv).to eq([[user.role.name,user.parent.name]])
    end

    it 'exports only email_options' do
      options={"personal_details"=>"false", "role"=>"false","parent"=>"false","email_options"=>"true","handle"=>"false"}
      csv=[]
      User.export(csv,0 , options)
      expect(csv).to eq([[user.email_on_submission, user.email_on_review,user.email_on_review_of_review, user.copy_of_emails]])
    end

    it 'exports only handle' do
      options={"personal_details"=>"false", "role"=>"false","parent"=>"false","email_options"=>"false","handle"=>"true"}
      csv=[]
      User.export(csv,0 , options)
      expect(csv).to eq([[user.handle]])
    end
  end

  describe '.export_fields' do
    it 'exports all information setting in options' do
      options={"personal_details"=>"true","role"=>"true","parent"=>"true","email_options"=>"true","handle"=>"true"}
      expect(User.export_fields(options)).to eq(["name","full name","email","role","parent","email on submission","email on review","email on metareview","handle"])
    end

    it 'exports only personal_details' do
      options={"personal_details"=>"true","role"=>"false","parent"=>"false","email_options"=>"false","handle"=>"false"}
      expect(User.export_fields(options)).to eq(["name","full name","email"])
    end

    it 'exports only current role and parent' do
      options={"personal_details"=>"false","role"=>"true","parent"=>"true","email_options"=>"false","handle"=>"false"}
      expect(User.export_fields(options)).to eq(["role","parent"])
    end

    it 'exports only email_options' do
      options={"personal_details"=>"false","role"=>"false","parent"=>"false","email_options"=>"true","handle"=>"false"}
      expect(User.export_fields(options)).to eq(["email on submission","email on review","email on metareview"])
    end

    it 'exports only handle' do
      options={"personal_details"=>"false","role"=>"false","parent"=>"false","email_options"=>"false","handle"=>"true"}
      expect(User.export_fields(options)).to eq(["handle"])
    end
  end

  describe '.from_params' do
    it 'returns user by user_id fetching from params' do
      params = {
        :user_id => 1,
      }
      allow(User).to receive(:find).and_return(user)
      expect(User.from_params(params)).to eq user
    end
    it 'returns user by user name fetching from params' do
      params = {
        :user => {
          :name => 'abc'
        }
      }
      allow(User).to receive(:find_by).and_return(user)
      expect(User.from_params(params)).to eq user
    end
    it 'raises an error when Expertiza cannot find user' do
      params = {
        :user => {
          :name => 'ncsu'
        }
      }
      allow(user).to receive(:nil?).and_return(true)
      expect {User.from_params(params)}.to raise_error("Please <a href='http://localhost:3000/users/new'>create an account</a> for this user to continue.")
    end
  end

  describe '#teaching_assistant_for?' do
    it 'returns false if current user is not a TA' do
      allow(user1).to receive_message_chain("role.ta?"){ false }
      expect(user1.teaching_assistant_for?(user)).to be_falsey
    end

    it 'returns false if current user is a TA, but target user is not a student'do
      allow(user1).to receive_message_chain("role.ta?"){true }
      allow(user).to receive_message_chain("role.name").and_return('teacher')
      expect(user1.teaching_assistant_for?(user)).to be_falsey
    end

    it 'returns true if current user is a TA of target user'do
    allow(Ta).to receive(:find).and_return(user1)
    allow(user1).to receive_message_chain("role.ta?"){ true }
    allow(user).to receive_message_chain("role.name").and_return('Student')
    c1=Course.new
    allow(user1).to receive_message_chain(:courses_assisted_with,:any?).and_yield(c1)
    allow_any_instance_of(Course).to receive_message_chain(:assignments,:map,:flatten,:map,:include?,:user).and_return(true)
    expect(user1.teaching_assistant_for?(user)).to be true
    end
  end

  describe '#teaching_assistant?' do
    it 'returns true if current user is a TA' do
      allow(user).to receive_message_chain("role.ta?"){ true }
      expect(user.teaching_assistant?).to be true
    end

    it 'returns false if current user is not a TA' do
      allow(user).to receive_message_chain("role.ta?"){ false }
      expect(user.teaching_assistant?).to be_falsey
    end
  end

  describe '.search_users' do

    let(:role) { Role.new }
    before(:each) do
        allow(User).to receive_message_chain(:order,:where).and_return(user)
    end

    it 'when the search_by is 1' do
      search_by = "1"
      user_id = double
      letter = 'name'
      search_filter = '%' + letter + '%'
      expect(User).to receive_message_chain(:order,:where).with("(role_id in (?) or id = ?) and name like ?", role.get_available_roles, user_id, search_filter)
      expect(User.search_users(role,user_id,letter,search_by)).to eq user
    end

    it 'when the search_by is 2' do
      search_by = "2"
      user_id = double
      letter = 'fullname'
      search_filter = '%' + letter + '%'
      expect(User).to receive_message_chain(:order,:where).with("(role_id in (?) or id = ?) and fullname like ?", role.get_available_roles, user_id, search_filter)
      expect(User.search_users(role,user_id,letter,search_by)).to eq user
    end

    it 'when the search_by is 3' do
      search_by = "3"
      user_id = double
      letter = 'email'
      search_filter = '%' + letter + '%'
      expect(User).to receive_message_chain(:order,:where).with("(role_id in (?) or id = ?) and email like ?", role.get_available_roles, user_id, search_filter)
      expect(User.search_users(role,user_id,letter,search_by)).to eq user
    end

    it 'when the search_by is default value' do
      search_by = nil
      user_id = double
      letter = ''
      search_filter = letter + '%'
      expect(User).to receive_message_chain(:order,:where).with("(role_id in (?) or id = ?) and name like ?", role.get_available_roles, user_id, search_filter)
      expect(User.search_users(role,user_id,letter,search_by)).to eq user
    end
  end
end
