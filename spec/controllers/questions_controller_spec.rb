describe QuestionsController do
  describe '#destroy' do
    context 'success' do
      it 'deletes the question' do
	      params = {id: 1}
        post :destroy,params
        expect(flash[:success]).to eq("You have successfully deleted the question!")
      end
    end
  end