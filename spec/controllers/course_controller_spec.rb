describe CourseController do
  let(:instructor) { build(:instructor, id: 6) }
  let(:student) { build(:student)}
  describe '#action_allowed?' do
    context 'when current user is student' do
      it 'disallows all actions' do
        user = student
        stub_current_user(user, user.role.name, user.role)
        expect(controller.send(:action_allowed?)).to be false
      end

      it 'disallows certain action' do
        user = instructor
        stub_current_user(user, user.role.name, user.role)
        expect(controller.send(:action_allowed?)).to be true
      end
    end
  end

  describe '#create' do
    it 'redirects to tree_display#list page after creating a new course' do
      params = {
                course: {
                        name: 'CSC999',
                        private: false,
                        institutions_id: 1,
                        directory_path: '/cscs',
                        info: 'hello',
                        instructor_id: instructor.id
                }
      }
      session = {user: instructor}
      post :create, params, session
      expect(response).to redirect_to('/tree_display/list')
    end
  end

  describe '#edit' do
    context 'when @course is not nil' do
      it 'renders the course#edit page' do
        allow(Course).to receive(:find).with('1').and_return(double('Course', instructor_id: 6))
        session = {user: instructor}
        params = {id: 1}
        get :edit, params, session
        expect(response).to render_template(:edit)
      end
    end
  end
end
