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
  # Airbrake-1784274870078015831
  describe '#redirect_when_disallowed' do
    before(:each) do
      controller.instance_variable_set(:@participant, double('Participant', 
                                                              team: build(:assignment_team),
                                                              assignment: double('Assignment', id: 1, max_team_size: 1)))
      # allow(@participant).to receive(:assignment).with(no_args).and_return(build(:assignment, id: 1, max_team_size: 2))
      # allow(@participant).to receive(:team).with(no_args).and_return(build(:assignment_team))
      controller.session[:user] = double('User', id: 1)
    end

    it 'will return true when reviewer is nil' do
      allow(AssignmentParticipant).to receive_message_chain(:where, :first).with(any_args).and_return(nil)
      expect(controller.send(:redirect_when_disallowed)).to eq(true)
    end

    it 'will return false when reviewer is current_user' do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('User', id: 1))
      allow(AssignmentParticipant).to receive_message_chain(:where, :first).with(any_args).and_return(double('User', user_id: 1))
      expect(controller.send(:redirect_when_disallowed)).to eq(false)
    end
  end
end