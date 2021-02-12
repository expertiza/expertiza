describe ResponseController do
	context 'when session[:user] is invalid' do
		it 'redirects to root' do
			session[:user] = false
			get :pending_surveys, @params
			expect(response).to redirect_to('/')
		end
	end
end