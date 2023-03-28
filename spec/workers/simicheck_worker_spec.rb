require 'rails_helper' 
require 'sidekiq/testing'
Sidekiq::Testing.fake!

describe SimicheckWorker do
  let(:assignment) { build(:assignment, id: 1, name: 'no assignment', participants: [participant], teams: [team]) }
  let(:participant) { build(:participant, id: 1, parent_id: 1, user: user) }
  let(:team) { build(:assignment_team, id: 1, name: 'no team', users: [user], parent_id: 1) }
  let(:user) { build(:student, id: 1, email: 'psingh22@ncsu.edu') }

  before(:each) do
    allow(Assignment).to receive(:find).with(1).and_return(assignment)
    allow(Participant).to receive(:where).with(parent_id: 1).and_return([participant])
    allow(User).to receive(:where).with(email: "psingh22@ncsu.edu").and_return([user])
    allow(Participant).to receive(:where).with(user_id: 1, parent_id: 1).and_return([participant])
  end

  it "should increase the size of queue by 1 when SimicheckWorker is used" do
    SimicheckWorker.perform_in(42.minutes, 1, 'review', '2022-12-04 00:00:01')
    queue = Sidekiq::Queues['jobs']
    expect(queue.size).to eq(1)
    queue.clear
  end
end