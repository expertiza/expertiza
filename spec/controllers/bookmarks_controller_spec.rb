describe BookmarksController do
  # initialize any recurring objects
  let(:bookmark) { build(:bookmark) }
  let(:student) { build(:student, id: 1) }
  let(:instructor) { build(:instructor, id: 2) }
  let(:ta) { build(:teaching_assistant, id: 3) }

  # for student
  describe '#action_allowed?' do
    context 'when params action pertains to student minus edit, update, destroy' do
      before(:each) do
        @session = { user: student }
        stub_current_user(student, student.role.name, student.role)
        @request.session[:user] = student
      end

      let(:controller) { BookmarksController.new }

      it 'allows list action for student' do
        controller.params = { action: 'list' }
        expect(controller.action_allowed?).to eq('Student')
      end

      it 'allows new action for student' do
        controller.params = { action: 'new' }
        expect(controller.action_allowed?).to eq('Student')
      end

      it 'allows save_bookmark_rating_score action for student' do
        controller.params = { action: 'save_bookmark_rating_score' }
        expect(controller.action_allowed?).to eq('Student')
      end

      it 'allows create action for student' do
        controller.params = { action: 'create' }
        expect(controller.action_allowed?).to eq('Student')
      end
    end
  end

  # for instructor
  describe '#action_allowed?' do
    before(:each) do
      @session = { user: instructor }
      stub_current_user(instructor, instructor.role.name, instructor.role)
      @request.session[:user] = instructor
    end

    it 'allows list action for instructor' do
      controller.params = { action: 'list' }
      expect(controller.action_allowed?).to eq('Instructor')
    end

    it 'not allow list action for instructor' do
      controller.params = { action: 'list' }
      expect(controller.action_allowed?).not_to eq('Student')
    end
  end

  # for teaching  assistant
  describe '#action_allowed?' do
    before(:each) do
      @session = { user: instructor }
      stub_current_user(ta, ta.role.name, ta.role)
      @request.session[:user] = ta
    end

    it 'allows list action for ta' do
      controller.params = { action: 'list' }
      expect(controller.action_allowed?).to eq('Teaching Assistant')
    end

    it 'not allow list action for ta' do
      controller.params = { action: 'list' }
      expect(controller.action_allowed?).not_to eq('Student')
    end
  end

  # for special cases of edit, update, destroy params actions
  describe '#action_allowed?' do
    context 'when edit, update, destroy params action pertains to student' do
      before(:each) do
        allow(Bookmark).to receive(:find).with(1).and_return(bookmark)
        @session = { user: student }
        @request.session[:user] = student
      end
      it 'allows edit action' do
        controller.params = { id: '1', action: 'edit' }
        expect(controller.action_allowed?).to eq('Student')
      end
      it 'allows update action' do
        controller.params = { id: '1', action: 'update' }
        expect(controller.action_allowed?).to eq('Student')
      end
      it 'allows destroy action' do
        controller.params = { id: '1', action: 'destroy' }
        expect(controller.action_allowed?).to eq('Student')
      end
    end
  end

  describe '#specific_average_score' do
    context 'check corner cases for specific_average_score' do
      let(:controller) { BookmarksController.new }

      it 'score is null' do
        nullBookmark = nil
        expect(controller.specific_average_score(nullBookmark)).to eq('-')
      end
    end
  end

  describe '#total_average_score' do
    context 'check corner cases for total_average_score' do
      let(:controller) { BookmarksController.new }

      it 'score is null' do
        nullBookmark = nil
        expect(controller.total_average_score(nullBookmark)).to eq('-')
      end
    end
  end
end
