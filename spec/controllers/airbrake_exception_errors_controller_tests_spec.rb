require 'rails_helper'

describe TeamsController do
  describe 'Airbrake-1804043391875943089', type: :controller do
    it 'will set the default team parent as Assignment' do
      controller.params[:id] = 1
      controller.session[:team_type] = nil
      # assignment = create(:assignment)
      get :new
      expect(response.status).to eq(302)
    end
  end
end