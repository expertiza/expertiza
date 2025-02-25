describe StudentViewController do
  let(:instructor) { build(:instructor, id: 2) }
  let(:student1) { build(:student, id: 30, username: :Amanda) }
  # student view is only accessible to instructors, so we will make one

  before(:each) do
    stub_current_user(instructor, instructor.role.name, instructor.role)
  end

  describe 'check access' do
    it 'instructor should be able to call flip user' do
      expect(controller.action_allowed?).to be true
    end

    it 'student should not be able to call flip user' do
      stub_current_user(student1, student1.role.name, student1.role)
      expect(controller.action_allowed?).to be false
    end
  end

  describe 'the student view flag working as expected' do
    it 'flag should not be initialized by default' do
      expect(session[:flip_user]).to eq nil
    end

    it 'flag should be set to true after selecting student view' do
      post :flip_view
      expect(session[:flip_user]).to eq true
    end

    it 'flag should become false after using student view twice' do
      post :flip_view
      post :flip_view
      expect(session[:flip_user]).to eq false
    end
  end

  describe 'navigation should work as intended' do
    it 'should be redirected to homepage after entering student view' do
      post :flip_view
      expect(response).to redirect_to('/')
    end

    it 'should be redirected to homepage after exiting student view' do
      post :flip_view
      post :flip_view
      expect(response).to redirect_to('/')
    end
  end
end
