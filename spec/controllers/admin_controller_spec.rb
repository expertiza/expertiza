describe AdminController do
  subject { User.new }

  let(:admin) { build(:admin, id: 3) }
  let(:super_admin) { build(:superadmin, id: 1) }
  let(:instructor) { build(:instructor, id: 2) }
  let(:student1) { build(:student, id: 1, name: :lily) }
  let(:student2) { build(:student) }
  let(:student3) { build(:student, id: 10, role_id: 1, parent_id: nil) }
  let(:student4) { build(:student, id: 20, role_id: 4) }
  let(:student5) { build(:student, role_id: 4, parent_id: 3) }
  let(:student6) { build(:student, role_id: nil, name: :lilith)}


  describe '#action_allowed?' do
    context 'when params action is list all instructors' do
      before(:each) do
        controller.params = {:action => 'list_instructors'}
      end

      context 'when the role of current user is Admin' do
        it 'allows certain action' do
          stub_current_user(admin, admin.role.name, admin.role)
          expect(controller.send(:action_allowed?)).to be true
        end
      end

      context 'when the role of current user is Super-Admin' do
        it 'allows certain action' do
          stub_current_user(super_admin, super_admin.role.name, super_admin.role)
          expect(controller.send(:action_allowed?)).to be true
        end
      end

      context 'when the role of current user is Instructor' do
        it 'refuses certain action' do
          stub_current_user(instructor, instructor.role.name, instructor.role)
          expect(controller.send(:action_allowed?)).to be false
        end
      end

      context 'when the role of current user is Student' do
        it 'refuses certain action' do
          stub_current_user(student1, student1.role.name, student1.role)
          expect(controller.send(:action_allowed?)).to be false
        end
      end
    end

    context 'when params action is remove an instructor' do
      before(:each) do
        controller.params = {:action => 'remove_instructor'}
      end

      context 'when the role of current user is Admin' do
        it 'allows certain action' do
          stub_current_user(admin, admin.role.name, admin.role)
          expect(controller.send(:action_allowed?)).to be true
        end
      end

      context 'when the role of current user is Super-Admin' do
        it 'allows certain action' do
          stub_current_user(super_admin, super_admin.role.name, super_admin.role)
          expect(controller.send(:action_allowed?)).to be true
        end
      end

      context 'when the role of current user is Instructor' do
        it 'refuses certain action' do
          stub_current_user(instructor, instructor.role.name, instructor.role)
          expect(controller.send(:action_allowed?)).to be false
        end
      end

      context 'when the role of current user is Student' do
        it 'refuses certain action' do
          stub_current_user(student1, student1.role.name, student1.role)
          expect(controller.send(:action_allowed?)).to be false
        end
      end
    end

    context 'when params action is other than list and remove instructors' do
      before(:each) do
        controller.params = {:action => 'remove_administrator'}
      end

      context 'when the role of current user is Admin' do
        it 'allows certain action' do
          stub_current_user(admin, admin.role.name, admin.role)
          expect(controller.send(:action_allowed?)).to be false
        end
      end

      context 'when the role of current user is Super-Admin' do
        it 'allows certain action' do
          stub_current_user(super_admin, super_admin.role.name, super_admin.role)
          expect(controller.send(:action_allowed?)).to be true
        end
      end

      context 'when the role of current user is Instructor' do
        it 'refuses certain action' do
          stub_current_user(instructor, instructor.role.name, instructor.role)
          expect(controller.send(:action_allowed?)).to be false
        end
      end

      context 'when the role of current user is Student' do
        it 'refuses certain action' do
          stub_current_user(student1, student1.role.name, student1.role)
          expect(controller.send(:action_allowed?)).to be false
        end
      end
    end
  end

  context 'list_super_administrators' do
    it 'list all the super admins' do
      allow(User).to receive(where).with(["role_id = 1"]).and_return(ActiveRecordRelationStub.new(User, [super_admin]))
      expect(@user).to eql?(ActiveRecordRelationStub.new(User, [super_admin]))
      expect(controller.send(:list_super_administrators)).to render_template('list_administrators.html.erb')
    end
  end

  context 'show_super_administrator' do
    it 'render show page' do
      allow(User).to receive(where).with(["role_id = 1"]).and_return(ActiveRecordRelationStub.new(User, [super_admin]))
      expect(@user).to eql?(ActiveRecordRelationStub.new(User, [super_admin]))
      expect(controller.send(:show_super_administrator)).to render_template('show_administrators.html.erb')
    end
  end
end
