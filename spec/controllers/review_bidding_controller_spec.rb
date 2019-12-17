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

  # before(:each) do
  
  # end

  # describe '#set_priority' do
  # end
  
  # describe '#review_bid' do 
  # end

  # describe '#get_quartiles' do
  # end

end