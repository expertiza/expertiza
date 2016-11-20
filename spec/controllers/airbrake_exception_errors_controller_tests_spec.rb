require 'rails_helper'
require 'pry'

describe TeamsController do
  # Airbrake-1804043391875943089
  describe '#new', type: :controller do
    it 'will set the default team parent as Assignment' do
      allow(Assignment).to receive(:find).with(1).and_return(instance_double('Assignment'))
      get :new
      # get :new, params: { id: 1 }, session: { team_type: nil }
      controller.params[:id] = 1
      controller.session[:team_type] = nil
      expect(response).to have_http_status(302)

      expect { Object.const_get(session[:team_type]).find(params[:id]) }.to raise_error(TypeError)
      expect { Object.const_get(session[:team_type] ||= 'Assignment').find(params[:id]) }.not_to raise_error(TypeError)
    end
  end
 
  # Airbrake-1807465099223895248
  describe '#delete', type: :controller do
    before(:each) do
      user = build(:instructor)
      stub_current_user(user, user.role.name, user.role)
      # to deal with redirect_to :back
      request.env['HTTP_REFERER'] = 'www.google.com'
    end

    it 'will redirect to previous page if the team cannot be found by id' do
      allow(Team).to receive(:find).with(any_args).and_return(nil)
      allow(Team).to receive(:find_by).with(any_args).and_return(nil)
      post :delete, id: 1
      expect(response).to redirect_to 'www.google.com'
    end

    it 'will delete the team if current team did not involve in any other reviews' do
      team = double('Team', id: 1, name: 'test team', parent_id: 1)
      signed_up_teams = [double('SignedUpTeam', topic_id: 1, is_waitlisted: true)]
      controller.session[:team_type] = 'Assignment'
      controller.session[:user] = double('User', id: 1)
    
      allow(Team).to receive(:find).with(any_args).and_return(team)
      allow(Team).to receive(:find_by).with(any_args).and_return(team)
      allow(Assignment).to receive(:find).with(any_args).and_return(double('Course'))
      allow(SignedUpTeam).to receive(:where).with(any_args).and_return(signed_up_teams)
      allow(SignedUpTeam).to receive_message_chain(:where, :first).with(any_args).and_return(signed_up_teams.first)
      allow(TeamsUser).to receive(:where).with(any_args).and_return(nil)
      allow(signed_up_teams).to receive(:destroy_all).and_return(true)
      allow(team).to receive(:destroy).and_return(true)

      post :delete, id: 1
      expect(response).to redirect_to 'www.google.com'
    end
  end
end

describe ImportFileController do
  # Airbrake-1774360945974838307
  describe '#importFile', type: :controller do
    it 'will catch the error info if the tempfile cannot be obtained from params[:file]' do
      controller.params = {
        id: 1,
        options: {"has_column_names" => "true", "handle_dups" => "ignore"},
        model: 'AssignmentTeam',
        file: nil
      }
      session = {
        assignment_id: 1
      }
      expect { controller.send(:importFile, session, controller.params) }.not_to raise_error
      expect(controller.send(:importFile, session, controller.params).inspect).to eq("[#<NoMethodError: undefined method `each_line' for nil:NilClass>]")
    end
  end
end

describe SubmittedContentController do 
  # Airbrake-1775143306379398644
  describe '#are_needed_authorizations_present?', type: :controller do
    it 'return false when the participant cannot find by id' do
        controller.params[:id] = 1
        allow(Participant).to receive(:find).with(any_args).and_return(nil)
        allow(Participant).to receive(:find_by).with(any_args).and_return(nil)
        expect(controller.send(:are_needed_authorizations_present?)).to eq(false)
    end

    it 'return false when the participant is reader or reviewer' do
        controller.params[:id] = 1
        participant = double('Participant',
                             can_submit: false,
                             can_review: true,
                             can_take_quiz: false)
        allow(Participant).to receive(:find).with(any_args).and_return(participant)
        allow(Participant).to receive(:find_by).with(any_args).and_return(participant)
        expect(controller.send(:are_needed_authorizations_present?)).to eq(false)
    end

    it 'return true when the participant is other role (participant or submitter)' do
        controller.params[:id] = 1
        participant = double('Participant',
                             can_submit: true,
                             can_review: true,
                             can_take_quiz: true)
        allow(Participant).to receive(:find).with(any_args).and_return(participant)
        allow(Participant).to receive(:find_by).with(any_args).and_return(participant)
        expect(controller.send(:are_needed_authorizations_present?)).to eq(true)
    end
  end
end

describe MenuItemsController do
  # Airbrake-1766139777878852159
  describe '#link', type: :controller do
    it "can handle the situation (redirect_to '/') when the session[:menu] is nil" do
      controller.params[:name] = "manage/courses"
      controller.session[:menu] = nil
      get :link
      expect(response).to redirect_to('/')
    end

    it 'redirect to node.url when the session[:menu] is not nil' do
      controller.params[:name] = "manage/courses"
      allow(controller.session[:menu]).to receive(:try).with(any_args).and_return(double('node', url: '/tree_display/goto_courses'))
      get :link
      expect(response).to redirect_to('/tree_display/goto_courses')
    end
  end
end

describe GradesController do
  # Airbrake-1784274870078015831
  describe '#redirect_when_disallowed', type: :controller do
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

describe ReviewMappingController do
  before(:each) do
    user = build(:instructor)
    stub_current_user(user, user.role.name, user.role)
    # to deal with redirect_to :back
    request.env['HTTP_REFERER'] = 'www.google.com'
  end
  # Airbrake-1800902813969550245
  describe '#delete_reviewer' do
    it 'will stay in current page if review_response_map_id is nil' do
      allow(ReviewResponseMap).to receive(:find).with(any_args).and_return(nil)
      allow(ReviewResponseMap).to receive(:find_by).with(any_args).and_return(nil)
      post :delete_reviewer, id: 1
      expect(flash[:error]).to eq('This review has already been done. It cannot been deleted.')
      expect(response).to redirect_to 'www.google.com'
    end

    it 'will delete reviewer if current reviewer did not do any reviews' do
      review_response_map = double('ReviewResponseMap', 
                                  id: 1,
                                  reviewee: double('Participant', name: 'stu1'),
                                  reviewer: double('Participant', name: 'stu2'))
      allow(ReviewResponseMap).to receive(:find).with(any_args).and_return(review_response_map)
      allow(ReviewResponseMap).to receive(:find_by).with(any_args).and_return(review_response_map)
      allow(Response).to receive(:exists?).with(any_args).and_return(false)
      allow(review_response_map).to receive(:destroy).and_return(true)
      post :delete_reviewer, id: 1
      expect(flash[:success]).to eq("The review mapping for \"stu1\" and \"stu2\" has been deleted.")
      expect(response).to redirect_to 'www.google.com'
    end
  end
end