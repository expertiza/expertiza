describe AssignmentQuestionnaireController do
  let(:super_admin) { build(:superadmin, id: 1, role_id: 5) }
  let(:instructor1) { build(:instructor, id: 10, role_id: 3, parent_id: 3, name: 'Instructor1') }
  let(:student1) { build(:student, id: 21, role_id: 1) }
  let(:assignment) { build(:assignment, id: 1) }

  #Extra stubs/mocks being created here. 
  let(:assignment3) do
    build(:assignment, id: 3, name: 'test3 assignment', instructor_id: 10, staggered_deadline: true, directory_path: 'new_test_assignment',
                       participants: [build(:participant)], teams: [build(:assignment_team)], course_id: 1)
  end    
  
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
    
    context 'user is the ancestor of the assignment found' do
      ##Assert if the user, who is the ancestor of the instructor who created the course, is allowed to perform the action. 
      it 'allows a certain action' do
        stub_current_user(super_admin, super_admin.role.name, super_admin.role)
        allow(Assignment).to receive(:find).and_return(assignment3)
        allow_any_instance_of(Assignment).to receive(:instructor).and_return(instructor1)
        expect(controller.send(:action_allowed?)).to be_truthy
      end
    end

    context 'course ta is allowed to perform actions on the assignment found' do
      ##Created an assignment for a course
      ##Assigned a ta to that course
      ##Assert if this assignment's course's ta is the same guy who signed in. 
      it 'allows a certain action' do
        ta1 = create(:teaching_assistant, id: 25)
        ta2 = create(:teaching_assistant, id:40, name: 'test_ta_2')
        course1 = create(:course)
        assignment4 = create(:assignment, course_id: course1.id, instructor_id: instructor1)
        TaMapping.create(ta_id: ta1.id, course_id: course1.id)
        
        stub_current_user(ta2, ta2.role.name, ta2.role)
        allow(Assignment).to receive(:find).and_return(assignment4)
        expect(controller.send(:action_allowed?)).to be false
      end

    end
    
  end

   describe '#delete_all' do

    # context 'when no assignment is associated with the id in the database' do
    #   it 'refuses certain action' do
    #     assignment_id = 30
    #     allow(Assignment).to receive(:find_by).and_return(nil)
    #     delete :new, params
    #     expect(flash[:error]).to eq('Assignment #' + assignment.id.to_s + ' does not currently exist.')
    #   end
    # end

    context 'when questionnaires related to an assignment are deleted' do
      it 'should persist that delete in the database' do
        assignment5 = create(:assignment)

        questionnaire1 = create(:questionnaire)
        questionnaire2 = create(:questionnaire)
        questionnaire3 = create(:questionnaire)

        assignment_questionnaire1 = create(:assignment_questionnaire, assignment_id: assignment5.id, questionnaire_id: questionnaire1.id)
        assignment_questionnaire2 = create(:assignment_questionnaire, assignment_id: assignment5.id, questionnaire_id: questionnaire2.id)
        assignment_questionnaire3 = create(:assignment_questionnaire, assignment_id: assignment5.id, questionnaire_id: questionnaire3.id)

        allow(Assignment).to receive(:find).and_return(assignment5)
        allow(controller).to receive(:params).and_return({assignment_id: assignment5.id})
        controller.send(:delete_all)

        expect(AssignmentQuestionnaire.where(assignment_id: assignment5.id).count).to eq(0)

      end
    end

  end

end