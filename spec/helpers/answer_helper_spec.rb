describe AnswerHelper do
    before(:each) do
        @assignment1 = double('Assignment', id: 1)
        allow(Assignment).to receive(:find).with('1').and_return(@assignment1)
        @questionnaire3 = double('Questionnaire', id: 1)
        allow(Questionnaire).to receive(:find).with('3').and_return(@questionnaire3)
        @questionnaire4 = double('Questionnaire', id: 2)
        allow(Questionnaire).to receive(:find).with('4').and_return(@questionnaire4)
        @duedate1 = double('Duedate', id: 1, due_at: '2019-11-30 23:30:12', deadline_type_id: 1, parent_id: 1, round: 1)
        allow(DueDate).to receive(:find).with('1').and_return(@duedate1)
        @duedate2 = double('Duedate', id: 2, due_at: '2019-12-30 23:30:12', deadline_type_id: 2, parent_id: 1, round: 1)
        allow(DueDate).to receive(:find).with('2').and_return(@duedate2)
        @duedate3 = double('Duedate', id: 3, due_at: '2019-01-30 23:30:12', deadline_type_id: 1, parent_id: 1, round: 2)
        allow(DueDate).to receive(:find).with('3').and_return(@duedate3)
        @duedate4 = double('Duedate', id: 4, due_at: '2019-02-30 23:30:12', deadline_type_id: 2, parent_id: 1, round: 2)
        allow(DueDate).to receive(:find).with('4').and_return(@duedate4)
        @assignment_questionnaire1 = double('AssignmentQuestionnaire', id: 1, assignment_id: 1, questionnaire_id: 1, used_in_round: 1)
        allow(AssignmentQuestionnaire).to receive(:find).with('1').and_return(@assignment_questionnaire1)
        @assignment_questionnaire2 = double('AssignmentQuestionnaire', id: 2, assignment_id: 1, questionnaire_id: 2, used_in_round: 2)
        allow(AssignmentQuestionnaire).to receive(:find).with('2').and_return(@assignment_questionnaire2)               
    end

    describe '#delete_existing_responses' do
      it 'renders questionnaires#view page' do
        allow(Questionnaire).to receive(:find).with('1').and_return(questionnaire)
        params = {id: 1}
        get :view, params
        expect(response).to render_template(:view)
      end
    end

    describe '#review_mailer' do
      it 'renders questionnaires#view page' do
        allow(Questionnaire).to receive(:find).with('1').and_return(questionnaire)
        params = {id: 1}
        get :view, params
        expect(response).to render_template(:view)
      end
    end

    describe '#delete_answers' do
      it 'renders questionnaires#view page' do
        allow(Questionnaire).to receive(:find).with('1').and_return(questionnaire)
        params = {id: 1}
        get :view, params
        expect(response).to render_template(:view)
      end
    end

    describe '#in_active_period' do
      it 'renders questionnaires#view page' do
        allow(Questionnaire).to receive(:find).with('1').and_return(questionnaire)
        params = {id: 1}
        get :view, params
        expect(response).to render_template(:view)
      end
    end