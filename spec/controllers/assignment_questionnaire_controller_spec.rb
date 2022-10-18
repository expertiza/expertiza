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
      #If the instructor is not an instructor of the assignment found then the instructor mustn't be allowed to perform action
      it 'does not allow instructor to perform action wrt the assignment' do
        stub_current_user(instructor1, instructor1.role.name, instructor1.role)
        allow(Assignment).to receive(:find).and_return(assignment)
        allow_any_instance_of(Assignment).to receive(:instructor).and_return(instructor1)
        expect(controller.send(:action_allowed?)).to be_falsey
      end
    end
    context 'instructor is the instructor for the assignment found' do
      ## If no questionnaire is associated with the id in database, then appropriate missing record error should be flashed
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
      ##If there is no assignment associated with the id in the database then controller must throw an error
      it 'throws an error that the assignment does not exist' do
        stub_current_user(super_admin, super_admin.role.name, super_admin.role)

        allow(Assignment).to receive(:find).with(20).and_return(nil)
        allow(controller).to receive(:params).and_return({ assignment_id: 20})
        controller.send(:delete_all)
        expect(flash[:error]).to be_eql('Assignment #20 does not currently exist.')
      end
    end
  

    # context 'when questionnaires related to an assignment are deleted' do
    #   #When all the questionnaires related to an assignment are deleted the count of assignment_questionnaire records should be 0 for that asssignment
    #   it 'should persist that delete in the database' do
    #     assignment3 = create(:assignment)

    #     questionnaire1 = create(:questionnaire)
    #     questionnaire2 = create(:questionnaire)
    #     questionnaire3 = create(:questionnaire)

    #     assignment_questionnaire1 = create(:assignment_questionnaire, assignment_id: assignment3.id, questionnaire_id: questionnaire1.id)
    #     assignment_questionnaire2 = create(:assignment_questionnaire, assignment_id: assignment3.id, questionnaire_id: questionnaire2.id)
    #     assignment_questionnaire3 = create(:assignment_questionnaire, assignment_id: assignment3.id, questionnaire_id: questionnaire3.id)

    #     allow(Assignment).to receive(:find).and_return(assignment3)
    #     allow(controller).to receive(:params).and_return({assignment_id: assignment3.id})
    #     controller.send(:delete_all)

    #     expect(AssignmentQuestionnaire.where(assignment_id: assignment3.id).count).to eq(0)

    #   end
    # end
  end

    describe '#create' do

      context 'when assignment id is entered as nil' do
        ## If assignment id is nil, then appropriate missing assignment id error should be flashed. 
        it 'flashes a response of missing assignment id' do
          request_params = { assignment_id: nil}
          stub_current_user(super_admin, super_admin.role.name, super_admin.role)
          allow(Assignment).to receive(:find).and_return(nil)      
          post :create, params: request_params
          expect(flash[:error]).to be_eql('Missing questionnaire')
        end
      end

      context 'when questionnaire id is entered as nil' do
        ## If questionnaire id is nil, then appropriate missing questionnaire id error should be flashed. 
        it 'flashes a response of missing questionnaire id' do
          request_params = {  assignment_id: 1, questionnaire_id: nil }
          stub_current_user(super_admin, super_admin.role.name, super_admin.role)
          allow(Assignment).to receive(:find).and_return(assignment)
          allow(Questionnaire).to receive(:find).and_return(nil)
          post :create, params: request_params
          expect(flash[:error]).to be_eql('Questionnaire # does not currently exist.')
        end
      end
      
      context 'when no assignment is associated with the id in the database' do
        ## If no assignment is associated with the id in database, then appropriate missing record error should be flashed
        it 'throws an error that the assignment does not exist in the db' do
          questionnaire1 = create(:questionnaire)
          request_params = {  assignment_id: 7, questionnaire_id: questionnaire1.id}
          stub_current_user(super_admin, super_admin.role.name, super_admin.role)
          allow(Assignment).to receive(:find).with('7').and_return(nil)
          allow(Questionnaire).to receive(:find).and_return(questionnaire1)
          post :create, params: request_params
          expect(flash[:error]).to be_eql('Assignment #7 does not currently exist.')
        end
      end

      context 'when no questionnaire is associated with the id in the database' do
         ## If no questionnaire is associated with the id in database, then appropriate missing record error should be flashed
        it 'throws an error that the questionnaire does not exist in the db' do
          request_params = { assignment_id: assignment.id, questionnaire_id: 7}
          stub_current_user(super_admin, super_admin.role.name, super_admin.role)
          allow(Assignment).to receive(:find).and_return(assignment)
          allow(Questionnaire).to receive(:find).with("7").and_return(nil)
          post :create, params: request_params
          expect(flash[:error]).to be_eql('Questionnaire #7 does not currently exist.')
        end
      end

      # context 'when saving a new assignment questionnaire' do
      #   ## Checking if the assignment question is saved correctly to the database. 
      #   it 'should save and redirect appropriatley' do
      #     assignment5 = create(:assignment)
      #     questionnaire1 = create(:questionnaire)
      #     params = { assignment_id: assignment5.id, questionnaire_id: questionnaire1.id }

      #     stub_current_user(super_admin, super_admin.role.name, super_admin.role)
      #     allow(Assignment).to receive(:find).and_return(assignment5)
      #     allow(Questionnaire).to receive(:find).and_return(questionnaire1)
      #     allow(controller).to receive(:params).and_return(params)
      #     controller.send(:create)

      #     expect(AssignmentQuestionnaire.where(assignment_id: assignment5.id).count).to eq(1)
      #   end
      # end

  end

end