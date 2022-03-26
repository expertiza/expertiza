describe AssignmentQuestionnaireController do
  let(:super_admin) { build(:superadmin, id: 1, role_id: 5) }
  let(:instructor1) { build(:instructor, id: 10, role_id: 3, parent_id: 3, name: 'Instructor1') }
  let(:student1) { build(:student, id: 21, role_id: 1) }
  let(:assignment) { build(:assignment, id: 1) }
  
  #Extra stubs/mocks being created here. 
  let(:assignment1) do
    build(:assignment, id: 3, name: 'test3 assignment', instructor_id: 10, staggered_deadline: true, directory_path: 'new_test_assignment',
                       participants: [build(:participant)], teams: [build(:assignment_team)], course_id: 1)
  end
  describe '#action_allowed?' do
    context 'when no assignment is associated with the id' do
      #If there is no assignment ID passed, the action should not be allowed. 
      it 'refuses further actions' do
        allow(Assignment).to receive(:find).and_return(nil)
        expect(controller.send(:action_allowed?)).to be_falsey
      end
    end
    context 'instructor is not the instructor of the assignment found' do
      #If user is an instructor, who is parent of the assignment found, then the user mustn't be allowed to perform action
      it 'does not allow instructor to perform action wrt the assignment' do
        stub_current_user(instructor1, instructor1.role.name, instructor1.role)
        allow(Assignment).to receive(:find).and_return(assignment)
        allow_any_instance_of(Assignment).to receive(:instructor).and_return(instructor1)
        expect(controller.send(:action_allowed?)).to be_falsey
      end
    end
    context 'instructor is the instructor for the assignment found' do
      it 'allows instructor to perform action wrt the assignment' do
        stub_current_user(instructor1, instructor1.role.name, instructor1.role)
        allow(Assignment).to receive(:find).and_return(assignment1)
        allow_any_instance_of(Assignment).to receive(:instructor).and_return(instructor1)
        expect(controller.send(:action_allowed?)).to be_truthy
      end
    end
    context 'user is the ancestor of the assignment found' do
      ##If the user is the ancestor of the instructor who created the course then this user allowed to perform the action. 
      it 'allows user to perform action wrt the assignment' do
        stub_current_user(super_admin, super_admin.role.name, super_admin.role)
        allow(Assignment).to receive(:find).and_return(assignment1)
        allow_any_instance_of(Assignment).to receive(:instructor).and_return(instructor1)
        expect(controller.send(:action_allowed?)).to be_truthy
      end
    end
    context 'TA who is not course TA is not allowed to perform actions on the assignment found' do
      ##If the user is assignment's course's TA, then the user is allowed to perform action wrt assignment.
      it 'does not allow TA to perform action wrt the assignment' do
        course2 = create(:course)
        assignment2 = create(:assignment, course_id: course2.id, instructor_id: instructor1)
        ta1 = create(:teaching_assistant, id: 20)
        ta2 = create(:teaching_assistant, id:40, name: 'test_ta_2')
        TaMapping.create(ta_id: ta1.id, course_id: course2.id)
        
        stub_current_user(ta2, ta2.role.name, ta2.role)
        allow(Assignment).to receive(:find).and_return(assignment2)
        expect(controller.send(:action_allowed?)).to be false
      end
    end

  end

  describe '#delete_all' do

    context 'when no assignment is associated with the id in the database' do

      it 'throws an error that the assignment does not exist' do
        stub_current_user(super_admin, super_admin.role.name, super_admin.role)
        params = {:assignment_id => 20}

        allow(Assignment).to receive(:find).with('20').and_return(nil)
        post :delete_all, params
        expect(flash[:error]).to eq 'Assignment #' + params[:assignment_id].to_s + ' does not currently exist.'
      end
    end

    context 'when questionnaires related to an assignment are deleted' do
      it 'should persist that delete in the database' do
        assignment3 = create(:assignment)

        questionnaire1 = create(:questionnaire)
        questionnaire2 = create(:questionnaire)
        questionnaire3 = create(:questionnaire)

        assignment_questionnaire1 = create(:assignment_questionnaire, assignment_id: assignment3.id, questionnaire_id: questionnaire1.id)
        assignment_questionnaire2 = create(:assignment_questionnaire, assignment_id: assignment3.id, questionnaire_id: questionnaire2.id)
        assignment_questionnaire3 = create(:assignment_questionnaire, assignment_id: assignment3.id, questionnaire_id: questionnaire3.id)

        allow(Assignment).to receive(:find).and_return(assignment3)
        allow(controller).to receive(:params).and_return({assignment_id: assignment3.id})
        controller.send(:delete_all)

        expect(AssignmentQuestionnaire.where(assignment_id: assignment3.id).count).to eq(0)

      end
    end
  end


  

  #expect(response).to render_template('new')
end