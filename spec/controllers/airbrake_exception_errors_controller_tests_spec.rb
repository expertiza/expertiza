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

describe GradesController do
  describe 'Airbrake-1784274870078015831' do
    it 'will redirect when current user is not the reviewer' do
      allow(@participant).to receive_message_chain(:assignment, :max_team_size).with(no_args).and_return(2)
      allow(@participant).to receive_message_chain(:assignment, :id).with(no_args).and_return(1)
      allow(@participant).to receive(:team).and_return(build(:assignment_team))
      # @request.session['user'] = build(:student, id: 1)
      current_user = build(:student, id: 1)
      current_role = current_user.role
      stub_current_user(current_user, 'Student', current_role)
      allow(AssignmentParticipant).to receive_message_chain(:where, :first).with(1, 1).and_return(nil)
      gc = GradesController.new
      expect(gc.send(:redirect_when_disallowed)).to eq(true)
    end
  end
end