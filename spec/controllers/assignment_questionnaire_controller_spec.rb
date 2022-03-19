describe AssignmentQuestionnaireController do
  let(:super_admin) { build(:superadmin, id: 1, role_id: 5) }
  let(:instructor1) { build(:instructor, id: 10, role_id: 3, parent_id: 3, name: 'Instructor1') }
  let(:student1) { build(:student, id: 21, role_id: 1) }
  let(:assignment) { build(:assignment, id: 1) }
  let(:questionnaire) { build(:questionnaire, id:1) }
  describe '#action_allowed?' do
    context 'when no assignment is associated with the id' do
      it 'refuses certain action' do
        allow(Assignment).to receive(:find).and_return(nil)
        expect(controller.send(:action_allowed?)).to be_falsey
      end
    end
    context 'instructor is the parent of the assignment found' do
      it 'allows a certain action' do
        stub_current_user(instructor1, instructor1.role.name, instructor1.role)
        allow(Assignment).to receive(:find).and_return(assignment)
        allow_any_instance_of(Assignment).to receive(:instructor).and_return(instructor1)
        expect(controller.send(:action_allowed?)).to be_falsey
      end
    end
  end

  describe '#create' do
  context 'assignment id is not entered' do
    it 'flashes a response of missing assignment id' do
      allow(Assignment).to recieve(new()).and_return(params[:assigment_id])
      assert_nil(params[:assignment_id])
    end
  end
  context 'questionnaire id is not entered' do
    it 'flashes a response of missing questionnaire id' do
      allow(Questionnaire).to recieve(new()).and_return(params[:questionnaire_id])
      assert_nil(params[:questionnaire_id])
    end
  end
  context 'when no assignment is associated with the id' do
    it 'flashes no assignment id in the db' do
      allow(Assignment).to receive(:find).and_return(nil)
      expect(flash[:error]).to match(/Assignment # [0-9] does not currently exist./) ## check this regex
    end
  end
  context 'when no questionnaire is associated with id' do
    it 'flashes no questionaire id in the db' do
      allow(Questionnaire).to receive(:find).and_return(nil)
      expect(flash[:error]).to match(/Questionnaire # [0-9] does not currently exist./) ## check this regex
    end
  end
end

