# https://smartlogic.io/blog/how-to-test-a-sidekiq-worker/
require 'rails_helper' 
require 'sidekiq/testing'
Sidekiq::Testing.fake!

describe MailWorker do
  let(:assignment) { build(:assignment, id: 1, name: 'no assignment', participants: [participant], teams: [team]) }
  let(:participant) { build(:participant, id: 1, parent_id: 1, user: user) }
  let(:team) { build(:assignment_team, id: 1, name: 'no team', users: [user], parent_id: 1) }
  let(:user) { build(:student, id: 1, email: 'psingh22@ncsu.edu') }
  let(:review_response_map) { build(:review_response_map, id: 1, reviewed_object_id: 1, reviewer_id: 1, reviewee_id: 1) }

  before(:each) do
    allow(Assignment).to receive(:find).with(1).and_return(assignment)
    allow(Participant).to receive(:where).with(parent_id: 1).and_return([participant])
    allow(User).to receive(:where).with(email: "psingh22@ncsu.edu").and_return([user])
    allow(Participant).to receive(:where).with(user_id: 1, parent_id: 1).and_return([participant])
    allow(ResponseMap).to receive(:where).with(reviewed_object_id: 1).and_return([review_response_map])
    allow(ResponseMap).to receive(:where).with(id: 1).and_return([review_response_map])
  end

  it "should increase the size of queue by 1 when MailWorker is used" do
    MailWorker.perform_in(42.minutes, 1, "review", "2021-10-27 00:00:01")
    queue = Sidekiq::Queues["jobs"]
    expect(queue.size).to eq(1)
    queue.clear
  end

  describe 'Tests mailer with sidekiq' do 
    it "1. should have sent welcome email after user was created" do
      Sidekiq::Testing.inline!  # executes the jobs immediately when they are placed in the queue
      email = Mailer.sync_message(
        to: 'tluo@ncsu.edu',
        subject: 'Your Expertiza account and password has been created',
        body: {
          obj_name: 'assignment',
          type: 'submission',
          location: '1',
          first_name: 'User',
          partial_name: 'update'
        }
      ).deliver_now
      email = Mailer.deliveries.first
      expect(email.from[0]).to eq('expertiza.debugging@gmail.com')
      expect(email.to[0]).to eq('expertiza.debugging@gmail.com')
      expect(email.subject).to eq("Your Expertiza account and password has been created")
    end

    it "2. should send email to required email address with proper content" do
      Sidekiq::Testing.inline!

      # MailWorker contains one public method, which is an instance method not class method
      mailworker = MailWorker.new
      # perform(assignment_id, deadline_type, due_at)
      mailworker.perform(1, 'metareview', '2022-12-31 00:00:01')
      email = ActionMailer::Base.deliveries.first
      expect(email.from[0]).to eq('expertiza.debugging@gmail.com')
      expect(email.bcc[0]).to eq(user.email)
      expect(email.subject).to eq('Message regarding teammate review for assignment no assignment')
    end

    it "3. should not return email if deadline is drop_outstanding_reviews" do
      Sidekiq::Testing.inline!
      Mailer.deliveries.clear
      worker = MailWorker.new
      worker.perform(1, 'drop_outstanding_reviews', '2018-12-31 00:00:01')
      expect(Mailer.deliveries.size).to eq(0)
    end

    it "4. should increase the size of queue by 1 when MailWorker is used" do
      Sidekiq::Testing.inline!
      Mailer.deliveries.clear
      worker = MailWorker.new
      worker.perform(1, 'review', '2022-12-05 00:00:01')
      expect(Mailer.deliveries.size).to eq(1)
    end

  end
end
