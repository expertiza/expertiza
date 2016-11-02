require 'rails_helper'
require 'pry'

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

describe ImportFileController do
	describe 'Airbrake-1774360945974838307', type: :controller do
		it 'will catch the error info if the tempfile cannot be obtained from params[:file]' do
      controller.params = {
        id: 1,
        options: {"has_column_names"=>"true", "handle_dups"=>"ignore"},
        model: 'AssignmentTeam',
        file: nil
      }
      session = {
        assignment_id: 1
      }
      ifc = ImportFileController.new
      expect{ifc.send(:importFile, session, controller.params)}.not_to raise_error
      expect(ifc.send(:importFile, session, controller.params).inspect).to eq("[#<NoMethodError: undefined method `each_line' for nil:NilClass>]")
    end
  end
end