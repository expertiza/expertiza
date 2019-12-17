require "rails_helper"
require 'rspec/rails'
describe ReviewBiddingController do
  let(:assignment) { build(:assignment, id: 1, instructor_id: 6, due_dates: [due_date], microtask: true, staggered_deadline: true) }
  let(:instructor) { build(:instructor, id: 6) }

  let(:student) { build(:student, id: 8) }
  let(:participant) { build(:participant, id: 1, user_id: 6, assignment: assignment) }
  let(:topic) { build(:topic, id: 1) }
  let(:signed_up_team) { build(:signed_up_team, team: team, topic: topic) }
  let(:signed_up_team2) { build(:signed_up_team, team_id: 2, is_waitlisted: true) }
  let(:team) { build(:assignment_team, id: 1, assignment: assignment) }
  let(:due_date) { build(:assignment_due_date, deadline_type_id: 1) }
  let(:due_date2) { build(:assignment_due_date, deadline_type_id: 2) }
  # let(:bid) { Bid.new(topic_id: 1, priority: 1) }
  let(:bid) { ReviewBid.new(sign_up_topic_id: 1, priority: 1) }

  before(:each) do
    allow(Assignment).to receive(:find).with('1').and_return(assignment)
    allow(Assignment).to receive(:find).with(1).and_return(assignment)
    stub_current_user(instructor, instructor.role.name, instructor.role)
    allow(SignUpTopic).to receive(:find).with('1').and_return(topic)
    allow(Participant).to receive(:find_by).with(id: '1').and_return(participant)
    allow(Participant).to receive(:find_by).with(parent_id: 1, user_id: 8).and_return(participant)
    allow(AssignmentParticipant).to receive(:find).with('1').and_return(participant)
    allow(AssignmentParticipant).to receive(:find).with(1).and_return(participant)
  end

  describe '#set_priority' do
    include RSpec::Rails::ControllerExampleGroup
    it 'sets priority of review bidding topic' do
      allow(participant).to receive(:team).and_return(team)
      allow(Bid).to receive(:where).with(sign_up_topic_id:1).and_return([bid])
      allow(Bid).to receive(:where).with(participant_id: 1).and_return([bid])
      allow(Bid).to receive_message_chain(:where, :map).with(participant_id: 1).with(no_args).and_return([1])
      # allow(Bid).to receive(:where).with(topic_id: '1', team_id: 1).and_return([bid])
      allow_any_instance_of(Array).to receive(:update_all).with(priority: 1).and_return([bid])
      params = {
          participant_id: 1,
          assignment_id: 1,
          topic: ['1']
      }
      post :set_priority, params
      expect(response)
    end
  end
   describe '#review_bid' do
    before(:each) do
      allow(SignUpTopic).to receive(:find_slots_filled).with(1).and_return([topic])
       #allow(SignUpTopic).to receive(:find_slots_waitlisted).with(1).and_return([])
       allow(SignUpTopic).to receive(:where).with(assignment_id: 1, private_to: nil).and_return([topic])
       allow(participant).to receive(:team).and_return(participant)
     end

     context 'when assignment is bidded' do
       it 'renders review_bid' do
  #       assignment.is_intelligent = true
         allow(Bid).to receive_message_chain(:where, :order).with(team_id: 1).with(:priority).and_return([double('Bid', topic_id: 1)])
         allow(SignUpTopic).to receive(:find_by).with(id: 1).and_return(topic)
         params = {id: 1}
         session = {user: instructor}
         get :review_bid, params, session
         expect(controller.instance_variable_get(:@bids).size).to eq(1)
         expect(controller.instance_variable_get(:@sign_up_topics)).to be_empty
         expect(response).to render_template('sign_up_sheet/review_bid')
       end
     end

end
end