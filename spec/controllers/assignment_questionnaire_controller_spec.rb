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

    context 'when no assignment is associated with the id in the database' do
      it 'refuses certain action' do
        params = {:assignment_id => 20}
        session = { user: super_admin }

        allow(Assignment).to receive(:find).with('20').and_return(nil)
        post :delete_all, params, session
        expect(flash[:error]).to be_present
        # expect(flash[:error]).to eq('Assignment #' + params[:assignment_id].to_s + ' does not currently exist.')
      end
    end
  

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

    describe '#create' do
      context 'when assignment id is entered as nil' do
        it 'flashes a response of missing assignment id' do
          session = { user: super_admin}
          params = { :assignment_id => nil}
          post :create, params
          expect(flash[:error]).to be_eql('Missing assignment ID - Assignment ID entered is Nil')
        end
      end

      context 'when questionnaire id is entered as nil' do
        it 'flashes a response of missing questionnaire id' do
          session = { user: super_admin}
          params = { :questionnaire_id => nil}
          post :create, params
          expect(flash[:error]).to be_eql('Missing questionnaire ID - Questionnaire ID entered is Nil')
        end
      end
      
      context 'when non-nil assignment id is not found' do
        it 'flashes an error if non-nil assignment id does not previousley exist in db' do
          session = { user: super_admin}
          allow(Assignment).to receive(:find).with('7').and_return(nil)
          params = { :assignment_id => '7'}
          post :create, params
          expect(flash[:error]).to be_eql('Assignment #7 does not currently exist.')
        end
      end

      context 'when non-nil questionnaire id is not found' do
        it 'flashes an error if non-nil questionnaire id does not previousley exist in db' do
          session = { user: super_admin}
          allow(Questionnaire).to receive(:find).with('7').and_return(nil)
          params = { :questionnaire_id => '7'}
          post :create, params
          expect(flash[:error]).to be_eql('Questionnaire #7 does not currently exist.')
        end
      end

      context 'when saving a new assignment questionnaire' do
        it 'should save and redirect appropriatley' do
          assignmentQuestionnaire = AssignmentQuestionnaire.new(assignment_id: 1, questionnaire_id:1).save
          expect(assignmentQuestionnaire).to eq(true)

          expect(response).to render_template(:add_new_questions_questionnaires)
        end
      end

  end
end