describe Ta do
  let!(:ta) { create(:teaching_assistant, id: 999) }
  let(:course1) { build(:course, id: 1, name: 'ECE517') }
  let(:course2) { build(:course, id: 2, name: 'ECE506') }
  describe '#teaching_assistant?' do
    it 'returns true for a teaching assistant' do
      expect(ta.teaching_assistant?).to be_truthy
    end
  end
  describe '#assign_courses_to_assignment' do
    it 'returns associated courses' do
      allow(TaMapping).to receive(:get_courses).with(999).and_return([course1, course2])
      expect(ta.assign_courses_to_assignment).to eq([course1, course2])
    end
  end
  describe '#courses_assisted_with' do
    it 'returns a map of courses' do
    	ta_mapping = TaMapping.new
    	allow(ta_mapping).to receive(:course_id).and_return(1)
      allow(TaMapping).to receive(:where).with(ta_id: 999).and_return([ta_mapping])
      allow(Course).to receive(:find).with(1).and_return(course1)
      expect(ta.courses_assisted_with).eq([course1])
    end
  end
end