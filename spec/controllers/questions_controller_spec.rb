describe QuestionsController do
 let(:instructor) { build(:instructor, id: 6) }
 let!(:question) { create(:question, id: 1) }
 before(:each) do
    stub_current_user(instructor, instructor.role.name, instructor.role)
  end
  describe '#destroy' do
    context 'success' do
      it 'deletes the question' do
	      params = {id: 1}
        post :destroy,params
        expect(flash[:success]).to eq("You have successfully deleted the question!")
      end
    end
  end
end
