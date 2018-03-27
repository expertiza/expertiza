describe QuestionnairesController do
  let(:questionnaire) { build(:questionnaire) }
  let(:quiz_questionnaire) { build(:questionnaire, type: 'QuizQuestionnaire') }
  let(:review_questionnaire) { build(:questionnaire, type: 'ReviewQuestionnaire') }
  let(:question) { build(:question, id: 1) }
  let(:instructor) { build(:instructor, id: 6) }
  before(:each) do
    stub_current_user(instructor, instructor.role.name, instructor.role)
  end

  describe '#copy,  #copy_questionnaire_details and #assign_instructor_id' do
    it 'redirects to view page of copied questionnaire' do
      allow(Questionnaire).to receive(:find).with('1').and_return(questionnaire)
      allow(Question).to receive(:where).with(questionnaire_id: '1').and_return([question])
      allow(instructor).to receive(:instructor_id).and_return(6)
      question_advice = build(:question_advice)
      allow(QuestionAdvice).to receive(:where).with(question_id: 1).and_return([question_advice])
      tree_folder = double('TreeFolder', id: 1)
      allow(TreeFolder).to receive(:find_by).with(name: 'Review').and_return(tree_folder)
      allow(FolderNode).to receive(:find_by).with(node_object_id: 1).and_return(double('FolderNode', id: 1))
      allow(QuestionnaireNode).to receive(:find_or_create_by).with(parent_id: 1, node_object_id: 2).and_return(double('QuestionnaireNode'))
      allow_any_instance_of(QuestionnairesController).to receive(:undo_link).with(any_args).and_return('')
      params = {id: 1}
      session = {user: instructor}
      get :copy, params, session
      expect(response).to redirect_to('/questionnaires/view?id=2')
      expect(controller.instance_variable_get(:@questionnaire).name).to eq 'Copy of Test questionnaire'
      expect(controller.instance_variable_get(:@questionnaire).private).to eq false
      expect(controller.instance_variable_get(:@questionnaire).min_question_score).to eq 0
      expect(controller.instance_variable_get(:@questionnaire).max_question_score).to eq 5
      expect(controller.instance_variable_get(:@questionnaire).type).to eq 'ReviewQuestionnaire'
      expect(controller.instance_variable_get(:@questionnaire).display_type).to eq 'Review'
      expect(controller.instance_variable_get(:@questionnaire).instructor_id).to eq 6
    end
  end

  describe '#view' do
    it 'renders questionnaires#view page' do
      allow(Questionnaire).to receive(:find).with('1').and_return(questionnaire)
      params = {id: 1}
      get :view, params
      expect(response).to render_template(:view)
    end
  end

  describe '#new' do
    context 'when params[:model] has whitespace in it' do
      it 'creates new questionnaire object and renders questionnaires#new page' do
        params = {model: 'Assignment SurveyQuestionnaire'}
        get :new, params
        expect(response).to render_template(:new)
      end
    end

    context 'when params[:model] does not have whitespace in it' do
      it 'creates new questionnaire object and renders questionnaires#new page' do
        params = {model: 'ReviewQuestionnaire'}
        get :new, params
        expect(response).to render_template(:new)
      end
    end
  end

  describe '#create' do
    it 'redirects to questionnaires#edit page after create a new questionnaire' do
      params = {
        questionnaire: {
          name: 'test questionnaire',
          private: false,
          min_question_score: 0,
          max_question_score: 5,
          type: 'ReviewQuestionnaire'
        }
      }
      session = {user: double('Instructor', id: 6)}
      tree_folder = double('TreeFolder', id: 1)
      allow(TreeFolder).to receive_message_chain(:where, :first).with(['name like ?', 'Review']).with(no_args).and_return(tree_folder)
      allow(FolderNode).to receive(:find_by).with(node_object_id: 1).and_return(double('FolderNode', id: 1))
      allow(QuestionnaireNode).to receive(:create).with(parent_id: 1, node_object_id: 1, type: 'QuestionnaireNode').and_return(double('QuestionnaireNode'))
      post :create, params, session
      expect(flash[:success]).to eq('You have successfully created a questionnaire!')
      expect(response).to redirect_to('/questionnaires/1/edit')
      expect(controller.instance_variable_get(:@questionnaire).private).to eq false
      expect(controller.instance_variable_get(:@questionnaire).name).to eq 'test questionnaire'
      expect(controller.instance_variable_get(:@questionnaire).min_question_score).to eq 0
      expect(controller.instance_variable_get(:@questionnaire).max_question_score).to eq 5
      expect(controller.instance_variable_get(:@questionnaire).type).to eq 'ReviewQuestionnaire'
      expect(controller.instance_variable_get(:@questionnaire).display_type).to eq 'Review'
      expect(controller.instance_variable_get(:@questionnaire).instructor_id).to eq 6
    end
  end

  describe '#create_quiz_questionnaire, #create_questionnaire and #save' do
    context 'when quiz is valid' do
      before(:each) do
        # create_quiz_questionnaire
        allow_any_instance_of(QuestionnairesController).to receive(:valid_quiz).and_return('valid')
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

  describe '#edit' do
    context 'when @questionnaire is not nil' do
      it 'renders the questionnaires#edit page' do
        allow(Questionnaire).to receive(:find).with('1').and_return(double('Questionnaire', instructor_id: 6))
        session = {user: instructor}
        params = {id: 1}
        get :edit, params
        expect(response).to render_template(:edit)
      end
    end

    context 'when @questionnaire is nil' do
      it 'redirects to root page' do
        allow(Questionnaire).to receive(:find).with('666').and_return(nil)
        session = {user: instructor}
        params = {id: 666}
        get :edit, params
        expect(response).to redirect_to('/')
      end
    end
  end

  describe '#update' do
    before(:each) do
      @questionnaire1 = double('Questionnaire', id: 1)
      allow(Questionnaire).to receive(:find).with('1').and_return(@questionnaire1)
      @params = {
        id: 1,
        questionnaire: {
          name: 'test questionnaire',
          instructor_id: 6,
          private: 0,
          min_question_score: 0,
          max_question_score: 5,
          type: 'ReviewQuestionnaire',
          display_type: 'Review',
          instructor_loc: ''
        }
      }
    end
    context 'successfully updates the attributes of questionnaire' do
      it 'redirects to questionnaires#edit page after updating' do
        allow(@questionnaire1).to receive(:update_attributes).with(any_args).and_return(true)
        # need complete params hash to handle strong parameters
        post :update, @params
        expect(flash[:success]).to eq 'The questionnaire has been successfully updated!'
        expect(response).to redirect_to('/questionnaires/1/edit')
      end
    end

    context 'have some errors when updating the attributes of questionnaire' do
      it 'redirects to questionnaires#edit page after updating' do
        allow(@questionnaire1).to receive(:update_attributes).with(any_args).and_raise('This is an error!')
        post :update, @params
        expect(flash[:error].to_s).to eq 'This is an error!'
        expect(response).to redirect_to('/questionnaires/1/edit')
      end
    end
  end

  describe '#delete' do
    context 'when @questionnaire.assignments returns non-empty array' do
      it 'sends the error message to flash[:error]' do
        questionnaire1 = double('Questionnaire', name: 'test questionnaire',
                                                 assignments: [double('Assignment', name: 'test assignment')])
        allow(Questionnaire).to receive(:find).with('1').and_return(questionnaire1)
        params = {id: 1}
        get :delete, params
        expect(flash[:error]).to eq('The assignment <b>test assignment</b> uses this questionnaire. Are sure you want to delete the assignment?')
        expect(response).to redirect_to('/tree_display/list')
      end
    end

    context 'when question.answers returns non-empty array' do
      it 'sends the error message to flash[:error]' do
        questionnaire1 = double('Questionnaire', name: 'test questionnaire', assignments: [],
                                                 questions: [double('Question', answers: [double('Answer')])])
        allow(Questionnaire).to receive(:find).with('1').and_return(questionnaire1)
        params = {id: 1}
        get :delete, params
        expect(flash[:error]).to eq('There are responses based on this rubric, we suggest you do not delete it.')
        expect(response).to redirect_to('/tree_display/list')
      end
    end

    context 'when @questionnaire.assignments and question.answers return empty arrays' do
      it 'deletes all objects related to current questionnaire' do
        advices = [double('QuestionAdvice')]
        question = double('Question', answers: [], question_advices: advices)
        questionnaire_node = double('QuestionnaireNode')
        questionnaire1 = double('Questionnaire', name: 'test questionnaire', assignments: [],
                                                 questions: [question], questionnaire_node: questionnaire_node)
        allow(Questionnaire).to receive(:find).with('1').and_return(questionnaire1)
        allow(advices).to receive(:each).with(any_args).and_return(true)
        allow(question).to receive(:delete).and_return(true)
        allow(questionnaire_node).to receive(:delete).and_return(true)
        allow(questionnaire1).to receive(:delete).and_return(true)
        allow_any_instance_of(QuestionnairesController).to receive(:undo_link).with(any_args).and_return(true)
        params = {id: 1}
        get :delete, params
        expect(flash[:error]).to eq nil
        expect(response).to redirect_to('/tree_display/list')
      end
    end
  end

  describe '#toggle_access' do
    it 'redirects to tree_display#list page' do
      allow(Questionnaire).to receive(:find).with('1').and_return(questionnaire)
      allow_any_instance_of(QuestionnairesController).to receive(:undo_link).with(any_args).and_return(true)
      params = {id: 1}
      get :toggle_access, params
      expect(response).to redirect_to('/tree_display/list')
      expect(controller.instance_variable_get(:@questionnaire).private).to eq true
      expect(controller.instance_variable_get(:@access)).to eq('private')
    end
  end

  describe '#add_new_questions' do
    context 'when adding ScoredQuestion' do
      it 'redirects to questionnaires#edit page after adding new questions' do
        question = double('Criterion', weight: 1, max_label: '', min_label: '', size: '', alternatives: '')
        allow(Questionnaire).to receive(:find).with('1').and_return(double('Questionnaire', id: 1, questions: [question]))
        allow(question).to receive(:save).and_return(true)
        params = {
          id: 1,
          question: {
            total_num: 2,
            type: 'Criterion'
          }
        }
        post :add_new_questions, params
        expect(response).to redirect_to('/questionnaires/1/edit')
      end
    end

    context 'when adding unScoredQuestion' do
      it 'redirects to questionnaires#edit page after adding new questions' do
        question = double('Dropdown', size: '', alternatives: '')
        allow(Questionnaire).to receive(:find).with('1').and_return(double('Questionnaire', id: 1, questions: [question]))
        allow(question).to receive(:save).and_return(true)
        params = {
          id: 1,
          question: {
            total_num: 2,
            type: 'Dropdown'
          }
        }
        post :add_new_questions, params
        expect(response).to redirect_to('/questionnaires/1/edit')
      end
    end
  end

  describe '#save_all_questions' do
    context 'when params[:save] is not nil, params[:view_advice] is nil' do
      it 'redirects to questionnaires#edit page after saving all questions' do
        allow(Question).to receive(:find).with('1').and_return(question)
        allow(question).to receive(:save).and_return(true)
        params = {
          id: 1,
          save: true,
          question: {
            '1' => {
              seq: 66.0,
              txt: 'WOW',
              weight: 10,
              size: '50,3',
              max_label: 'Strong agree',
              min_label: 'Not agree'
            }
          }
        }
        post :save_all_questions, params
        expect(flash[:success]).to eq('All questions has been successfully saved!')
        expect(response).to redirect_to('/questionnaires/1/edit')
      end
    end

    context 'when params[:save] is nil, params[:view_advice] is not nil' do
      it 'redirects to advice#edit_advice page' do
        params = {
          id: 1,
          view_advice: true,
          question: {}
        }
        post :save_all_questions, params
        expect(response).to redirect_to('/advice/edit_advice/1')
      end
    end
  end

  describe '#view_quiz' do
    it 'renders questionnaires#view_quiz' do
      allow(Questionnaire).to receive(:find).with('1').and_return(double('Questionnaire'))
      allow(Participant).to receive(:find).with('1').and_return(double('Participant'))
      params = {id: 1, pid: 1}
      get :view_quiz, params
      expect(response).to render_template(:view)
    end
  end

  describe '#new_quiz' do
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

      it 'renders questionnaires#new_quiz if current participant has a team' do
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

  describe '#edit_quiz' do
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

  describe '#update_quiz' do
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

  describe '#valid_quiz' do
    before(:each) do
      allow(Assignment).to receive_message_chain(:find, :num_quiz_questions).with('1').with(no_args).and_return(1)
    end

    context 'when user does not specify quiz name' do
      it 'returns message (Please specify quiz name (please do not use your name or id).)' do
        controller.params = {
          aid: 1,
          questionnaire: {name: ''}
        }
        expect(controller.valid_quiz).to eq('Please specify quiz name (please do not use your name or id).')
      end
    end

    context 'when user does not specify a type for each question' do
      it 'returns message (Please select a type for each question)' do
        controller.params = {
          aid: 1,
          questionnaire: {name: 'test questionnaire'}
        }
        expect(controller.valid_quiz).to eq('Please select a type for each question')
      end
    end

    context 'when user does not specify choice info for one question' do
      it 'returns mesage (Please select a correct answer for all questions)' do
        controller.params = {
          aid: 1,
          questionnaire: {name: 'test questionnaire'},
          question_type: {'1' => {type: 'TrueFalse'}},
          new_question: {'1' => {iscorrect: 'True'}},
          new_choices: {'1' => {}}
        }
        expect(controller.valid_quiz).to eq('Please select a correct answer for all questions')
      end
    end

    context 'when user specifies all necessary information' do
      it 'returns mesage (valid)' do
        controller.params = {
          aid: 1,
          questionnaire: {name: 'test questionnaire'},
          question_type: {'1' => {type: 'TrueFalse'}},
          new_question: {'1' => {iscorrect: 'True'}},
          new_choices: {'1' => {'TrueFalse' => 'sth'}}
        }
        question = build(:question, type: 'TrueFalse')
        allow(TrueFalse).to receive(:create).with(txt: '', type: 'TrueFalse', break_before: true).and_return(question)
        allow(question).to receive(:isvalid).with('sth').and_return('valid')
        expect(controller.valid_quiz).to eq('valid')
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
