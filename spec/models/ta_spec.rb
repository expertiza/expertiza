describe Ta do
  let!(:ta) { create(:teaching_assistant, id: 999) }
  describe 'teaching_assistant?' do
    it 'returns true for a teaching assistant' do
      expect(ta.teaching_assistant?).to be_truthy
    end
  end


end