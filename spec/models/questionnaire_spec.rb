describe Questionnaire do
  let(:itemnaire) { Questionnaire.new name: 'abc', private: 0, min_item_score: 0, max_item_score: 10, instructor_id: 1234 }
  let(:itemnaire1) { Questionnaire.new name: 'xyz', private: 0, max_item_score: 20, instructor_id: 1234 }
  let(:assignment) { build(:assignment, id: 1, name: 'no assignment', participants: [participant], teams: [team]) }
  let(:team) { build(:assignment_team, id: 1, name: 'no team') }
  let(:participant) { build(:participant, id: 1) }
  let(:assignment_itemnaire1) { build(:assignment_itemnaire, id: 1, assignment_id: 1, itemnaire_id: 2) }
  let(:itemnaire2) { build(:itemnaire, id: 2, type: 'MetareviewQuestionnaire') }
  let!(:checkbox1) { Checkbox.create(id: 3, type: 'Checkbox', seq: 2.0, txt: 'test txt2', weight: 11) }
  let(:item1) { create(:item, itemnaire: itemnaire2, weight: 1, id: 1) }
  let(:item2) { create(:item, itemnaire: itemnaire2, weight: 2, id: 2) }
  let(:itemnaire_node) { build(:itemnaire_node) }
  describe '#name' do
    it 'returns the name of the Questionnaire' do
      expect(itemnaire.name).to eq('abc')
    end

    it 'Validate presence of name which cannot be blank' do
      itemnaire.name = '  '
      expect(itemnaire).not_to be_valid
    end
  end

  describe '#instructor_id' do
    it 'returns the instructor id' do
      expect(itemnaire.instructor_id).to eq(1234)
    end
  end

  describe '#maximum_score' do
    it 'validate maximum score' do
      expect(itemnaire.max_item_score).to eq(10)
    end

    it 'validate maximum score is integer' do
      expect(itemnaire.max_item_score).to eq(10)
      itemnaire.max_item_score = 'a'
      expect(itemnaire).not_to be_valid
    end

    it 'validate maximum should be positive' do
      expect(itemnaire.max_item_score).to eq(10)
      itemnaire.max_item_score = -10
      expect(itemnaire).not_to be_valid
      itemnaire.max_item_score = 10
    end
  end

  describe '#minimum_score' do
    it 'validate minimum score' do
      itemnaire.min_item_score = 5
      expect(itemnaire.min_item_score).to eq(5)
    end

    it 'validate default minimum score' do
      expect(itemnaire1.min_item_score).to eq(0)
    end

    it 'validate minimum should be smaller than maximum' do
      expect(itemnaire.min_item_score).to eq(0)
      itemnaire.min_item_score = 10
      expect(itemnaire).not_to be_valid
      itemnaire.min_item_score = 0
    end
  end

  it 'allowing calls from copy_itemnaire_details' do
    allow(Questionnaire).to receive(:find).with('1').and_return(itemnaire)
    allow(Question).to receive(:where).with(itemnaire_id: '1').and_return([Question])
    item_advice = build(:item_advice)
    allow(QuestionAdvice).to receive(:where).with(item_id: 1).and_return([item_advice])
  end

  describe '#get_weighted_score' do
    context 'when there are no rounds' do
      it 'just uses the symbol with no round' do
        allow(AssignmentQuestionnaire).to receive(:find_by).with(assignment_id: 1, itemnaire_id: 2).and_return(assignment_itemnaire1)
        allow(assignment_itemnaire1).to receive(:used_in_round).and_return(nil)
        allow(itemnaire2).to receive(:symbol).and_return('a')
        allow(itemnaire2).to receive(:assignment_itemnaires).and_return(assignment_itemnaire1)
        allow(assignment_itemnaire1).to receive(:find_by).with(assignment_id: 1).and_return(assignment_itemnaire1)
        scores = { 'a' => { scores: { avg: 100 } } }
        expect(itemnaire2.get_weighted_score(assignment, scores)).to eq(100)
      end
    end
  end

  describe '#true_false_items?' do
    context 'when there are no true/false items' do
      it 'returns false' do
        allow(itemnaire2).to receive(:items).and_return([item1, item2])
        expect(itemnaire2.true_false_items?).to eq(false)
      end
    end
    context 'when there is a true/false item' do
      it 'returns true' do
        allow(itemnaire2).to receive(:items).and_return([item1, item2, checkbox1])
        expect(itemnaire2.true_false_items?).to eq(true)
      end
    end
    context 'when there are no associated items' do
      it 'returns false' do
        allow(itemnaire2).to receive(:items).and_return([])
        expect(itemnaire2.true_false_items?).to eq(false)
      end
    end
  end

  describe '#delete' do
    it 'deletes all dependent objects and itself' do
      allow(itemnaire2).to receive(:items).and_return([item1, item2])
      allow(itemnaire2).to receive(:assignments).and_return([])
      allow(QuestionnaireNode).to receive(:find_by).with(node_object_id: 2).and_return(itemnaire_node)
      expect(itemnaire2.delete).to be_truthy
    end
    context 'when there are associated assignments' do
      it 'raises an error' do
        allow(itemnaire2).to receive(:items).and_return([item1, item2])
        allow(itemnaire2).to receive(:assignments).and_return([assignment])
        allow(QuestionnaireNode).to receive(:find_by).with(node_object_id: 2).and_return(itemnaire_node)
        expect { itemnaire2.delete }.to raise_error(RuntimeError)
      end
    end
  end

  describe '#max_possible_score' do
    it 'returns the highest possible score for the itemnaire' do
      items = [item1, item2, checkbox1]
      allow(Questionnaire).to receive(:joins).with('INNER JOIN items ON items.itemnaire_id = itemnaires.id').and_return(items)
      allow(items).to receive(:select).with('SUM(items.weight) * itemnaires.max_item_score as max_score').and_return(items)
      allow(items).to receive(:where).with('itemnaires.id = ?', 2).and_return(items)
      allow(item1).to receive(:max_score).and_return(100)
      expect(itemnaire2.max_possible_score).to eq(100)
    end
  end
end
