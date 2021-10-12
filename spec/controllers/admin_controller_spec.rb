describe AdminController do
  # create fake users
  let(:admin1) { build(:admin, id: 3, role_id: 4) }
  let(:admin2) { build(:admin, id: 4, role_id: 4) }
  let(:super_admin) { build(:superadmin, id: 1, role_id: 5) }
  let(:instructor1) { build(:instructor, id: 10, role_id: 2) }
  let(:instructor2) { build(:instructor, id: 11, role_id: 2) }
  let(:student1) { build(:student, id: 21, role_id: 1) }

  before(:each) do
    allow(User).to receive(find).with('3').and_return(admin1)
    allow(User).to receive(find).with('1').and_return(super_admin)
    allow(User).to receive(find).with('10').and_return(instructor1)
    allow(User).to receive(find).with('21').and_return(student1)
    allow(User).to receive(where).with(:role_id => 4).and_return([ admin1, admin2 ])
    allow(User).to receive(where).with(:role_id => 5).and_return([ super_admin ])
    allow(User).to receive(where).with(:role_id => 2).and_return([ instructor1, instructor2 ])
    allow(Role).to recieve(superadministrator).to receive(id).and_return(5)
    allow(Role).to recieve(administrator).to receive(id).and_return(4)
    allow(Role).to recieve(instructor).to receive(id).and_return(2)
  end

  describe '#action_allowed?' do
    context 'when params action is list all instructors' do
      before(:each) do
        controller.params = {action: 'list_instructors'}
      end

      context 'when the role of current user is Admin' do
        it 'allows certain action' do
          user = admin1
          stub_current_user(user, user.role.name, user.role)
          expect(controller.send(:action_allowed?)).to be true
        end
      end

      context 'when the role of current user is Super-Admin' do
        it 'allows certain action' do
          user = super_admin
          stub_current_user(user, user.role.name, user.role)
          expect(controller.send(:action_allowed?)).to be true
        end
      end

      context 'when the role of current user is Instructor' do
        it 'refuses certain action' do
          user = instructor1
          stub_current_user(user, user.role.name, user.role)
          expect(controller.send(:action_allowed?)).to be false
        end
      end

      context 'when the role of current user is Student' do
        it 'refuses certain action' do
          user = student1
          stub_current_user(user, user.role.name, user.role)
          expect(controller.send(:action_allowed?)).to be false
        end
      end
    end

    context 'when params action is remove an instructor' do
      before(:each) do
        controller.params = {action: 'remove_instructor'}
      end

      context 'when the role of current user is Admin' do
        it 'allows certain action' do
          user = admin1
          stub_current_user(user, user.role.name, user.role)
          expect(controller.send(:action_allowed?)).to be true
        end
      end

      context 'when the role of current user is Super-Admin' do
        it 'allows certain action' do
          user = super_admin
          stub_current_user(user, user.role.name, user.role)
          expect(controller.send(:action_allowed?)).to be true
        end
      end

      context 'when the role of current user is Instructor' do
        it 'refuses certain action' do
          user = instructor1
          stub_current_user(user, user.role.name, user.role)
          expect(controller.send(:action_allowed?)).to be false
        end
      end

      context 'when the role of current user is Student' do
        it 'refuses certain action' do
          user = student1
          stub_current_user(user, user.role.name, user.role)
          expect(controller.send(:action_allowed?)).to be false
        end
      end
    end

    context 'when params action is other than list and remove instructors' do
      before(:each) do
        controller.params = {:action => 'remove_administrator'}
      end

      context 'when the role of current user is Admin' do
        it 'refuses certain action' do
          user = admin1
          expect(controller.send(:action_allowed?)).to be false
        end
      end

      context 'when the role of current user is Super-Admin' do
        it 'allows certain action' do
          user = super_admin
          stub_current_user(user, user.role.name, user.role)
          expect(controller.send(:action_allowed?)).to be true
        end
      end

      context 'when the role of current user is Instructor' do
        it 'refuses certain action' do
          user = instructor1
          stub_current_user(user, user.role.name, user.role)
          expect(controller.send(:action_allowed?)).to be false
        end
      end

      context 'when the role of current user is Student' do
        it 'refuses certain action' do
          user = student1
          stub_current_user(user, user.role.name, user.role)
          expect(controller.send(:action_allowed?)).to be false
        end
      end
    end
  end

  context '#list_super_administrators' do
    it 'list all the Super-Administrators and render #list' do
      get :list_super_administrators
      expect(@user).to eql([ super_admin ])
      expect(response).to render_template(list_super_administrators)
    end
  end

  context '#show_super_administrator' do
    it 'find selected Super-Administrator and render #show' do
      controller.params = {id: '1'}
      controller.send(:show_super_administrators)
      expect(@user).to eql(super_admin)
      expect(@role).to eql(5)
      expect(response).to render_template(show_super_administrator)
    end
  end

  context '#list_administrators' do
    it 'list all the admins and render #list' do
      get :list_administrators
      expect(response).to render_template(list_administrators)
    end
  end

  context '#show_administrator' do
    it 'find selected admin and render #show' do
      controller.params = {id: '3'}
      controller.send(:show_administrator)
      expect(@user).to eql(admin1)
      expect(@role).to eql(4)
      expect(response).to render_template(show_administrator)
    end
  end

  context '#list_instructors' do
    it 'list all the instructors and render #list' do
      get :list_instructors
      expect(response).to render_template(list_instructors)
    end
  end

  context '#show_instructors' do
    it 'find selected instructor and render #show' do
      controller.params = {id: '10'}
      controller.send(:show_instructor)
      expect(@user).to eql(instructor1)
      expect(@role).to eql(2)
      expect(response).to render_template(show_instructor)
    end
  end
end
