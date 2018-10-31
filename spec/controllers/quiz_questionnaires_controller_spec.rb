describe QuizQuestionnairesController do
  let(:quiz_questionnaire) { build(:questionnaire, type: 'QuizQuestionnaire') }
  let(:question) { build(:question, id: 1) }
  let(:instructor) { build(:instructor, id: 6) }
  before(:each) do
    stub_current_user(instructor, instructor.role.name, instructor.role)
  end

  describe '#create and #save' do
    context 'when quiz is valid' do
      before(:each) do
        # create_quiz_questionnaire
        allow_any_instance_of(QuestionnairesController).to receive(:valid).and_return('valid')
      end
      context 'when questionnaire type is QuizQuestionnaire' do
        it 'redirects to submitted_content#edit page' do
          params = {
            aid: 1,
            pid: 1,
            questionnaire: {
              name: 'Test questionnaire',
              type: 'QuizQuestionnaire'
            }
          }
          # create_questionnaire
          participant = double('Participant')
          allow(Participant).to receive(:find).with('1').and_return(participant)
          allow(AssignmentTeam).to receive(:team).with(participant).and_return(double('AssignmentTeam', id: 6))
          allow_any_instance_of(QuestionnairesController).to receive(:save_choices).with(1).and_return(true)
          # save
          allow_any_instance_of(QuestionnairesController).to receive(:save_questions).with(1).and_return(true)
          allow_any_instance_of(QuestionnairesController).to receive(:undo_link).with(any_args).and_return('')
          post :create_quiz_questionnaire, params
          expect(flash[:note]).to eq('The quiz was successfully created.')
          expect(response).to redirect_to('/submitted_content/1/edit')
          expect(controller.instance_variable_get(:@questionnaire).private).to eq false
          expect(controller.instance_variable_get(:@questionnaire).name).to eq 'Test questionnaire'
          expect(controller.instance_variable_get(:@questionnaire).min_question_score).to eq 0
          expect(controller.instance_variable_get(:@questionnaire).max_question_score).to eq 1
          expect(controller.instance_variable_get(:@questionnaire).type).to eq 'QuizQuestionnaire'
          expect(controller.instance_variable_get(:@questionnaire).instructor_id).to eq 6
        end
      end

      context 'when questionnaire type is not QuizQuestionnaire' do
        it 'redirects to submitted_content#edit page' do
          params = {
            aid: 1,
            pid: 1,
            questionnaire: {
              name: 'Test questionnaire',
              type: 'ReviewQuestionnaire'
            }
          }
          # create_questionnaire
          allow(ReviewQuestionnaire).to receive(:new).with(any_args).and_return(review_questionnaire)
          session = {user: build(:teaching_assistant, id: 1)}
          allow(Ta).to receive(:get_my_instructor).with(1).and_return(6)
          # save
          allow(TreeFolder).to receive(:find_by).with(name: 'Review').and_return(double('TreeFolder', id: 1))
          allow(FolderNode).to receive(:find_by).with(node_object_id: 1).and_return(double('FolderNode'))
          allow_any_instance_of(QuestionnairesController).to receive(:undo_link).with(any_args).and_return('')
          post :create_quiz_questionnaire, params, session
          expect(flash[:note]).to be nil
          expect(response).to redirect_to('/tree_display/list')
          expect(controller.instance_variable_get(:@questionnaire).private).to eq false
          expect(controller.instance_variable_get(:@questionnaire).name).to eq 'Test questionnaire'
          expect(controller.instance_variable_get(:@questionnaire).min_question_score).to eq 0
          expect(controller.instance_variable_get(:@questionnaire).max_question_score).to eq 5
          expect(controller.instance_variable_get(:@questionnaire).type).to eq 'ReviewQuestionnaire'
          expect(controller.instance_variable_get(:@questionnaire).instructor_id).to eq 6
        end
      end
    end

    context 'when quiz is invalid and questionnaire type is QuizQuestionnaire' do
      it 'redirects to submitted_content#edit page' do
        params = {
          aid: 1,
          pid: 1,
          questionnaire: {
            name: 'test questionnaire',
            type: 'QuizQuestionnaire'
          }
        }
        # create_quiz_questionnaire
        allow_any_instance_of(QuestionnairesController).to receive(:valid_quiz).and_return('Please select a correct answer for all questions')
        request.env['HTTP_REFERER'] = 'www.google.com'
        post :create_quiz_questionnaire, params
        expect(flash[:error]).to eq('Please select a correct answer for all questions')
        expect(response).to redirect_to('www.google.com')
      end
    end
  end

  describe '#view' do
    it 'renders questionnaires#view' do
      allow(Questionnaire).to receive(:find).with('1').and_return(double('Questionnaire'))
      allow(Participant).to receive(:find).with('1').and_return(double('Participant'))
      params = {id: 1, pid: 1}
      get :view_quiz, params
      expect(response).to render_template(:view)
    end
  end

  describe '#new' do
    context 'when an assignment requires quiz' do
      before(:each) do
        @params = {
          aid: 1,
          model: 'QuizQuestionnaire',
          pid: 1,
          private: 0
        }
        @assignment = double('Assignment')
        allow(Assignment).to receive(:find).with('1').and_return(@assignment)
        allow(@assignment).to receive(:require_quiz?).and_return(true)
      end

      it 'renders quiz_questionnaires#new if current participant has a team' do
        team = double('AssignmentTeam')
        allow(AssignmentParticipant).to receive_message_chain(:find, :team).with('1').with(no_args).and_return(team)
        allow(@assignment).to receive(:topics?).and_return(true)
        allow(team).to receive(:topic).and_return(double(:SignUpTopic))
        get :new_quiz, @params
        expect(response).to render_template(:new_quiz)
      end

      it 'shows error message and redirects to submitted_content#view if current participant does not have a team' do
        allow(AssignmentParticipant).to receive_message_chain(:find, :team).with('1').with(no_args).and_return(nil)
        get :new_quiz, @params
        expect(flash[:error]).to eq('You should create or join a team first.')
        expect(response).to redirect_to('/submitted_content/view?id=1')
      end

      it 'shows error message and redirects to submitted_content#view if current participant have a team w/o topic' do
        team = double('AssignmentTeam')
        allow(AssignmentParticipant).to receive_message_chain(:find, :team).with('1').with(no_args).and_return(team)
        allow(@assignment).to receive(:topics?).and_return(true)
        allow(team).to receive(:topic).and_return(nil)
        get :new_quiz, @params
        expect(flash[:error]).to eq('Your team should have a topic.')
        expect(response).to redirect_to('/submitted_content/view?id=1')
      end
    end

    context 'when an assignment does not require quiz' do
      it 'shows error message and redirects to submitted_content#view' do
        params = {
          aid: 1,
          model: 'QuizQuestionnaire',
          pid: 1,
          private: 0
        }
        assignment = double('Assignment')
        allow(Assignment).to receive(:find).with('1').and_return(assignment)
        allow(assignment).to receive(:require_quiz?).and_return(false)
        get :new_quiz, params
        expect(flash[:error]).to eq('This assignment does not support the quizzing feature.')
        expect(response).to redirect_to('/submitted_content/view?id=1')
      end
    end
  end

  describe '#edit' do
    before(:each) do
      @questionnaire = double('Questionnaire')
      allow(Questionnaire).to receive(:find).with('1').and_return(@questionnaire)
    end

    context 'when current questionnaire is not taken by anyone' do
      it 'renders questionnaires#edit page' do
        allow(@questionnaire).to receive(:taken_by_anyone?).and_return(false)
        params = {id: 1}
        get :edit_quiz, params
        expect(response).to render_template(:edit)
      end
    end

    context 'when current questionnaire has been taken by someone' do
      it 'shows flash[:error] message and redirects to submitted_content#view page' do
        allow(@questionnaire).to receive(:taken_by_anyone?).and_return(true)
        params = {id: 1, pid: 1}
        get :edit_quiz, params
        expect(flash[:error]).to eq('Your quiz has been taken by some other students, you cannot edit it anymore.')
        expect(response).to redirect_to('/submitted_content/view?id=1')
      end
    end
  end

  describe '#update' do
    context 'when @questionnaire is nil' do
      it 'redirects to submitted_content#view page' do
        allow(Questionnaire).to receive(:find).with('1').and_return(nil)
        params = {id: 1, pid: 1}
        post :update_quiz, params
        expect(response).to redirect_to('/submitted_content/view?id=1')
      end
    end

    context 'when @questionnaire is not nil' do
      it 'updates all quiz questions and redirects to submitted_content#view page' do
        params = {
          id: 1,
          pid: 1,
          save: true,
          questionnaire: {
            name: 'test questionnaire',
            instructor_id: 6,
            private: 0,
            min_question_score: 0,
            max_question_score: 5,
            type: 'ReviewQuestionnaire',
            display_type: 'Review',
            instructor_loc: ''
          },
          question: {
            '1' => {txt: 'Q1'},
            '2' => {txt: 'Q2'},
            '3' => {txt: 'Q3'}
          },
          quiz_question_choices: {
            '1' => {MultipleChoiceRadio:
                    {:correctindex => 1, '1' => {txt: 'a11'}, '2' => {txt: 'a12'}, '3' => {txt: 'a13'}, '4' => {txt: 'a14'}}},
            '2' => {TrueFalse: {'1' => {iscorrect: 'True'}}},
            '3' => {MultipleChoiceCheckbox:
                    {'1' => {iscorrect: '1', txt: 'a31'}, '2' => {iscorrect: '0', txt: 'a32'},
                     '3' => {iscorrect: '1', txt: 'a33'}, '4' => {iscorrect: '0', txt: 'a34'}}}
          }
        }
        questionnaire = double('Questionnaire')
        allow(Questionnaire).to receive(:find).with('1').and_return(questionnaire)
        allow(questionnaire).to receive(:update_attributes).with(any_args).and_return(true)
        q1 = build(:question, id: 1, type: 'MultipleChoiceRadio')
        q2 = build(:question, id: 2, type: 'TrueFalse')
        q3 = build(:question, id: 3, type: 'MultipleChoiceCheckbox')
        allow(Question).to receive(:find).with('1').and_return(q1)
        allow(Question).to receive(:find).with('2').and_return(q2)
        allow(Question).to receive(:find).with('3').and_return(q3)
        qc = double('QuizQuestionChoice')
        # quiz question choice for true/false question
        qc_tf = double('QuizQuestionChoice', txt: 'True')
        allow(QuizQuestionChoice).to receive(:where).with(question_id: '1').and_return([qc, qc, qc, qc])
        allow(QuizQuestionChoice).to receive(:where).with(question_id: '2').and_return([qc_tf])
        allow(QuizQuestionChoice).to receive(:where).with(question_id: '3').and_return([qc, qc, qc, qc])
        allow(q1).to receive(:save).and_return(true)
        allow(q2).to receive(:save).and_return(true)
        allow(q3).to receive(:save).and_return(true)
        allow(qc).to receive(:update_attributes).with(any_args).and_return(true)
        allow(qc_tf).to receive(:update_attributes).with(any_args).and_return(true)
        post :update_quiz, params
        expect(response).to redirect_to('/submitted_content/view?id=1')
      end
    end
  end

  describe '#save_choices' do
    it 'is able to save different kinds of quiz questions' do
      controller.params = {
        new_question: {'1' => 'q1', '2' => 'q2', '3' => 'q3'},
        new_choices:
        {'1' =>
          {MultipleChoiceRadio: {'1' => {txt: 'a11', iscorrect: '3'}, '2' => {txt: 'a12'}, '3' => {txt: 'a13'}, '4' => {txt: 'a14'}}},
         '2' =>
          {TrueFalse: {'1' => {iscorrect: '1'}}},
         '3' =>
          {MultipleChoiceCheckbox:
            {'1' => {iscorrect: '1', txt: 'a31'},
             '2' => {iscorrect: '0', txt: 'a32'},
             '3' => {iscorrect: '1', txt: 'a33'},
             '4' => {iscorrect: '0', txt: 'a34'}}}},
        question_type: {'1' => {type: 'MultipleChoiceRadio'}, '2' => {type: 'TrueFalse'}, '3' => {type: 'MultipleChoiceCheckbox'}}
      }
      q1 = build(:question, id: 1, type: 'MultipleChoiceRadio')
      q2 = build(:question, id: 2, type: 'TrueFalse')
      q3 = build(:question, id: 3, type: 'MultipleChoiceCheckbox')
      allow(Question).to receive(:where).with(questionnaire_id: 1).and_return([q1, q2, q3])
      expect { controller.send(:save_choices, 1) }.to change { QuizQuestionChoice.count }.from(0).to(10)
    end
  end
end
