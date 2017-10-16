describe AssignmentForm do
  let(:assignment) { build(:assignment, id: 1) }
  let(:due_date) { build(:assignment_due_date) }
  let(:assignment_form) { AssignmentForm.new }
  let(:user) { double('Instructor', timezonepref: 'Eastern Time (US & Canada)') }
  let(:assignment_questionnaire) { double('AssignmentQuestionnaire') }
  let(:assignment_questionnaire2) { double('AssignmentQuestionnaire') }
  before(:each) do
    assignment_form.instance_variable_set(:@assignment, assignment)
  end

  describe '.create_form_object' do
    it 'create an assignment_form object'
  end

  describe '#update' do
    it 'updates related objects successfully and returns true'
  end

  describe '#update_assignment' do
    context 'when updating attributes of assignment unsuccessfully' do
      it 'changes @has_errors value to true and returns @assignment.num_reviews (3 by default)'
    end

    context 'when updating attributes of assignment successfully' do
      it 'returns @assignment.num_reviews (3 by default) and the value of @has_errors is nil'
    end
  end

  describe '#update_assignment_questionnaires' do
    context 'when attributes are nil' do
      it 'returns false'
    end

    context 'when attributes are not nil and at least one assignment_questionnaire\'s id is nil or blank' do
      context 'when both save and update_attributes method do not work' do
        it 'changes @has_errors value to true and returns attributes (args)'
      end

      context 'when both save and update_attributes method work well' do
        it 'returns attributes (args) and @has_errors value is nil'
      end
    end
  end

  describe '#update_due_dates' do
    context 'when attributes are nil' do
      it 'returns false'
    end

    context 'when attributes are not nil and at least one due_date\'s id is nil or blank' do
      context 'when both save and update_attributes method do not work' do
        it 'changes @has_errors value to true and returns attributes (args)'
      end

      context 'when both save and update_attributes method work well' do
        it 'returns attributes (args) and @has_errors and @errors value is nil'
      end
    end
  end

  describe '#add_to_delayed_queue' do
    context 'when the deadline type is review' do
      it 'adds two delayed jobs and changes the # of DelayedJob by 2'
    end

    context 'when the deadline type is team formation and current assignment is team-based assignment' do
      it 'adds a delayed job and changes the # of DelayedJob by 2'
    end
  end

  describe '#change_item_type' do
    it 'changes the item_type displayes in the log'
  end

  describe '#find_min_from_now' do
    it 'returns the difference between current time and due date in minutes'
  end

  describe '#set_up_assignment_review' do
    it 'updates round_of_reviews (eg. from 1 to 2) and directory_path of current assignment'
  end

  describe '#staggered_deadline' do
    context 'when current assignment.staggered_deadlines is nil' do
      it 'sets staggered_deadline attribute of current assignment to false'
    end

    context 'when current assignment.staggered_deadlines is not nil' do
      it 'does not change staggered_deadline attribute of current assignment'
    end
  end

  describe '#availability_flag' do
    context 'when current assignment.availability_flag is nil' do
      it 'sets availability_flag attribute of current assignment to false'
    end

    context 'when current assignment.availability_flag is not nil' do
      it 'does not change availability_flag attribute of current assignment'
    end
  end

  describe '#micro_task' do
    context 'when current assignment.microtask is nil' do
      it 'sets microtask attribute of current assignment to false'
    end

    context 'when current assignment.microtask is not nil' do
      it 'does not change microtask attribute of current assignment'
    end
  end

  describe '#reviews_visible_to_all' do
    context 'when current assignment.reviews_visible_to_all is nil' do
      it 'sets reviews_visible_to_all attribute of current assignment to false'
    end

    context 'when current assignment.reviews_visible_to_all is not nil' do
      it 'does not change reviews_visible_to_all attribute of current assignment'
    end
  end

  describe '#review_assignment_strategy' do
    context 'when current assignment.review_assignment_strategy is nil' do
      it 'sets review_assignment_strategy attribute of current assignment to false'
    end

    context 'when current assignment.review_assignment_strategy is not nil' do
      it 'does not change review_assignment_strategy attribute of current assignment'
    end
  end

  describe '#require_quiz' do
    context 'when current assignment is a calibrated assignment' do
      it 'sets require_quiz attribute of current assignment to false'
    end

    context 'when current assignment.require_quiz is not nil' do
      it 'does not change require_quiz attribute of current assignment'
    end
  end

  describe '.copy' do
    it 'copies the original assignment to a new one and returns the new assignment_id'
  end
end
