describe QuestionnairesController do
  let(:questionnaire) do
    build(id: 1, name: 'questionnaire', ta_id: 8, course_id: 1, private: false, min_question_score: 0, max_question_score: 5, type: 'ReviewQuestionnaire')
  end
  let(:questionnaire) { build(:questionnaire) }
  let(:quiz_questionnaire) { build(:questionnaire, type: 'QuizQuestionnaire') }
  let(:review_questionnaire) { build(:questionnaire, type: 'ReviewQuestionnaire') }
  let(:question) { build(:question, id: 1) }
  let(:admin) { build(:admin) }
  let(:instructor) { build(:instructor, id: 6) }
  let(:instructor2) { build(:instructor, id: 66) }
  let(:ta) { build(:teaching_assistant, id: 8) }
  before(:each) do
    allow(Questionnaire).to receive(:find).with('1').and_return(questionnaire)
    stub_current_user(instructor, instructor.role.name, instructor.role)
  end

  def check_access username
    stub_current_user(username, username.role.name, username.role)
    expect(controller.send(:action_allowed?))
  end

  describe '#action_allowed?' do
    let(:questionnaire) { build(:questionnaire, id: 1) }
    let(:instructor) { build(:instructor, id: 1) }
    let(:ta) { build(:teaching_assistant, id: 10, parent_id: 66) }
    context 'when params action is edit or update' do
      before(:each) do
        controller.params = {id: '1', action: 'edit'}
        controller.request.session[:user] = instructor
      end

      context 'when the role name of current user is super admin or admin' do
        it 'allows certain action' do
          check_access(admin).to be true
        end
      end

      context 'when current user is the instructor of current questionnaires' do
        it 'allows certain action' do
          check_access(instructor).to be true
        end
      end

      context 'when current user is the ta of the course which current questionnaires belongs to' do
        it 'allows certain action' do
          allow(TaMapping).to receive(:exists?).with(ta_id: 8, course_id: 1).and_return(true)
          check_access(ta).to be true
        end
      end
      context 'when current user is a ta but not the ta of the course which current questionnaires belongs to' do
        it 'does not allow certain action' do
          allow(TaMapping).to receive(:exists?).with(ta_id: 10, course_id: 1).and_return(false)
          controller.request.session[:user] = instructor2
          check_access(ta).to be false
        end
      end

      context 'when current user is the instructor of the course which current questionnaires belongs to' do
        it 'allows certain action' do
          allow(Course).to receive(:find).with(1).and_return(double('Course', instructor_id: 6))
          check_access(instructor).to be true
        end
      end

      context 'when current user is an instructor but not the instructor of current course or current questionnaires' do
        it 'does not allow certain action' do
          allow(Course).to receive(:find).with(1).and_return(double('Course', instructor_id: 66))
          check_access(instructor2).to be false
        end
      end
    end
    context 'when params action is not edit and update' do
      before(:each) do
        controller.params = {id: '1', action: 'new'}
      end

      context 'when the role current user is super admin/admin/instructor/ta' do
        it 'allows certain action except edit and update' do
          check_access(admin).to be true
        end
      end
    end
  end
  describe '#copy' do
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
      params = {questionnaire: {name: 'test questionnaire',
                                private: false,
                                min_question_score: 0,
                                max_question_score: 5,
                                type: 'ReviewQuestionnaire'}}
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

  describe '#edit' do
    context 'when @questionnaire is not nil' do
      it 'renders the questionnaires#edit page' do
        allow(Questionnaire).to receive(:find).with('1').and_return(double('Questionnaire', instructor_id: 6))
        session = {user: instructor}
        params = {id: 1}
        get :edit, params, session
        expect(response).to render_template(:edit)
      end
    end

    context 'when @questionnaire is nil' do
      it 'redirects to root page' do
        allow(Questionnaire).to receive(:find).with('666').and_return(nil)
        session = {user: instructor}
        params = {id: 666}
        get :edit, params, session
        expect(response).to redirect_to('/')
      end
    end
  end

  describe '#update' do
    before(:each) do
      @questionnaire1 = double('Questionnaire', id: 1)
      allow(Questionnaire).to receive(:find).with('1').and_return(@questionnaire1)
      @params = {id: 1,
                 questionnaire: {name: 'test questionnaire',
                                 instructor_id: 6,
                                 private: 0,
                                 min_question_score: 0,
                                 max_question_score: 5,
                                 type: 'ReviewQuestionnaire',
                                 display_type: 'Review',
                                 instructor_loc: ''}}
      @params_with_question = {id: 1,
                               questionnaire: {name: 'test questionnaire',
                                               instructor_id: 6,
                                               private: 0,
                                               min_question_score: 0,
                                               max_question_score: 5,
                                               type: 'ReviewQuestionnaire',
                                               display_type: 'Review',
                                               instructor_loc: ''},
                               question: {'1' => {seq: 66.0,
                                                  txt: 'WOW',
                                                  weight: 10,
                                                  size: '50,3',
                                                  max_label: 'Strong agree',
                                                  min_label: 'Not agree'}}}
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

    context 'successfully updates the questions in a questionnaire' do
      it 'redirects to questionnaires#edit page after saving all questions' do
        allow(Question).to receive(:find).with('1').and_return(question)
        allow(question).to receive(:save).and_return(true)
        allow(@questionnaire1).to receive(:update_attributes).with(any_args).and_return(true)
        post :update, @params_with_question
        expect(flash[:success]).to eq('The questionnaire has been successfully updated!')
        expect(response).to redirect_to('/questionnaires/1/edit')
      end
    end

    context 'when params[:view_advice] is not nil' do
      it 'redirects to advice#edit_advice page' do
        params = {id: 1,
                  view_advice: true}
        post :update, params
        expect(response).to redirect_to('/advice/edit_advice/1')
      end
    end

    context 'when params[:add_new_questions] is not nil' do
      it 'redirects to questionnaire#add_new_questions' do
        params = {id: 1,
                  add_new_questions: true,
                  new_question: {total_num: 2,
                                 type: 'Criterion'}}
        post :update, params
        expect(response).to redirect_to action: 'add_new_questions', id: params[:id], question: params[:new_question]
      end
    end
  end

  describe '#delete' do
    context 'when @questionnaire.assignments returns non-empty array' do
      it 'sends the error message to flash[:error]' do
        questionnaire1 = double('Questionnaire',
                                name: 'test questionnaire',
                                assignments: [double('Assignment',
                                                     name: 'test assignment')])
        allow(Questionnaire).to receive(:find).with('1').and_return(questionnaire1)
        params = {id: 1}
        get :delete, params
        expect(flash[:error]).to eq('The assignment <b>test assignment</b> uses this questionnaire. Are sure you want to delete the assignment?')
        expect(response).to redirect_to('/tree_display/list')
      end
    end

    context 'when question.answers returns non-empty array' do
      it 'sends the error message to flash[:error]' do
        questionnaire1 = double('Questionnaire',
                                name: 'test questionnaire',
                                assignments: [],
                                questions: [double('Question',
                                                   answers: [double('Answer')])])
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
        questionnaire1 = double('Questionnaire',
                                name: 'test questionnaire',
                                assignments: [],
                                questions: [question],
                                questionnaire_node: questionnaire_node)
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

  describe '#add_new_questions' do
    context 'when adding ScoredQuestion' do
      it 'redirects to questionnaires#edit page after adding new questions' do
        question = double('Criterion', weight: 1, max_label: '', min_label: '', size: '', alternatives: '')
        allow(Questionnaire).to receive(:find).with('1').and_return(double('Questionnaire', id: 1, questions: [question]))
        allow(question).to receive(:save).and_return(true)
        params = {id: 1,
                  question: {total_num: 2,
                             type: 'Criterion'}}
        post :add_new_questions, params
        expect(response).to redirect_to('/questionnaires/1/edit')
      end
    end

    context 'when adding unScoredQuestion' do
      it 'redirects to questionnaires#edit page after adding new questions' do
        question = double('Dropdown', size: '', alternatives: '')
        allow(Questionnaire).to receive(:find).with('1').and_return(double('Questionnaire', id: 1, questions: [question]))
        allow(question).to receive(:save).and_return(true)
        params = {id: 1,
                  question: {total_num: 2,
                             type: 'Dropdown'}}
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
        params = {id: 1,
                  save: true,
                  question: {'1' => {seq: 66.0,
                                     txt: 'WOW',
                                     weight: 10,
                                     size: '50,3',
                                     max_label: 'Strong agree',
                                     min_label: 'Not agree'}}}
        post :save_all_questions, params
        expect(flash[:success]).to eq('All questions have been successfully saved!')
        expect(response).to redirect_to('/questionnaires/1/edit')
      end
    end

    context 'when params[:save] is nil, params[:view_advice] is not nil' do
      it 'redirects to advice#edit_advice page' do
        params = {id: 1,
                  view_advice: true,
                  question: {}}
        post :save_all_questions, params
        expect(response).to redirect_to('/advice/edit_advice/1')
      end
    end
  end
end
