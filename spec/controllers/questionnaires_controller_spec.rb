describe QuestionnairesController do
  let(:questionnaire) { build(:questionnaire) }
  let(:quiz_questionnaire) { build(:questionnaire, type: 'QuizQuestionnaire') }
  let(:review_questionnaire) { build(:questionnaire, type: 'ReviewQuestionnaire') }
  let(:question) { build(:question, id: 1) }
  before(:each) do
    instructor = build(:instructor)
    stub_current_user(instructor, instructor.role.name, instructor.role)
  end

  describe '#copy,  #copy_questionnaire_details and #assign_instructor_id' do
    it 'redirects to view page of copied questionnaire'
  end

  describe '#view' do
    it 'renders questionnaires#view page'
  end

  describe '#new' do
    context 'when params[:model] has whitespace in it' do
      it 'creates new questionnaire object and renders questionnaires#new page'
    end

    context 'when params[:model] does not have whitespace in it' do
      it 'creates new questionnaire object and renders questionnaires#new page'
    end
  end

  describe '#create' do
    it 'redirects to questionnaires#edit page after create a new questionnaire'
  end

  describe '#create_quiz_questionnaire, #create_questionnaire and #save' do
    context 'when quiz is valid' do
      context 'when questionnaire type is QuizQuestionnaire' do
        it 'redirects to submitted_content#edit page'
      end

      context 'when questionnaire type is not QuizQuestionnaire' do
        it 'redirects to submitted_content#edit page'
      end
    end

    context 'when quiz is invalid and questionnaire type is QuizQuestionnaire' do
      it 'redirects to submitted_content#edit page'
    end
  end

  describe '#edit' do
    context 'when @questionnaire is not nil' do
      it 'renders the questionnaires#edit page'
    end

    context 'when @questionnaire is nil' do
      it 'redirects to /questionnaires page'
    end
  end

  describe '#update' do
    context 'successfully updates the attributes of questionnaire' do
      it 'redirects to questionnaires#edit page after updating'
    end

    context 'have some errors when updating the attributes of questionnaire' do
      it 'redirects to questionnaires#edit page after updating'
    end
  end

  describe '#delete' do
    context 'when @questionnaire.assignments returns non-empty array' do
      it 'sends the error message to flash[:error]'
    end

    context 'when question.answers returns non-empty array' do
      it 'sends the error message to flash[:error]'
    end

    context 'when @questionnaire.assignments and question.answers return empty arrays' do
      it 'deletes all objects related to current questionnaire'
    end
  end

  describe '#toggle_access' do
    it 'redirects to tree_display#list page'
  end

  describe '#add_new_questions' do
    context 'when adding ScoredQuestion' do
      it 'redirects to questionnaires#edit page after adding new questions'
    end

    context 'when adding unScoredQuestion' do
      it 'redirects to questionnaires#edit page after adding new questions'
    end
  end

  describe '#save_all_questions' do
    context 'when params[:save] is not nil, params[:view_advice] is nil' do
      it 'redirects to questionnaires#edit page after saving all questions'
        # params = {
        #   id: 1,
        #   save: true,
        #   question: {
        #     '1' => {
        #       seq: 66.0,
        #       txt: 'WOW',
        #       weight: 10,
        #       size: '50,3',
        #       max_label: 'Strong agree',
        #       min_label: 'Not agree'
        #     }
        #   }
        # }
    end

    context 'when params[:save] is nil, params[:view_advice] is not nil' do
      it 'redirects to advice#edit_advice page'
    end
  end

  describe '#view_quiz' do
    it 'renders questionnaires#view_quiz'
  end

  describe '#new_quiz' do
    context 'when an assignment requires quiz' do
      it 'renders questionnaires#new_quiz if current participant has a team'

      it 'shows error message and redirects to submitted_content#view if current participant does not have a team'

      it 'shows error message and redirects to submitted_content#view if current participant have a team w/o topic'
    end

    context 'when an assignment does not require quiz' do
      it 'shows error message and redirects to submitted_content#view'
    end
  end

  describe '#edit_quiz' do
    context 'when current questionnaire is not taken by anyone' do
      it 'renders questionnaires#edit page'
    end

    context 'when current questionnaire has been taken by someone' do
      it 'shows flash[:error] message and redirects to submitted_content#view page'
    end
  end

  describe '#update_quiz' do
    context 'when @questionnaire is nil' do
      it 'redirects to submitted_content#view page'
    end

    context 'when @questionnaire is not nil' do
      it 'updates all quiz questions and redirects to submitted_content#view page'
        # params = {
        #   id: 1,
        #   pid: 1,
        #   save: true,
        #   questionnaire: {
        #     name: 'test questionnaire',
        #     instructor_id: 6,
        #     private: 0,
        #     min_question_score: 0,
        #     max_question_score: 5,
        #     type: 'ReviewQuestionnaire',
        #     display_type: 'Review',
        #     instructor_loc: ''
        #   },
        #   question: {
        #     '1' => {txt: 'Q1'},
        #     '2' => {txt: 'Q2'},
        #     '3' => {txt: 'Q3'}
        #   },
        #   quiz_question_choices: {
        #     '1' => {MultipleChoiceRadio:
        #             {:correctindex => 1, '1' => {txt: 'a11'}, '2' => {txt: 'a12'}, '3' => {txt: 'a13'}, '4' => {txt: 'a14'}}},
        #     '2' => {TrueFalse: {'1' => {iscorrect: 'True'}}},
        #     '3' => {MultipleChoiceCheckbox:
        #             {'1' => {iscorrect: '1', txt: 'a31'}, '2' => {iscorrect: '0', txt: 'a32'},
        #              '3' => {iscorrect: '1', txt: 'a33'}, '4' => {iscorrect: '0', txt: 'a34'}}}
        #   }
        # }
    end
  end

  describe '#valid_quiz' do
    context 'when user does not specify quiz name' do
      it 'returns message (Please specify quiz name (please do not use your name or id).)'
    end

    context 'when user does not specify a type for each question' do
      it 'returns message (Please select a type for each question)'
    end

    context 'when user does not specify choice info for one question' do
      it 'returns mesage (Please select a correct answer for all questions)'
    end

    context 'when user specifies all necessary information' do
      it 'returns mesage (valid)'
        # controller.params = {
        #   aid: 1,
        #   questionnaire: {name: 'test questionnaire'},
        #   question_type: {'1' => {type: 'TrueFalse'}},
        #   new_question: {'1' => {iscorrect: 'True'}},
        #   new_choices: {'1' => {'TrueFalse' => 'sth'}}
        # }
    end
  end

  describe '#save_choices' do
    it 'is able to save different kinds of quiz questions'
      # controller.params = {
      #   new_question: {'1' => 'q1', '2' => 'q2', '3' => 'q3'},
      #   new_choices:
      #   {'1' =>
      #     {MultipleChoiceRadio: {'1' => {txt: 'a11', iscorrect: '3'}, '2' => {txt: 'a12'}, '3' => {txt: 'a13'}, '4' => {txt: 'a14'}}},
      #    '2' =>
      #     {TrueFalse: {'1' => {iscorrect: '1'}}},
      #    '3' =>
      #     {MultipleChoiceCheckbox:
      #       {'1' => {iscorrect: '1', txt: 'a31'},
      #        '2' => {iscorrect: '0', txt: 'a32'},
      #        '3' => {iscorrect: '1', txt: 'a33'},
      #        '4' => {iscorrect: '0', txt: 'a34'}}}},
      #   question_type: {'1' => {type: 'MultipleChoiceRadio'}, '2' => {type: 'TrueFalse'}, '3' => {type: 'MultipleChoiceCheckbox'}}
      # }
  end
end
