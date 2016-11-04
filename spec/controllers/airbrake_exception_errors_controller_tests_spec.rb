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

describe SignUpSheetController do
  before(:each) do
    allow_any_instance_of(ApplicationController).to receive(:[]).with(:user).and_return(build(:student, id: 1))
  end
  describe 'Airbrake-1781398948366778395', type: :controller do
    it 'can handle the situation when the @participant is nil' do
      # session[:user] = build(:student, id: 1)
      
      controller.params[:assignment_id] = 1
      suc = SignUpSheetController.new
      allow(Participant).to receive_message_chain(:where, :first).with(1, 1).and_return(nil)
      expect(suc.send(:are_needed_authorizations_present?)).to eq(true)
    end
  end
end

describe MenuItemsController do
  describe 'Airbrake-1766139777878852159', type: :controller do
    it "can handle the situation (redirect_to '/') when the session[:menu] is nil"do
      controller.params[:name] = "manage/courses"
      controller.session[:menu] = nil
      get :link
      expect(response).to redirect_to('/')
    end

    it 'redirect to node.url when the session[:menu] is not nil'do
      controller.params[:name] = "manage/courses"
      allow(controller.session[:menu]).to receive(:try).with(any_args).and_return(double('node', url: '/tree_display/goto_courses'))
      get :link
      expect(response).to redirect_to('/tree_display/goto_courses')
    end
  end
end