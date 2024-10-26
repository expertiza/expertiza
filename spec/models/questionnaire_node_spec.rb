describe QuestionnaireNode do
  let(:itemnaire) { build(:itemnaire) }
  let(:itemnaire2) { build(:itemnaire) }
  let(:itemnaire3) { build(:itemnaire) }
  let(:itemnaire_node) { build(:itemnaire_node) }
  let(:teaching_assistant) { build(:teaching_assistant) }
  let(:student) { build(:student) }
  let(:assignment) { build(:assignment, id: 1, name: 'Assignment') }
  it { should belong_to(:itemnaire) }
  it { should belong_to(:node_object) }
  describe '#table' do
    it 'returns the name of the table' do
      expect(QuestionnaireNode.table).to eq('itemnaires')
    end
  end
  describe '#is_leaf' do
    it 'returns whether the node is a leaf' do
      expect(itemnaire_node.is_leaf).to eq(true)
    end
  end
  describe '#get_modified_date' do
    it 'returns when the itemnaire was last changed' do
      allow(Questionnaire).to receive(:find_by).with(id: 0).and_return(itemnaire)
      allow(itemnaire).to receive(:updated_at).and_return('2011-11-11 11:11:11')
      expect(itemnaire_node.get_modified_date).to eq('2011-11-11 11:11:11')
    end
  end
  describe '#get_creation_date' do
    it 'returns when the itemnaire was created' do
      allow(Questionnaire).to receive(:find_by).with(id: 0).and_return(itemnaire)
      allow(itemnaire).to receive(:created_at).and_return('2011-11-11 11:11:11')
      expect(itemnaire_node.get_creation_date).to eq('2011-11-11 11:11:11')
    end
  end
  describe '#get_private' do
    it 'returns whether the associated itemnaire is private' do
      allow(Questionnaire).to receive(:find_by).with(id: 0).and_return(itemnaire)
      allow(itemnaire).to receive(:private).and_return(true)
      expect(itemnaire_node.get_private).to eq(true)
    end
  end
  describe '#get_instructor_id' do
    it 'returns whether the associated instructor id with the itemnaire' do
      allow(Questionnaire).to receive(:find_by).with(id: 0).and_return(itemnaire)
      allow(itemnaire).to receive(:instructor_id).and_return(1)
      expect(itemnaire_node.get_instructor_id).to eq(1)
    end
  end
  describe '#get_name' do
    it 'returns itemnaire name' do
      allow(Questionnaire).to receive(:find_by).with(id: 0).and_return(itemnaire)
      allow(itemnaire).to receive(:name).and_return('CSC 517 Assignment 1')
      expect(itemnaire_node.get_name).to eq('CSC 517 Assignment 1')
    end
  end
  describe '#get' do
    context 'when the user is a teaching assistant' do
      it 'returns the itemnaires associated with the TA' do
        condition = '(itemnaires.private = 0 or itemnaires.instructor_id in (?))'
        values = [1]
        sortvar = 'name'
        sortorder = 'ASC'
        arr = [itemnaire, itemnaire2, itemnaire3]
        allow(User).to receive(:find).with(1).and_return(teaching_assistant)
        allow(Questionnaire).to receive(:where).with([condition, values]).and_return(arr)
        allow(QuestionnaireNode).to receive(:includes).with(:itemnaire).and_return(Questionnaire)
        allow(Ta).to receive(:get_mapped_instructor_ids).with(1).and_return([1])
        allow(arr).to receive(:order).with("itemnaires.#{sortvar} #{sortorder}").and_return(arr)
        expect(QuestionnaireNode.get(sortvar = nil, sortorder = nil, user_id = 1, show = nil, parent_id = nil, _search = nil)).to eq(arr)
      end
    end
    context 'when the user is not a teaching assistant' do
      it 'returns the itemnaires associated with the student' do
        condition = '(itemnaires.private = 0 or itemnaires.instructor_id = ?)'
        values = 1
        sortvar = 'name'
        sortorder = 'ASC'
        arr = [itemnaire, itemnaire2, itemnaire3]
        allow(User).to receive(:find).with(1).and_return(student)
        allow(Questionnaire).to receive(:where).with([condition, values]).and_return(arr)
        allow(QuestionnaireNode).to receive(:includes).with(:itemnaire).and_return(Questionnaire)
        allow(Ta).to receive(:get_mapped_instructor_ids).with(1).and_return([1])
        allow(arr).to receive(:order).with("itemnaires.#{sortvar} #{sortorder}").and_return(arr)
        expect(QuestionnaireNode.get(sortvar = nil, sortorder = nil, user_id = 1, show = nil, parent_id = nil, _search = nil)).to eq(arr)
      end
    end
    context 'when the user is not a teaching assistant and show is enabled' do
      it 'returns the itemnaires associated with the student' do
        condition = 'itemnaires.instructor_id = ?'
        values = 1
        sortvar = 'name'
        sortorder = 'ASC'
        arr = [itemnaire, itemnaire2, itemnaire3]
        allow(User).to receive(:find).with(1).and_return(student)
        allow(Questionnaire).to receive(:where).with([condition, values]).and_return(arr)
        allow(QuestionnaireNode).to receive(:includes).with(:itemnaire).and_return(Questionnaire)
        allow(Ta).to receive(:get_mapped_instructor_ids).with(1).and_return([1])
        allow(arr).to receive(:order).with("itemnaires.#{sortvar} #{sortorder}").and_return(arr)
        expect(QuestionnaireNode.get(sortvar = nil, sortorder = nil, user_id = 1, show = true, parent_id = nil, _search = nil)).to eq(arr)
      end
    end
    context 'when the user is a teaching assistant and show is enabled and parent_id is enabled' do
      it 'returns the itemnaires associated with the student' do
        conditions = 'itemnaires.instructor_id = ?'
        name = 'AssignmentQuestionnaire'
        conditions += " and itemnaires.type = \"#{name}\""
        values = 1
        sortvar = 'name'
        sortorder = 'ASC'
        arr = [itemnaire, itemnaire2, itemnaire3]
        allow(TreeFolder).to receive(:find).with(2).and_return(assignment)
        allow(User).to receive(:find).with(1).and_return(student)
        allow(Questionnaire).to receive(:where).with([conditions, values]).and_return(arr)
        allow(QuestionnaireNode).to receive(:includes).with(:itemnaire).and_return(Questionnaire)
        allow(Ta).to receive(:get_mapped_instructor_ids).with(1).and_return([1])
        allow(arr).to receive(:order).with("itemnaires.#{sortvar} #{sortorder}").and_return(arr)
        expect(QuestionnaireNode.get(sortvar = nil, sortorder = nil, user_id = 1, show = true, parent_id = 2, _search = nil)).to eq(arr)
      end
    end
  end
end
