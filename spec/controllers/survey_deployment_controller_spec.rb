describe SurveyDeploymentController do
	describe '#pending_surveys' do
		context 'when session[:user] is invalid' do
			it 'redirects to root' do
				get :pending_surveys, @params
				expect(response).to redirect_to('/survey_deployment/pending_surveys')
			end
		end
	end
end