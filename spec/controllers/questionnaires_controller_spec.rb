# frozen_string_literal: true

describe QuestionnairesController do
  let(:itemnaire) do
    build(id: 1, name: 'itemnaire', ta_id: 8, course_id: 1, private: false, min_item_score: 0, max_item_score: 5, type: 'ReviewQuestionnaire')
  end
  let(:itemnaire) { build(:itemnaire) }
  let(:quiz_itemnaire) { build(:itemnaire, type: 'QuizQuestionnaire') }
  let(:review_itemnaire) { build(:itemnaire, type: 'ReviewQuestionnaire') }
  let(:item) { build(:item, id: 1) }
  let(:admin) { build(:admin) }
  let(:instructor) { build(:instructor, id: 6) }
  let(:instructor2) { build(:instructor, id: 66) }
  let(:ta) { build(:teaching_assistant, id: 8) }
  let(:itemnaire1) { build(itemnaire, id: 1, assignment_id: 1, itemnaire_id: 1, used_in_round: 1) }
  let(:itemnaire2) { build(itemnaire, id: 2, assignment_id: 1, itemnaire_id: 2, used_in_round: 2) }
  let(:assignment) { build(assignment, id: 1) }
  let(:due_date1) { build(due_date, id: 1, due_at: '2019-11-30 23:30:12', deadline_type_id: 1, parent_id: 1, round: 1) }
  let(:due_date2) { build(due_date, id: 2, due_at: '2500-12-30 23:30:12', deadline_type_id: 2, parent_id: 1, round: 1) }
  let(:due_date3) { build(due_date, id: 3, due_at: '2019-01-30 23:30:12', deadline_type_id: 1, parent_id: 1, round: 2) }
  let(:due_date4) { build(due_date, id: 4, due_at: '2019-02-28 23:30:12', deadline_type_id: 2, parent_id: 1, round: 2) }
  let(:assignment_itemnaire1) { build(assignment_itemnaire, id: 1, assignment_id: 1, itemnaire_id: 1, used_in_round: 1) }
  let(:assignment_itemnaire2) { build(assignment_itemnaire, id: 2, assignment_id: 1, itemnaire_id: 2, used_in_round: 2) }
  before(:each) do
    allow(Questionnaire).to receive(:find).with('1').and_return(itemnaire)
    stub_current_user(instructor, instructor.role.name, instructor.role)
  end

  def check_access(username)
    stub_current_user(username, username.role.name, username.role)
    expect(controller.send(:action_allowed?))
  end

  describe '#action_allowed?' do
    let(:itemnaire) { build(:itemnaire, id: 1) }
    let(:instructor) { build(:instructor, id: 1) }
    let(:ta) { build(:teaching_assistant, id: 10, parent_id: 66) }

    context 'when request_params action is edit or update' do
      before(:each) do
        controller.params = { id: '1', action: 'edit' }
        controller.request.session[:user] = instructor
      end

      context 'when the role name of current user is super admin or admin' do
        it 'allows certain action' do
          check_access(admin).to be true
        end
      end

      context 'when current user is the instructor of current itemnaires' do
        it 'allows certain action' do
          check_access(instructor).to be true
        end
      end

      context 'when current user is the ta of the course which current itemnaires belongs to' do
        it 'allows certain action' do
          teaching_assistant = create(:teaching_assistant)
          stub_current_user(teaching_assistant, teaching_assistant.role.name, teaching_assistant.role)
          course = create(:course)
          TaMapping.create(ta_id: teaching_assistant.id, course_id: course.id)
          check_access(teaching_assistant).to be true
        end
      end

      context 'when current user is a ta but not the ta of the course which current itemnaires belongs to' do
        it 'does not allow certain action' do
          # The itemnaire is associated with the first instructor
          # A factory created course will associate itself with the first instructor
          # So here we want the TA on a course that explicitly has some other instructor
          # Otherwise the TA will be indirectly associated with the itemnaire
          teaching_assistant = create(:teaching_assistant)
          stub_current_user(teaching_assistant, teaching_assistant.role.name, teaching_assistant.role)
          instructor1 = create(:instructor, name: 'test_instructor1')
          instructor2 = create(:instructor, name: 'test_instructor2')
          course = create(:course, instructor_id: instructor2.id)
          TaMapping.create(ta_id: teaching_assistant.id, course_id: course.id)
          check_access(teaching_assistant).to be false
        end
      end

      context 'when current user is the instructor of the course which current itemnaires belongs to' do
        it 'allows certain action' do
          allow(Course).to receive(:find).with(1).and_return(double('Course', instructor_id: 6))
          check_access(instructor).to be true
        end
      end

      context 'when current user is an instructor but not the instructor of current course or current itemnaires' do
        it 'does not allow certain action' do
          allow(Course).to receive(:find).with(1).and_return(double('Course', instructor_id: 66))
          check_access(instructor2).to be false
        end
      end
    end
    context 'when request_params action is not edit and update' do
      before(:each) do
        controller.params = { id: '1', action: 'new' }
      end

      context 'when the role current user is super admin/admin/instructor/ta' do
        it 'allows certain action except edit and update' do
          check_access(admin).to be true
        end
      end
    end
  end
  describe '#copy' do
    it 'redirects to view page of copied itemnaire' do
      allow(Questionnaire).to receive(:find).with('1').and_return(itemnaire)
      allow(Question).to receive(:where).with(itemnaire_id: '1').and_return([item])
      allow(instructor).to receive(:instructor_id).and_return(6)
      item_advice = build(:item_advice)
      allow(QuestionAdvice).to receive(:where).with(item_id: 1).and_return([item_advice])
      tree_folder = double('TreeFolder', id: 1)
      allow(TreeFolder).to receive(:find_by).with(name: 'Review').and_return(tree_folder)
      allow(FolderNode).to receive(:find_by).with(node_object_id: 1).and_return(double('FolderNode', id: 1))
      allow(QuestionnaireNode).to receive(:find_or_create_by).with(parent_id: 1, node_object_id: 2).and_return(double('QuestionnaireNode'))
      allow_any_instance_of(QuestionnairesController).to receive(:undo_link).with(any_args).and_return('')
      request_params = { id: 1 }
      user_session = { user: instructor }
      get :copy, params: request_params, session: user_session
      expect(response).to redirect_to('/itemnaires/view?id=2')
      expect(controller.instance_variable_get(:@itemnaire).name).to eq('Copy of ' + itemnaire.name)
      expect(controller.instance_variable_get(:@itemnaire).private).to eq false
      expect(controller.instance_variable_get(:@itemnaire).min_item_score).to eq 0
      expect(controller.instance_variable_get(:@itemnaire).max_item_score).to eq 5
      expect(controller.instance_variable_get(:@itemnaire).type).to eq 'ReviewQuestionnaire'
      expect(controller.instance_variable_get(:@itemnaire).display_type).to eq 'Review'
      expect(controller.instance_variable_get(:@itemnaire).instructor_id).to eq 6
    end
  end

  describe '#view' do
    it 'renders itemnaires#view page' do
      allow(Questionnaire).to receive(:find).with('1').and_return(itemnaire)
      request_params = { id: 1 }
      get :view, params: request_params
      expect(response).to render_template(:view)
    end
  end

  describe '#new' do
    context 'when request_params[:model] has whitespace in it' do
      it 'creates new itemnaire object and renders itemnaires#new page' do
        request_params = { model: 'Assignment SurveyQuestionnaire' }
        get :new, params: request_params
        expect(response).to render_template(:new)
      end
    end

    context 'when request_params[:model] does not have whitespace in it' do
      it 'creates new itemnaire object and renders itemnaires#new page' do
        request_params = { model: 'ReviewQuestionnaire' }
        get :new, params: request_params
        expect(response).to render_template(:new)
      end
    end

    context 'when the itemnaire is a bookmark rating rubric' do
      it 'creates new itemnaire object and renders itemnaires#new page' do
        request_params = { model: 'BookmarkRatingQuestionnaire' }
        get :new, params: request_params
        expect(response).to render_template(:new)
      end
    end

    context 'when the itemnaire is a bookmark rating rubric and has whitespace' do
      it 'creates new itemnaire object and renders itemnaires#new page' do
        request_params = { model: 'Bookmark RatingQuestionnaire' }
        get :new, params: request_params
        expect(response).to render_template(:new)
      end
    end
  end

  describe '#create' do
    it 'redirects to itemnaires#edit page after create a new itemnaire' do
      request_params = { itemnaire: { name: 'test itemnaire',
                                          private: false,
                                          min_item_score: 0,
                                          max_item_score: 5,
                                          type: 'ReviewQuestionnaire' } }
      user_session = { user: instructor }
      tree_folder = double('TreeFolder', id: 1)
      allow(TreeFolder).to receive_message_chain(:where, :first).with(['name like ?', 'Review']).with(no_args).and_return(tree_folder)
      allow(FolderNode).to receive(:find_by).with(node_object_id: 1).and_return(double('FolderNode', id: 1))
      allow(QuestionnaireNode).to receive(:create).with(parent_id: 1, node_object_id: 1, type: 'QuestionnaireNode').and_return(double('QuestionnaireNode'))
      post :create, params: request_params, session: user_session
      expect(flash[:success]).to eq('You have successfully created a itemnaire!')
      expect(response).to redirect_to('/itemnaires/1/edit')
      expect(controller.instance_variable_get(:@itemnaire).private).to eq false
      expect(controller.instance_variable_get(:@itemnaire).name).to eq 'test itemnaire'
      expect(controller.instance_variable_get(:@itemnaire).min_item_score).to eq 0
      expect(controller.instance_variable_get(:@itemnaire).max_item_score).to eq 5
      expect(controller.instance_variable_get(:@itemnaire).type).to eq 'ReviewQuestionnaire'
      expect(controller.instance_variable_get(:@itemnaire).display_type).to eq 'Review'
      expect(controller.instance_variable_get(:@itemnaire).instructor_id).to eq 6
    end
  end

  describe '#edit' do
    context 'when @itemnaire is not nil' do
      it 'renders the itemnaires#edit page' do
        allow(Questionnaire).to receive(:find).with('1').and_return(double('Questionnaire', instructor_id: 6))
        user_session = { user: instructor }
        request_params = { id: 1 }
        get :edit, params: request_params, session: user_session
        expect(response).to render_template(:edit)
      end
    end

    context 'when @itemnaire is nil' do
      it 'redirects to root page' do
        allow(Questionnaire).to receive(:find).with('666').and_return(nil)
        user_session = { user: instructor }
        request_params = { id: 666 }
        get :edit, params: request_params, session: user_session
        expect(response).to redirect_to('/')
      end
    end
  end

  describe '#update' do
    before(:each) do
      @itemnaire1 = double('Questionnaire', id: 1)
      allow(Questionnaire).to receive(:find).with('1').and_return(@itemnaire1)
      @request_params = { id: 1,
                          itemnaire: { name: 'test itemnaire',
                                           instructor_id: 6,
                                           private: 0,
                                           min_item_score: 0,
                                           max_item_score: 5,
                                           type: 'ReviewQuestionnaire',
                                           display_type: 'Review',
                                           instructor_loc: '' } }
      @request_params_with_item = { id: 1,
                                        itemnaire: { name: 'test itemnaire',
                                                         instructor_id: 6,
                                                         private: 0,
                                                         min_item_score: 0,
                                                         max_item_score: 5,
                                                         type: 'ReviewQuestionnaire',
                                                         display_type: 'Review',
                                                         instructor_loc: '' },
                                        item: { '1' => { seq: 66.0,
                                                             txt: 'WOW',
                                                             weight: 10,
                                                             size: '50,3',
                                                             max_label: 'Strong agree',
                                                             min_label: 'Not agree' } } }
    end
    context 'successfully updates the attributes of itemnaire' do
      it 'redirects to itemnaires#edit page after updating' do
        allow(@itemnaire1).to receive(:update_attributes).with(any_args).and_return(true)
        # need complete request_params hash to handle strong parameters
        post :update, params: @request_params
        expect(flash[:success]).to eq 'The itemnaire has been successfully updated!'
        expect(response).to redirect_to('/itemnaires/1/edit')
      end
    end

    context 'have some errors when updating the attributes of itemnaire' do
      it 'redirects to itemnaires#edit page after updating' do
        allow(@itemnaire1).to receive(:update_attributes).with(any_args).and_raise('This is an error!')
        post :update, params: @request_params
        expect(flash[:error].to_s).to eq 'This is an error!'
        expect(response).to redirect_to('/itemnaires/1/edit')
      end
    end

    context 'successfully updates the items in a itemnaire' do
      it 'redirects to itemnaires#edit page after saving all items' do
        allow(Question).to receive(:find).with('1').and_return(item)
        allow(item).to receive(:save).and_return(true)
        allow(@itemnaire1).to receive(:update_attributes).with(any_args).and_return(true)
        post :update, params: @request_params_with_item
        expect(flash[:success]).to eq('The itemnaire has been successfully updated!')
        expect(response).to redirect_to('/itemnaires/1/edit')
      end
    end

    context 'when request_params[:view_advice] is not nil' do
      it 'redirects to advice#edit_advice page' do
        request_params = { id: 1,
                           view_advice: true }
        post :update, params: request_params
        expect(response).to redirect_to('/advice/edit_advice?id=1')
      end
    end

    context 'when request_params[:add_new_items] is not nil' do
      it 'redirects to itemnaire#add_new_items' do
        request_params = { id: 1,
                           add_new_items: true,
                           new_item: { total_num: 2,
                                           type: 'Criterion' } }
        post :update, params: request_params
        expect(response).to redirect_to action: 'add_new_items', id: request_params[:id], item: request_params[:new_item]
      end
    end
  end

  describe '#delete' do
    context 'when @itemnaire.assignments returns non-empty array' do
      it 'sends the error message to flash[:error]' do
        itemnaire1 = double('Questionnaire',
                                name: 'test itemnaire',
                                assignments: [double('Assignment',
                                                     name: 'test assignment')])
        allow(Questionnaire).to receive(:find).with('1').and_return(itemnaire1)
        request_params = { id: 1 }
        get :delete, params: request_params
        expect(flash[:error]).to eq('The assignment <b>test assignment</b> uses this itemnaire. Are sure you want to delete the assignment?')
        expect(response).to redirect_to('/tree_display/list')
      end
    end

    context 'when item.answers returns non-empty array' do
      it 'sends the error message to flash[:error]' do
        itemnaire1 = double('Questionnaire',
                                name: 'test itemnaire',
                                assignments: [],
                                items: [double('Question',
                                                   answers: [double('Answer')])])
        allow(Questionnaire).to receive(:find).with('1').and_return(itemnaire1)
        request_params = { id: 1 }
        get :delete, params: request_params
        expect(flash[:error]).to eq('There are responses based on this rubric, we suggest you do not delete it.')
        expect(response).to redirect_to('/tree_display/list')
      end
    end

    context 'when @itemnaire.assignments and item.answers return empty arrays' do
      it 'deletes all objects related to current itemnaire' do
        advices = [double('QuestionAdvice')]
        item = double('Question', answers: [], item_advices: advices)
        itemnaire_node = double('QuestionnaireNode')
        itemnaire1 = double('Questionnaire',
                                name: 'test itemnaire',
                                assignments: [],
                                items: [item],
                                itemnaire_node: itemnaire_node)
        allow(Questionnaire).to receive(:find).with('1').and_return(itemnaire1)
        allow(advices).to receive(:each).with(any_args).and_return(true)
        allow(item).to receive(:delete).and_return(true)
        allow(itemnaire_node).to receive(:delete).and_return(true)
        allow(itemnaire1).to receive(:delete).and_return(true)
        allow_any_instance_of(QuestionnairesController).to receive(:undo_link).with(any_args).and_return(true)
        request_params = { id: 1 }
        get :delete, params: request_params
        expect(flash[:error]).to eq nil
        expect(response).to redirect_to('/tree_display/list')
      end
    end
  end

  describe '#add_new_items' do
    let(:criterion) { Criterion.new(id: 2, weight: 1, max_label: '', min_label: '', size: '', alternatives: '') }
    let(:dropdown) { Dropdown.new(id: 3, size: '', alternatives: '') }

    context 'when adding ScoredQuestion' do
      it 'redirects to itemnaires#edit page after adding new items' do
        allow(Questionnaire).to receive(:find).with('1').and_return(double('Questionnaire', id: 1, items: [criterion]))
        allow(item).to receive(:seq).and_return(0)
        allow_any_instance_of(Array).to receive(:ids).and_return([2]) # need to stub since .ids isn't recognized in the context of testing
        allow(item).to receive(:save).and_return(true)
        request_params = { id: 1,
                           item: { total_num: 2,
                                       type: 'Criterion' } }
        post :add_new_items, params: request_params
        expect(response).to redirect_to('/itemnaires/1/edit')
      end
    end

    context 'when adding unScoredQuestion' do
      it 'redirects to itemnaires#edit page after adding new items' do
        allow(Questionnaire).to receive(:find).with('1').and_return(double('Questionnaire', id: 1, items: [dropdown]))
        allow_any_instance_of(Array).to receive(:ids).and_return([3]) # need to stub since .ids isn't recognized in the context of testing
        allow(item).to receive(:save).and_return(true)
        request_params = { id: 1,
                           item: { total_num: 2,
                                       type: 'Dropdown' } }
        post :add_new_items, params: request_params
        expect(response).to redirect_to('/itemnaires/1/edit')
      end
    end

    context 'when add_new_items is called and the change is not in the period.' do
      it 'AnswerHelper.in_active_period should be called to check if this change is in the period.' do
        allow(AnswerHelper).to receive(:in_active_period).with('1').and_return(false)
        expect(AnswerHelper).to receive(:in_active_period).with('1')
        request_params = { id: 1,
                           item: { total_num: 2,
                                       type: 'Criterion' } }
        post :add_new_items, params: request_params
      end
    end

    context 'when add_new_items is called and the change is in the period.' do
      it 'AnswerHelper.delete_existing_responses should be called to check if this change is in the period.' do
        allow(AnswerHelper).to receive(:in_active_period).with('1').and_return(true)
        allow(AnswerHelper).to receive(:delete_existing_responses).with([], '1')
        expect(AnswerHelper).to receive(:delete_existing_responses).with([], '1')
        request_params = { id: 1,
                           item: { total_num: 2,
                                       type: 'Criterion' } }
        post :add_new_items, params: request_params
      end
    end
  end

  describe '#save_all_items' do
    context 'when request_params[:save] is not nil, params: request_params[:view_advice] is nil' do
      it 'redirects to itemnaires#edit page after saving all items' do
        allow(Question).to receive(:find).with('1').and_return(item)
        allow(item).to receive(:save).and_return(true)
        request_params = { id: 1,
                           save: true,
                           item: { '1' => { seq: 66.0,
                                                txt: 'WOW',
                                                weight: 10,
                                                size: '50,3',
                                                max_label: 'Strong agree',
                                                min_label: 'Not agree' } } }
        post :save_all_items, params: request_params
        expect(flash[:success]).to eq('All items have been successfully saved!')
        expect(response).to redirect_to('/itemnaires/1/edit')
      end
    end

    context 'when request_params[:save] is nil, params: request_params[:view_advice] is not nil' do
      it 'redirects to advice#edit_advice page' do
        request_params = { id: 1,
                           view_advice: true,
                           item: {} }
        post :save_all_items, params: request_params
        expect(response).to redirect_to('/advice/edit_advice?id=1')
      end
    end
  end
end
