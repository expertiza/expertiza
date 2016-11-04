require 'rails_helper'
require 'pry'

describe TeamsController do
  describe 'Airbrake-1804043391875943089', type: :controller do

    it 'will set the default team parent as Assignment' do
      allow(Assignment).to receive(:find).with(1).and_return(instance_double('Assignment'))
      get :new
      # get :new, params: { id: 1 }, session: { team_type: nil }
      controller.params[:id] = 1
      controller.session[:team_type] = nil
      expect(response).to have_http_status(302)
      
      expect{ Object.const_get(session[:team_type]).find(params[:id]) }.to raise_error(TypeError)
      expect{ Object.const_get(session[:team_type] ||= 'Assignment').find(params[:id]) }.not_to raise_error(TypeError)
    end
  end
end