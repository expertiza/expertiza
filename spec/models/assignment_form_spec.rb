describe AssignmentForm do
  let(:assignment) { build(:assignment, id: 1) }
  let(:due_date) { build(:assignment_due_date) }
  let(:assignment_form) { AssignmentForm.new }
  let(:user) { double('Instructor', timezonepref: 'Eastern Time (US & Canada)') }
  let(:assignment_itemnaire1) { build(:assignment_itemnaire) }
  let(:assignment_itemnaire2) { build(:assignment_itemnaire) }
  let(:assignment_itemnaire2) { build(:assignment_itemnaire, id: 1, duty_id: 1, itemnaire_id: 1) }
  let(:aq_attributes1) { double('AssignmentQuestionnaire') }
  let(:aq_attributes2) { double('AssignmentQuestionnaire') }
  let(:itemnaire1) { double('Questionnaire', type: 'ReviewQuestionnaire') }
  let(:itemnaire2) { double('Questionnaire', type: 'MetareviewQuestionnaire') }
  let(:itemnaire3) { double('Questionnaire', type: 'TeammateReviewQuestionnaire') }
  before(:each) do
    assignment_form.instance_variable_set(:@assignment, assignment)
    allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment.id, used_in_round: 2).and_return([])
  end

  describe '.create_form_object' do
    it 'create an assignment_form object' do
      allow(Assignment).to receive(:find).with(1).and_return(assignment)
      allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: 1).and_return([assignment_itemnaire1])
      allow(AssignmentDueDate).to receive(:where).with(parent_id: 1).and_return([due_date])
      allow_any_instance_of(AssignmentForm).to receive(:set_up_assignment_review).and_return(true)
      expect(AssignmentForm.create_form_object(1).instance_of?(AssignmentForm)).to be true
    end
  end

  describe '#update' do
    it 'updates related objects successfully and returns true' do
      attributes = {
        assignment: {
          late_policy_id: 1,
          simicheck: true
        },
        assignment_itemnaire: [assignment_itemnaire1, assignment_itemnaire2],
        due_date: [double('DueDate'), double('DueDate')]
      }
      allow_any_instance_of(AssignmentForm).to receive(:update_assignment).with(attributes[:assignment]).and_return(true)
      allow_any_instance_of(AssignmentForm).to receive(:update_assignment_itemnaires).with(attributes[:assignment_itemnaire]).and_return(true)
      allow_any_instance_of(AssignmentForm).to receive(:update_assignment_itemnaires).with(attributes[:topic_itemnaire]).and_return(true)
      allow_any_instance_of(AssignmentForm).to receive(:update_due_dates).with(attributes[:due_date], user).and_return(true)
      allow_any_instance_of(AssignmentForm).to receive(:add_simicheck_to_delayed_queue).with(attributes[:assignment][:simicheck]).and_return(true)
      allow_any_instance_of(AssignmentForm).to receive(:delete_from_delayed_queue).and_return(true)
      allow_any_instance_of(AssignmentForm).to receive(:add_to_delayed_queue).and_return(true)
      expect(assignment_form.update(attributes, user)).to be true
    end
  end

  describe '#update_assignment' do
    context 'when updating attributes of assignment unsuccessfully' do
      it 'changes @has_errors value to true and returns @assignment.num_reviews (3 by default)' do
        allow(assignment).to receive(:update_attributes).with({}).and_return(false)
        expect(assignment_form.update_assignment({})).to eq(3)
        expect(assignment_form.instance_variable_get(:@has_errors)).to be true
      end
    end

    context 'when updating attributes of assignment successfully' do
      it 'returns @assignment.num_reviews (3 by default) and the value of @has_errors is nil' do
        allow(assignment).to receive(:update_attributes).with({}).and_return('Succeed!')
        expect(assignment_form.update_assignment({})).to eq(3)
        expect(assignment_form.instance_variable_get(:@has_errors)).to be nil
      end
    end
  end

  describe '#update_assignment_itemnaires' do
    context 'when attributes are nil or empty' do
      it 'returns nil' do
        expect(assignment_form.update_assignment_itemnaires(nil)).to eq(nil)
        expect(assignment_form.update_assignment_itemnaires([])).to eq(nil)
      end
    end

    context 'when attributes are not nil and received from Rubrics' do
      let(:attributes) { [aq_attributes1, aq_attributes2] }

      before(:each) do
        allow(assignment_itemnaire1).to receive(:itemnaire_id).and_return(1)
        allow(assignment_itemnaire2).to receive(:itemnaire_id).and_return(2)
        allow(Questionnaire).to receive(:find).with(1).and_return(itemnaire1)
        allow(Questionnaire).to receive(:find).with(2).and_return(itemnaire2)
        allow(aq_attributes1).to receive(:key?).with(:itemnaire_weight).and_return(true)
        allow(aq_attributes1).to receive(:[]).with(:itemnaire_weight).and_return(100)
        allow(aq_attributes1).to receive(:[]).with(:itemnaire_id).and_return(1)
        allow(aq_attributes1).to receive(:[]).with(:used_in_round).and_return('')
        allow(aq_attributes1).to receive(:key?).with(:topic_id).and_return(false)
        allow(aq_attributes1).to receive(:[]).with(:duty_id).and_return('')
        allow(aq_attributes1).to receive(:key?).with(:duty_id).and_return(false)
        allow(aq_attributes2).to receive(:key?).with(:itemnaire_weight).and_return(true)
        allow(aq_attributes2).to receive(:[]).with(:itemnaire_weight).and_return(0)
        allow(aq_attributes2).to receive(:[]).with(:itemnaire_id).and_return(2)
        allow(aq_attributes2).to receive(:[]).with(:used_in_round).and_return('')
        allow(aq_attributes2).to receive(:key?).with(:topic_id).and_return(false)
        allow(aq_attributes2).to receive(:[]).with(:duty_id).and_return('')
        allow(aq_attributes2).to receive(:key?).with(:duty_id).and_return(false)
      end

      context 'when both active records exist and can be found' do
        before(:each) do
          allow(assignment_itemnaire1).to receive(:id).and_return(1)
          allow(assignment_itemnaire2).to receive(:id).and_return(2)
          allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment.id).and_return(
            [assignment_itemnaire1, assignment_itemnaire2]
          )
        end

        it 'returns attributes (args) and does not change @has_errors value since update_attributes method works correctly' do
          allow(assignment_itemnaire1).to receive(:update_attributes).with(aq_attributes1).and_return(true)
          allow(assignment_itemnaire2).to receive(:update_attributes).with(aq_attributes2).and_return(true)
          expect(assignment_form.update_assignment_itemnaires(attributes)).to eq(attributes)
          expect(assignment_form.instance_variable_get(:@has_errors)).to be nil
        end

        it 'returns attributes (args), but changes @has_errors value to true since update_attributes method works incorrectly for assignment_itemnaire1' do
          allow(assignment_itemnaire1).to receive(:update_attributes).with(aq_attributes1).and_return(false)
          allow(assignment_itemnaire2).to receive(:update_attributes).with(aq_attributes2).and_return(true)
          expect(assignment_form.update_assignment_itemnaires(attributes)).to eq(attributes)
          expect(assignment_form.instance_variable_get(:@has_errors)).to be true
        end

        it 'returns attributes (args), but changes @has_errors value to true since update_attributes method works incorrectly for assignment_itemnaire2' do
          allow(assignment_itemnaire1).to receive(:update_attributes).with(aq_attributes1).and_return(true)
          allow(assignment_itemnaire2).to receive(:update_attributes).with(aq_attributes2).and_return(false)
          expect(assignment_form.update_assignment_itemnaires(attributes)).to eq(attributes)
          expect(assignment_form.instance_variable_get(:@has_errors)).to be true
        end

        it 'returns attributes (args), but changes @has_errors value to true since update_attributes method works incorrectly' do
          allow(assignment_itemnaire1).to receive(:update_attributes).with(aq_attributes1).and_return(false)
          allow(assignment_itemnaire2).to receive(:update_attributes).with(aq_attributes2).and_return(false)
          expect(assignment_form.update_assignment_itemnaires(attributes)).to eq(attributes)
          expect(assignment_form.instance_variable_get(:@has_errors)).to be true
        end

        it 'returns nil and changes @has_errors value to true since itemnaire_weight fails validation' do
          allow(aq_attributes1).to receive(:[]).with(:itemnaire_weight).and_return(50)
          allow(aq_attributes2).to receive(:[]).with(:itemnaire_weight).and_return(40)
          expect(assignment_form.update_assignment_itemnaires(attributes)).to eq(nil)
          expect(assignment_form.instance_variable_get(:@has_errors)).to be true
        end
      end

      context 'when active record assignment_itemnaire exists but assignment_itemnaire2 does not exist' do
        before(:each) do
          allow(assignment_itemnaire1).to receive(:id).and_return(1)
          allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment.id).and_return(
            [assignment_itemnaire1]
          )
          allow(AssignmentQuestionnaire).to receive(:where).with(user_id: anything, assignment_id: nil, itemnaire_id: nil).and_return([])
          allow(AssignmentQuestionnaire).to receive(:new).and_return(assignment_itemnaire2)
        end

        it 'returns attributes (args) and does not change @has_errors value since save and update_attributes methods work correctly' do
          allow(assignment_itemnaire1).to receive(:update_attributes).with(aq_attributes1).and_return(true)
          allow(assignment_itemnaire2).to receive(:save).and_return(true)
          allow(assignment_itemnaire2).to receive(:update_attributes).with(aq_attributes2).and_return(true)
          expect(assignment_form.update_assignment_itemnaires(attributes)).to eq(attributes)
          expect(assignment_form.instance_variable_get(:@has_errors)).to be nil
        end

        it 'returns attributes (args), but changes @has_errors value to true since save method works incorrectly for assignment_itemnaire2' do
          allow(assignment_itemnaire1).to receive(:id).and_return(1)
          allow(assignment_itemnaire1).to receive(:update_attributes).with(aq_attributes1).and_return(true)
          allow(assignment_itemnaire2).to receive(:id).and_return(nil)
          allow(assignment_itemnaire2).to receive(:save).and_return(false)
          expect(assignment_form.update_assignment_itemnaires(attributes)).to eq(attributes)
          expect(assignment_form.instance_variable_get(:@has_errors)).to be true
        end

        it 'returns attributes (args), but changes @has_errors value to true since update_attributes method works incorrectly for assignment_itemnaire2' do
          allow(assignment_itemnaire1).to receive(:id).and_return(1)
          allow(assignment_itemnaire1).to receive(:update_attributes).with(aq_attributes1).and_return(true)
          allow(assignment_itemnaire2).to receive(:id).and_return(nil)
          allow(assignment_itemnaire2).to receive(:save).and_return(true)
          allow(assignment_itemnaire2).to receive(:update_attributes).with(aq_attributes2).and_return(false)
          expect(assignment_form.update_assignment_itemnaires(attributes)).to eq(attributes)
          expect(assignment_form.instance_variable_get(:@has_errors)).to be true
        end

        it 'returns attributes (args), but changes @has_errors value to true since update_attributes method works incorrectly for assignment_itemnaire1' do
          allow(assignment_itemnaire1).to receive(:id).and_return(1)
          allow(assignment_itemnaire1).to receive(:update_attributes).with(aq_attributes1).and_return(false)
          allow(assignment_itemnaire2).to receive(:id).and_return(nil)
          allow(assignment_itemnaire2).to receive(:save).and_return(true)
          allow(assignment_itemnaire2).to receive(:update_attributes).with(aq_attributes2).and_return(true)
          expect(assignment_form.update_assignment_itemnaires(attributes)).to eq(attributes)
          expect(assignment_form.instance_variable_get(:@has_errors)).to be true
        end

        it 'returns nil and changes @has_errors value to true since itemnaire_weight fails validation' do
          allow(aq_attributes1).to receive(:[]).with(:itemnaire_weight).and_return(50)
          allow(aq_attributes2).to receive(:[]).with(:itemnaire_weight).and_return(40)
          expect(assignment_form.update_assignment_itemnaires(attributes)).to eq(nil)
          expect(assignment_form.instance_variable_get(:@has_errors)).to be true
        end
      end

      context 'when active record assignment_itemnaire does not exist but assignment_itemnaire2 exists' do
        before(:each) do
          allow(assignment_itemnaire2).to receive(:id).and_return(2)
          allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment.id).and_return(
            [assignment_itemnaire2]
          )
          allow(AssignmentQuestionnaire).to receive(:where).with(user_id: anything, assignment_id: nil, itemnaire_id: nil).and_return([])
          allow(AssignmentQuestionnaire).to receive(:new).and_return(assignment_itemnaire1)
        end

        it 'returns attributes (args) and does not change @has_errors value since save and update_attributes methods work correctly' do
          allow(assignment_itemnaire1).to receive(:save).and_return(true)
          allow(assignment_itemnaire1).to receive(:update_attributes).with(aq_attributes1).and_return(true)
          allow(assignment_itemnaire2).to receive(:update_attributes).with(aq_attributes2).and_return(true)
          expect(assignment_form.update_assignment_itemnaires(attributes)).to eq(attributes)
          expect(assignment_form.instance_variable_get(:@has_errors)).to be nil
        end

        it 'returns attributes (args), but changes @has_errors value to true since save method works incorrectly for assignment_itemnaire1' do
          allow(assignment_itemnaire1).to receive(:save).and_return(false)
          allow(assignment_itemnaire2).to receive(:update_attributes).with(aq_attributes2).and_return(true)
          expect(assignment_form.update_assignment_itemnaires(attributes)).to eq(attributes)
          expect(assignment_form.instance_variable_get(:@has_errors)).to be true
        end

        it 'returns attributes (args), but changes @has_errors value to true since update_attributes method works incorrectly for assignment_itemnaire1' do
          allow(assignment_itemnaire1).to receive(:save).and_return(true)
          allow(assignment_itemnaire1).to receive(:update_attributes).with(aq_attributes1).and_return(false)
          allow(assignment_itemnaire2).to receive(:update_attributes).with(aq_attributes2).and_return(true)
          expect(assignment_form.update_assignment_itemnaires(attributes)).to eq(attributes)
          expect(assignment_form.instance_variable_get(:@has_errors)).to be true
        end

        it 'returns attributes (args), but changes @has_errors value to true since update_attributes method works incorrectly for assignment_itemnaire2' do
          allow(assignment_itemnaire1).to receive(:save).and_return(true)
          allow(assignment_itemnaire1).to receive(:update_attributes).with(aq_attributes1).and_return(true)
          allow(assignment_itemnaire2).to receive(:update_attributes).with(aq_attributes2).and_return(false)
          expect(assignment_form.update_assignment_itemnaires(attributes)).to eq(attributes)
          expect(assignment_form.instance_variable_get(:@has_errors)).to be true
        end

        it 'returns nil and changes @has_errors value to true since itemnaire_weight validation fails' do
          allow(aq_attributes1).to receive(:[]).with(:itemnaire_weight).and_return(50)
          allow(aq_attributes2).to receive(:[]).with(:itemnaire_weight).and_return(40)
          expect(assignment_form.update_assignment_itemnaires(attributes)).to eq(nil)
          expect(assignment_form.instance_variable_get(:@has_errors)).to be true
        end
      end

      context 'when neither of active record exists' do
        before(:each) do
          allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment.id).and_return([])
          allow(AssignmentQuestionnaire).to receive(:where).with(user_id: anything, assignment_id: nil, itemnaire_id: nil).and_return([])
          allow(AssignmentQuestionnaire).to receive(:new).and_return(assignment_itemnaire1)
        end

        it 'returns attributes (args) and does not change @has_errors value since save and update_attributes methods work correctly' do
          allow(assignment_itemnaire1).to receive(:save).and_return(true)
          allow(assignment_itemnaire1).to receive(:update_attributes).with(aq_attributes1).and_return(true)
          allow(assignment_itemnaire1).to receive(:update_attributes).with(aq_attributes2).and_return(true)
          expect(assignment_form.update_assignment_itemnaires(attributes)).to eq(attributes)
          expect(assignment_form.instance_variable_get(:@has_errors)).to be nil
        end

        it 'returns attributes (args), but changes @has_errors value to true since save method works incorrectly' do
          allow(assignment_itemnaire1).to receive(:save).and_return(false)
          expect(assignment_form.update_assignment_itemnaires(attributes)).to eq(attributes)
          expect(assignment_form.instance_variable_get(:@has_errors)).to be true
        end

        it 'returns attributes (args), but changes @has_errors value to true since update_attributes method works incorrectly' do
          allow(assignment_itemnaire1).to receive(:save).and_return(true)
          allow(assignment_itemnaire1).to receive(:update_attributes).with(aq_attributes1).and_return(false)
          allow(assignment_itemnaire1).to receive(:update_attributes).with(aq_attributes2).and_return(false)
          expect(assignment_form.update_assignment_itemnaires(attributes)).to eq(attributes)
          expect(assignment_form.instance_variable_get(:@has_errors)).to be true
        end

        it 'returns nil and changes @has_errors value to true since itemnaire_weight validation fails' do
          allow(aq_attributes1).to receive(:[]).with(:itemnaire_weight).and_return(50)
          allow(aq_attributes2).to receive(:[]).with(:itemnaire_weight).and_return(40)
          expect(assignment_form.update_assignment_itemnaires(attributes)).to eq(nil)
          expect(assignment_form.instance_variable_get(:@has_errors)).to be true
        end
      end

      context 'when itemnaire_id is not given within attributes' do
        it 'returns attributes (args) and does not change @has_errors value when both attributes do not have itemnaire_id specified' do
          allow(aq_attributes1).to receive(:[]).with(:itemnaire_id).and_return('')
          allow(aq_attributes2).to receive(:[]).with(:itemnaire_id).and_return('')
          expect(assignment_form.update_assignment_itemnaires(attributes)).to eq(attributes)
          expect(assignment_form.instance_variable_get(:@has_errors)).to be nil
        end

        it 'returns attributes (args) and does not change @has_errors value when attributes1 does not have itemnaire_id specified' do
          allow(aq_attributes1).to receive(:[]).with(:itemnaire_id).and_return('')
          allow(assignment_itemnaire2).to receive(:id).and_return(2)
          allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment.id).and_return(
            [assignment_itemnaire2]
          )
          allow(assignment_itemnaire2).to receive(:update_attributes).with(aq_attributes2).and_return(true)
          expect(assignment_form.update_assignment_itemnaires(attributes)).to eq(attributes)
          expect(assignment_form.instance_variable_get(:@has_errors)).to be nil
        end

        it 'returns attributes (args) and does not change @has_errors value when attributes2 does not have itemnaire_id specified' do
          allow(aq_attributes2).to receive(:[]).with(:itemnaire_id).and_return('')
          allow(assignment_itemnaire1).to receive(:id).and_return(1)
          allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment.id).and_return(
            [assignment_itemnaire1]
          )
          allow(assignment_itemnaire1).to receive(:update_attributes).with(aq_attributes1).and_return(true)
          expect(assignment_form.update_assignment_itemnaires(attributes)).to eq(attributes)
          expect(assignment_form.instance_variable_get(:@has_errors)).to be nil
        end
      end
    end

    context 'when attributes are not nil and received from Topics tab' do
      let(:attributes) { [aq_attributes1, aq_attributes2] }

      before(:each) do
        allow(assignment_itemnaire1).to receive(:itemnaire_id).and_return(1)
        allow(assignment_itemnaire2).to receive(:itemnaire_id).and_return(2)
        allow(Questionnaire).to receive(:find).with(1).and_return(itemnaire1)
        allow(Questionnaire).to receive(:find).with(2).and_return(itemnaire2)
        allow(aq_attributes1).to receive(:key?).with(:itemnaire_weight).and_return(false)
        allow(aq_attributes1).to receive(:[]).with(:itemnaire_id).and_return(1)
        allow(aq_attributes1).to receive(:[]).with(:used_in_round).and_return('')
        allow(aq_attributes1).to receive(:key?).with(:topic_id).and_return(true)
        allow(aq_attributes1).to receive(:[]).with(:topic_id).and_return('')
        allow(aq_attributes1).to receive(:[]).with(:duty_id).and_return('')
        allow(aq_attributes1).to receive(:key?).with(:duty_id).and_return(false)
        allow(aq_attributes2).to receive(:key?).with(:itemnaire_weight).and_return(false)
        allow(aq_attributes2).to receive(:[]).with(:itemnaire_id).and_return(2)
        allow(aq_attributes2).to receive(:[]).with(:used_in_round).and_return('')
        allow(aq_attributes2).to receive(:key?).with(:topic_id).and_return(true)
        allow(aq_attributes2).to receive(:[]).with(:topic_id).and_return('')
        allow(aq_attributes2).to receive(:[]).with(:duty_id).and_return('')
        allow(aq_attributes2).to receive(:key?).with(:duty_id).and_return(false)
      end

      context 'when both active records exist and can be found' do
        before(:each) do
          allow(assignment_itemnaire1).to receive(:id).and_return(1)
          allow(assignment_itemnaire2).to receive(:id).and_return(2)
          allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment.id).and_return(
            [assignment_itemnaire1, assignment_itemnaire2]
          )
        end

        it 'returns attributes (args) and does not change @has_errors value since update_attributes method works correctly' do
          allow(assignment_itemnaire1).to receive(:update_attributes).with(aq_attributes1).and_return(true)
          allow(assignment_itemnaire2).to receive(:update_attributes).with(aq_attributes2).and_return(true)
          expect(assignment_form.update_assignment_itemnaires(attributes)).to eq(attributes)
          expect(assignment_form.instance_variable_get(:@has_errors)).to be nil
        end

        it 'returns attributes (args), but changes @has_errors value to true since update_attributes method works incorrectly for assignment_itemnaire1' do
          allow(assignment_itemnaire1).to receive(:update_attributes).with(aq_attributes1).and_return(false)
          allow(assignment_itemnaire2).to receive(:update_attributes).with(aq_attributes2).and_return(true)
          expect(assignment_form.update_assignment_itemnaires(attributes)).to eq(attributes)
          expect(assignment_form.instance_variable_get(:@has_errors)).to be true
        end

        it 'returns attributes (args), but changes @has_errors value to true since update_attributes method works incorrectly for assignment_itemnaire2' do
          allow(assignment_itemnaire1).to receive(:update_attributes).with(aq_attributes1).and_return(true)
          allow(assignment_itemnaire2).to receive(:update_attributes).with(aq_attributes2).and_return(false)
          expect(assignment_form.update_assignment_itemnaires(attributes)).to eq(attributes)
          expect(assignment_form.instance_variable_get(:@has_errors)).to be true
        end

        it 'returns attributes (args), but changes @has_errors value to true since update_attributes method works incorrectly' do
          allow(assignment_itemnaire1).to receive(:update_attributes).with(aq_attributes1).and_return(false)
          allow(assignment_itemnaire2).to receive(:update_attributes).with(aq_attributes2).and_return(false)
          expect(assignment_form.update_assignment_itemnaires(attributes)).to eq(attributes)
          expect(assignment_form.instance_variable_get(:@has_errors)).to be true
        end
      end

      context 'when active record assignment_itemnaire exists but assignment_itemnaire2 does not exist' do
        before(:each) do
          allow(assignment_itemnaire1).to receive(:id).and_return(1)
          allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment.id).and_return(
            [assignment_itemnaire1]
          )
          allow(AssignmentQuestionnaire).to receive(:where).with(user_id: anything, assignment_id: nil, itemnaire_id: nil).and_return([])
          allow(AssignmentQuestionnaire).to receive(:new).and_return(assignment_itemnaire2)
        end

        it 'returns attributes (args) and does not change @has_errors value since save and update_attributes methods work correctly' do
          allow(assignment_itemnaire1).to receive(:update_attributes).with(aq_attributes1).and_return(true)
          allow(assignment_itemnaire2).to receive(:save).and_return(true)
          allow(assignment_itemnaire2).to receive(:update_attributes).with(aq_attributes2).and_return(true)
          expect(assignment_form.update_assignment_itemnaires(attributes)).to eq(attributes)
          expect(assignment_form.instance_variable_get(:@has_errors)).to be nil
        end

        it 'returns attributes (args), but changes @has_errors value to true since save method works incorrectly for assignment_itemnaire2' do
          allow(assignment_itemnaire1).to receive(:id).and_return(1)
          allow(assignment_itemnaire1).to receive(:update_attributes).with(aq_attributes1).and_return(true)
          allow(assignment_itemnaire2).to receive(:id).and_return(nil)
          allow(assignment_itemnaire2).to receive(:save).and_return(false)
          expect(assignment_form.update_assignment_itemnaires(attributes)).to eq(attributes)
          expect(assignment_form.instance_variable_get(:@has_errors)).to be true
        end

        it 'returns attributes (args), but changes @has_errors value to true since update_attributes method works incorrectly for assignment_itemnaire2' do
          allow(assignment_itemnaire1).to receive(:id).and_return(1)
          allow(assignment_itemnaire1).to receive(:update_attributes).with(aq_attributes1).and_return(true)
          allow(assignment_itemnaire2).to receive(:id).and_return(nil)
          allow(assignment_itemnaire2).to receive(:save).and_return(true)
          allow(assignment_itemnaire2).to receive(:update_attributes).with(aq_attributes2).and_return(false)
          expect(assignment_form.update_assignment_itemnaires(attributes)).to eq(attributes)
          expect(assignment_form.instance_variable_get(:@has_errors)).to be true
        end

        it 'returns attributes (args), but changes @has_errors value to true since update_attributes method works incorrectly for assignment_itemnaire1' do
          allow(assignment_itemnaire1).to receive(:id).and_return(1)
          allow(assignment_itemnaire1).to receive(:update_attributes).with(aq_attributes1).and_return(false)
          allow(assignment_itemnaire2).to receive(:id).and_return(nil)
          allow(assignment_itemnaire2).to receive(:save).and_return(true)
          allow(assignment_itemnaire2).to receive(:update_attributes).with(aq_attributes2).and_return(true)
          expect(assignment_form.update_assignment_itemnaires(attributes)).to eq(attributes)
          expect(assignment_form.instance_variable_get(:@has_errors)).to be true
        end
      end

      context 'when active record assignment_itemnaire does not exist but assignment_itemnaire2 exists' do
        before(:each) do
          allow(assignment_itemnaire2).to receive(:id).and_return(2)
          allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment.id).and_return(
            [assignment_itemnaire2]
          )
          allow(AssignmentQuestionnaire).to receive(:where).with(user_id: anything, assignment_id: nil, itemnaire_id: nil).and_return([])
          allow(AssignmentQuestionnaire).to receive(:new).and_return(assignment_itemnaire1)
        end

        it 'returns attributes (args) and does not change @has_errors value since save and update_attributes methods work correctly' do
          allow(assignment_itemnaire1).to receive(:save).and_return(true)
          allow(assignment_itemnaire1).to receive(:update_attributes).with(aq_attributes1).and_return(true)
          allow(assignment_itemnaire2).to receive(:update_attributes).with(aq_attributes2).and_return(true)
          expect(assignment_form.update_assignment_itemnaires(attributes)).to eq(attributes)
          expect(assignment_form.instance_variable_get(:@has_errors)).to be nil
        end

        it 'returns attributes (args), but changes @has_errors value to true since save method works incorrectly for assignment_itemnaire1' do
          allow(assignment_itemnaire1).to receive(:save).and_return(false)
          allow(assignment_itemnaire2).to receive(:update_attributes).with(aq_attributes2).and_return(true)
          expect(assignment_form.update_assignment_itemnaires(attributes)).to eq(attributes)
          expect(assignment_form.instance_variable_get(:@has_errors)).to be true
        end

        it 'returns attributes (args), but changes @has_errors value to true since update_attributes method works incorrectly for assignment_itemnaire1' do
          allow(assignment_itemnaire1).to receive(:save).and_return(true)
          allow(assignment_itemnaire1).to receive(:update_attributes).with(aq_attributes1).and_return(false)
          allow(assignment_itemnaire2).to receive(:update_attributes).with(aq_attributes2).and_return(true)
          expect(assignment_form.update_assignment_itemnaires(attributes)).to eq(attributes)
          expect(assignment_form.instance_variable_get(:@has_errors)).to be true
        end

        it 'returns attributes (args), but changes @has_errors value to true since update_attributes method works incorrectly for assignment_itemnaire2' do
          allow(assignment_itemnaire1).to receive(:save).and_return(true)
          allow(assignment_itemnaire1).to receive(:update_attributes).with(aq_attributes1).and_return(true)
          allow(assignment_itemnaire2).to receive(:update_attributes).with(aq_attributes2).and_return(false)
          expect(assignment_form.update_assignment_itemnaires(attributes)).to eq(attributes)
          expect(assignment_form.instance_variable_get(:@has_errors)).to be true
        end
      end

      context 'when neither of active record exists' do
        before(:each) do
          allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment.id).and_return([])
          allow(AssignmentQuestionnaire).to receive(:where).with(user_id: anything, assignment_id: nil, itemnaire_id: nil).and_return([])
          allow(AssignmentQuestionnaire).to receive(:new).and_return(assignment_itemnaire1)
        end

        it 'returns attributes (args) and does not change @has_errors value since save and update_attributes methods work correctly' do
          allow(assignment_itemnaire1).to receive(:save).and_return(true)
          allow(assignment_itemnaire1).to receive(:update_attributes).with(aq_attributes1).and_return(true)
          allow(assignment_itemnaire1).to receive(:update_attributes).with(aq_attributes2).and_return(true)
          expect(assignment_form.update_assignment_itemnaires(attributes)).to eq(attributes)
          expect(assignment_form.instance_variable_get(:@has_errors)).to be nil
        end

        it 'returns attributes (args), but changes @has_errors value to true since save method works incorrectly' do
          allow(assignment_itemnaire1).to receive(:save).and_return(false)
          expect(assignment_form.update_assignment_itemnaires(attributes)).to eq(attributes)
          expect(assignment_form.instance_variable_get(:@has_errors)).to be true
        end

        it 'returns attributes (args), but changes @has_errors value to true since update_attributes method works incorrectly' do
          allow(assignment_itemnaire1).to receive(:save).and_return(true)
          allow(assignment_itemnaire1).to receive(:update_attributes).with(aq_attributes1).and_return(false)
          allow(assignment_itemnaire1).to receive(:update_attributes).with(aq_attributes2).and_return(false)
          expect(assignment_form.update_assignment_itemnaires(attributes)).to eq(attributes)
          expect(assignment_form.instance_variable_get(:@has_errors)).to be true
        end
      end

      context 'when itemnaire_id is not given within attributes' do
        it 'returns attributes (args) and does not change @has_errors value when both attributes do not have itemnaire_id specified' do
          allow(aq_attributes1).to receive(:[]).with(:itemnaire_id).and_return('')
          allow(aq_attributes2).to receive(:[]).with(:itemnaire_id).and_return('')
          expect(assignment_form.update_assignment_itemnaires(attributes)).to eq(attributes)
          expect(assignment_form.instance_variable_get(:@has_errors)).to be nil
        end

        it 'returns attributes (args) and does not change @has_errors value when attributes1 does not have itemnaire_id specified' do
          allow(aq_attributes1).to receive(:[]).with(:itemnaire_id).and_return('')
          allow(assignment_itemnaire2).to receive(:id).and_return(2)
          allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment.id).and_return(
            [assignment_itemnaire2]
          )
          allow(assignment_itemnaire2).to receive(:update_attributes).with(aq_attributes2).and_return(true)
          expect(assignment_form.update_assignment_itemnaires(attributes)).to eq(attributes)
          expect(assignment_form.instance_variable_get(:@has_errors)).to be nil
        end

        it 'returns attributes (args) and does not change @has_errors value when attributes2 does not have itemnaire_id specified' do
          allow(aq_attributes2).to receive(:[]).with(:itemnaire_id).and_return('')
          allow(assignment_itemnaire1).to receive(:id).and_return(1)
          allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment.id).and_return(
            [assignment_itemnaire1]
          )
          allow(assignment_itemnaire1).to receive(:update_attributes).with(aq_attributes1).and_return(true)
          expect(assignment_form.update_assignment_itemnaires(attributes)).to eq(attributes)
          expect(assignment_form.instance_variable_get(:@has_errors)).to be nil
        end
      end
    end
  end

  describe '#update_due_dates' do
    context 'when attributes are nil' do
      it 'returns false' do
        expect(assignment_form.update_due_dates(nil, user)).to be false
      end
    end

    context 'when attributes are not nil and at least one due_date\'s id is nil or blank' do
      let(:due_date2) { { due_at: '2015-06-22 12:05:00 -0400' } }
      let(:due_date3) { { id: 1, due_at: '2015-06-22 12:05:00 -0400' } }
      let(:attributes) { [due_date2, due_date3] }
      before(:each) do
        allow(AssignmentDueDate).to receive(:new).with(due_date2).and_return(due_date2)
        allow(AssignmentDueDate).to receive(:find).with(1).and_return(due_date3)
      end

      context 'when both save and update_attributes method do not work' do
        it 'changes @has_errors value to true and returns attributes (args)' do
          allow(due_date2).to receive(:save).and_return(false)
          allow(due_date3).to receive(:update_attributes).with(due_date3).and_return(false)
          assignment_form.instance_variable_set(:@errors, '')
          expect(assignment_form.update_due_dates(attributes, user)).to eq(attributes)
          expect(assignment_form.instance_variable_get(:@has_errors)).to be true
          expect(assignment_form.instance_variable_get(:@errors)).to match(/ActiveModel::Errors/)
        end
      end

      context 'when both save and update_attributes method work well' do
        it 'returns attributes (args) and @has_errors and @errors value is nil' do
          allow(due_date2).to receive(:save).and_return(true)
          allow(due_date3).to receive(:update_attributes).with(due_date3).and_return(true)
          expect(assignment_form.update_due_dates(attributes, user)).to eq(attributes)
          expect(assignment_form.instance_variable_get(:@has_errors)).to be nil
          expect(assignment_form.instance_variable_get(:@errors)).to be nil
        end
      end
    end
  end

  describe '#add_to_delayed_queue' do
    before(:each) do
      allow(AssignmentDueDate).to receive(:where).with(parent_id: 1).and_return([due_date])
      allow_any_instance_of(AssignmentForm).to receive(:find_min_from_now).with(any_args).and_return(666)
      allow(due_date).to receive(:update_attribute).with(:delayed_job_id, any_args).and_return('Succeed!')
      Sidekiq::Testing.inline!
    end

    context 'when the deadline type is review' do
      it 'adds two delayed jobs and changes the # of DelayedJob by 2' do
        allow(DeadlineType).to receive(:find).with(1).and_return(double('DeadlineType', name: 'review'))
        Sidekiq::Testing.fake!
        Sidekiq::RetrySet.new.clear
        Sidekiq::ScheduledSet.new.clear
        Sidekiq::Stats.new.reset
        Sidekiq::DeadSet.new.clear
        queue = Sidekiq::Queues['mailers']
        expect { assignment_form.add_to_delayed_queue }.to change { queue.size }.by(2)
      end
    end

    context 'when the deadline type is team formation and current assignment is team-based assignment' do
      it 'adds a delayed job and changes the # of DelayedJob by 2' do
        allow(DeadlineType).to receive(:find).with(1).and_return(double('DeadlineType', name: 'team_formation'))
        Sidekiq::Testing.fake!
        Sidekiq::RetrySet.new.clear
        Sidekiq::ScheduledSet.new.clear
        Sidekiq::Stats.new.reset
        Sidekiq::DeadSet.new.clear
        queue = Sidekiq::Queues['mailers']
        expect { assignment_form.add_to_delayed_queue }.to change { queue.size }.by(2)
      end
    end
  end

  describe '#assignment_itemnaire' do
    context 'when multiple active records of assignment_itemnaire are found for a given assignment_id, used_in_round, and topic_id' do
      it 'returns correct assignment itemnaire found by itemnaire type' do
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: 1).and_return(
          [assignment_itemnaire1, assignment_itemnaire2]
        )
        allow(assignment_itemnaire1).to receive(:itemnaire_id).and_return(1)
        allow(assignment_itemnaire2).to receive(:itemnaire_id).and_return(2)
        allow(Questionnaire).to receive(:find).with(1).and_return(itemnaire1)
        allow(Questionnaire).to receive(:find).with(2).and_return(itemnaire2)
        expect(assignment_form.assignment_itemnaire('ReviewQuestionnaire', nil, nil)).to eq(assignment_itemnaire1)
        expect(assignment_form.assignment_itemnaire('MetareviewQuestionnaire', nil, nil)).to eq(assignment_itemnaire2)
      end
    end

    context 'when active record for assignment_itemnaire is not found for a given assignment_id, used_in_round, and topic_id' do
      let(:new_assignment_itemnaire) { build(:assignment_itemnaire) }
      it 'returns new instance of assignment_itemnaire with default values' do
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: 1).and_return([])
        allow(AssignmentQuestionnaire).to receive(:where).with(user_id: anything, assignment_id: nil, itemnaire_id: nil).and_return([])
        allow(AssignmentQuestionnaire).to receive(:new).and_return(new_assignment_itemnaire)
        expect(assignment_form.assignment_itemnaire('ReviewQuestionnaire', nil, nil)).to eq(new_assignment_itemnaire)
      end
    end

    context 'when active record for assignment_itemnaire is not found for a given assignment_id amd duty_id' do
      let(:new_assignment_itemnaire) { build(:assignment_itemnaire) }
      it 'returns new instance of assignment_itemnaire with default values' do
        allow(assignment).to receive(:itemnaire_varies_by_duty).and_return(true)
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: 1, duty_id: anything).and_return([])
        allow(AssignmentQuestionnaire).to receive(:where).with(user_id: anything, assignment_id: nil, itemnaire_id: nil).and_return([])
        allow(AssignmentQuestionnaire).to receive(:new).and_return(new_assignment_itemnaire)
        expect(assignment_form.assignment_itemnaire('TeammateReviewQuestionnaire', nil, nil, 1)).to eq(new_assignment_itemnaire)
      end
    end

    context 'when active record for assignment_itemnaire is found for a given assignment_id, used_in_round, and topic_id, but associated itemnaire_id is nil' do
      # Based on the E1936 design this is not possible, but there could different models that create AQ with itemnaire_id
      let(:new_assignment_itemnaire) { build(:assignment_itemnaire) }
      it 'returns new instance of assignment_itemnaire with default values' do
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: 1).and_return(
          [assignment_itemnaire1]
        )
        allow(assignment_itemnaire1).to receive(:itemnaire_id).and_return(nil)
        allow(AssignmentQuestionnaire).to receive(:where).with(user_id: anything, assignment_id: nil, itemnaire_id: nil).and_return([])
        allow(AssignmentQuestionnaire).to receive(:new).and_return(new_assignment_itemnaire)
        expect(assignment_form.assignment_itemnaire('ReviewQuestionnaire', 1, 1)).to eq(new_assignment_itemnaire)
      end
    end

    context 'when active record for assignment_itemnaire is found for a given assignment_id amd duty_id' do
      let(:new_assignment_itemnaire) { build(:assignment_itemnaire) }
      it 'returns new instance of assignment_itemnaire with default values' do
        allow(assignment).to receive(:itemnaire_varies_by_duty).and_return(true)
        allow(Questionnaire).to receive(:find).with(1).and_return(itemnaire3)
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: 1, duty_id: 1).and_return([assignment_itemnaire2])
        allow(AssignmentQuestionnaire).to receive(:where).with(user_id: anything, assignment_id: nil, itemnaire_id: nil).and_return([])
        allow(AssignmentQuestionnaire).to receive(:new).and_return(new_assignment_itemnaire)
        expect(assignment_form.assignment_itemnaire('TeammateReviewQuestionnaire', nil, nil, 1)).to eq(assignment_itemnaire2)
      end
    end
  end

  describe '#itemnaire' do
    context 'when active record of itemnaire exists for a given assignment_itemnaire' do
      it 'returns correct itemnaire found by assignment_itemnaire' do
        allow(assignment_itemnaire1).to receive(:itemnaire_id).and_return(1)
        allow(Questionnaire).to receive(:find_by).with(id: 1).and_return(itemnaire1)
        expect(assignment_form.itemnaire(assignment_itemnaire1, anything)).to eq(itemnaire1)
      end
    end

    context 'when no active record of itemnaire exists for a given assignment_itemnaire' do
      it 'returns new instance of itemnaire object with id nil if itemnaire is not found by id' do
        allow(assignment_itemnaire1).to receive(:itemnaire_id).and_return(1)
        allow(Questionnaire).to receive(:find_by).with(id: 1).and_return(nil)
        expect(assignment_form.itemnaire(assignment_itemnaire1, 'ReviewQuestionnaire').id).to eq nil
      end

      it 'returns new instance of itemnaire object if assignment_itemnaire is nil' do
        expect(assignment_form.itemnaire(nil, 'ReviewQuestionnaire').id).to eq nil
      end
    end
  end

  describe '#find_min_from_now' do
    it 'returns the difference between current time and due date in minutes' do
      allow(DateTime).to receive(:now).and_return(DateTime.new(2017, 10, 7, 11, 11, 11).in_time_zone)
      due_at = Time.parse(DateTime.new(2017, 10, 7, 12, 12, 12).in_time_zone.to_s(:db))
      expect(assignment_form.find_min_from_now(due_at)).to eq(61)
    end
  end

  describe '#set_up_assignment_review' do
    it 'updates round_of_reviews (eg. from 1 to 2) and directory_path of current assignment' do
      allow(assignment).to receive(:set_up_defaults).and_return('OK!')
      allow(assignment).to receive(:find_due_dates).with('submission').and_return([double('DueDate')])
      allow(assignment).to receive(:find_due_dates).with('review').and_return([double('DueDate'), double('DueDate')])
      expect(assignment_form.instance_variable_get(:@assignment).directory_path).to eq('final_test')
    end
  end

  describe '#staggered_deadline' do
    context 'when current assignment.staggered_deadlines is nil' do
      it 'sets staggered_deadline attribute of current assignment to false' do
        assignment.staggered_deadline = nil
        expect(assignment_form.staggered_deadline).to be false
        expect(assignment_form.instance_variable_get(:@assignment).staggered_deadline).to be false
      end
    end

    context 'when current assignment.staggered_deadlines is not nil' do
      it 'does not change staggered_deadline attribute of current assignment' do
        assignment.staggered_deadline = true
        expect { assignment_form.staggered_deadline }.not_to change { assignment_form.instance_variable_get(:@assignment).staggered_deadline }
        expect(assignment_form.instance_variable_get(:@assignment).staggered_deadline).to be true
      end
    end
  end

  describe '#availability_flag' do
    context 'when current assignment.availability_flag is nil' do
      it 'sets availability_flag attribute of current assignment to false' do
        assignment.availability_flag = nil
        expect(assignment_form.availability_flag).to be false
        expect(assignment_form.instance_variable_get(:@assignment).availability_flag).to be false
      end
    end

    context 'when current assignment.availability_flag is not nil' do
      it 'does not change availability_flag attribute of current assignment' do
        assignment.availability_flag = true
        expect { assignment_form.availability_flag }.not_to change { assignment_form.instance_variable_get(:@assignment).availability_flag }
        expect(assignment_form.instance_variable_get(:@assignment).availability_flag).to be true
      end
    end
  end

  describe '#micro_task' do
    context 'when current assignment.microtask is nil' do
      it 'sets microtask attribute of current assignment to false' do
        assignment.microtask = nil
        expect(assignment_form.micro_task).to be false
        expect(assignment_form.instance_variable_get(:@assignment).microtask).to be false
      end
    end

    context 'when current assignment.microtask is not nil' do
      it 'does not change microtask attribute of current assignment' do
        assignment.microtask = true
        expect { assignment_form.micro_task }.not_to change { assignment_form.instance_variable_get(:@assignment).microtask }
        expect(assignment_form.instance_variable_get(:@assignment).microtask).to be true
      end
    end
  end

  describe '#reviews_visible_to_all' do
    context 'when current assignment.reviews_visible_to_all is nil' do
      it 'sets reviews_visible_to_all attribute of current assignment to false' do
        assignment.reviews_visible_to_all = nil
        expect(assignment_form.reviews_visible_to_all).to be false
        expect(assignment_form.instance_variable_get(:@assignment).reviews_visible_to_all).to be false
      end
    end

    context 'when current assignment.reviews_visible_to_all is not nil' do
      it 'does not change reviews_visible_to_all attribute of current assignment' do
        assignment.reviews_visible_to_all = true
        expect { assignment_form.micro_task }.not_to change { assignment_form.instance_variable_get(:@assignment).reviews_visible_to_all }
        expect(assignment_form.instance_variable_get(:@assignment).reviews_visible_to_all).to be true
      end
    end
  end

  describe '#review_assignment_strategy' do
    context 'when current assignment.review_assignment_strategy is nil' do
      it 'sets review_assignment_strategy attribute of current assignment to false' do
        assignment.review_assignment_strategy = nil
        expect(assignment_form.review_assignment_strategy).to eq('')
        expect(assignment_form.instance_variable_get(:@assignment).review_assignment_strategy).to eq('')
      end
    end

    context 'when current assignment.review_assignment_strategy is not nil' do
      it 'does not change review_assignment_strategy attribute of current assignment' do
        assignment.review_assignment_strategy = 'Instructor-Selected'
        expect { assignment_form.micro_task }.not_to change { assignment_form.instance_variable_get(:@assignment).review_assignment_strategy }
        expect(assignment_form.instance_variable_get(:@assignment).review_assignment_strategy).to eq('Instructor-Selected')
      end
    end
  end

  describe '#require_quiz' do
    context 'when current assignment is a calibrated assignment' do
      it 'sets require_quiz attribute of current assignment to false' do
        assignment.require_quiz = nil
        expect(assignment_form.require_quiz).to eq(0)
        expect(assignment_form.instance_variable_get(:@assignment).require_quiz).to be false
        expect(assignment_form.instance_variable_get(:@assignment).num_quiz_items).to eq(0)
      end
    end

    context 'when current assignment.require_quiz is not nil' do
      it 'does not change require_quiz attribute of current assignment' do
        assignment.require_quiz = true
        expect { assignment_form.require_quiz }.not_to change { assignment_form.instance_variable_get(:@assignment).require_quiz }
        expect(assignment_form.instance_variable_get(:@assignment).require_quiz).to be true
      end
    end
  end

  describe '.copy' do
    it 'copies the original assignment to a new one and returns the new assignment_id' do
      allow(Assignment).to receive(:find).with(1).and_return(assignment)
      allow_any_instance_of(AssignmentForm).to receive(:copy_assignment_itemnaire).with(any_args).and_return('OK!')
      allow(AssignmentDueDate).to receive(:copy).with(1, any_args).and_return('OK!')
      allow_any_instance_of(Assignment).to receive(:create_node).and_return('OK!')
      allow(SignUpTopic).to receive(:where).with(assignment_id: 1).and_return([build(:topic)])
      expect(AssignmentForm.copy(1, build(:instructor))).to eq(2)
    end
  end
end
