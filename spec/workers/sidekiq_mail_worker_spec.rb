describe MailWorker do
  let(:assignment) { build(:assignment, id: 1, name: 'no assignment', participants: [participant], teams: [team]) }
  let(:participant) { build(:participant, id: 1, parent_id: 1, user: user) }
  let(:team) { build(:assignment_team, id: 1, name: 'no team', users: [user], parent_id: 1) }
  let(:user) { build(:student, id: 1, email: 'psingh22@ncsu.edu') }
  let(:review_response_map) { build(:review_response_map, id: 1, reviewed_object_id: 1, reviewer_id: 1, reviewee_id: 1) }
  # let(:topic) { build(:topic, id: 1, topic_name: 'New Topic') }
  # let(:signedupteam) { build(:signed_up_team, team_id: team.id, topic: topic) }

  before(:each) do
    allow(Assignment).to receive(:find).with('1').and_return(assignment)
    allow(Participant).to receive(:where).with(parent_id: '1').and_return([participant])
    allow(User).to receive(:where).with(email: "psingh22@ncsu.edu").and_return([user])
    allow(Participant).to receive(:where).with(user_id: '1', parent_id: '1').and_return([participant])
    allow(ResponseMap).to receive(:where).with(reviewed_object_id: '1').and_return([review_response_map])
    allow(ResponseMap).to receive(:where).with(id: 1).and_return([review_response_map])
    # allow(SignedUpTeam).to receive(:where).with(team_id: 1).and_return([signedupteam])
  end

  describe 'Tests mailer with sidekiq' do
    it "should have sent welcome email after user was created" do
      # puts Mailer.deliveries
      Sidekiq::Testing.inline!
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
      expect(email.from[0]).to eq("expertiza.debugging@gmail.com")
      expect(email.to[0]).to eq("expertiza.debugging@gmail.com")
      expect(email.subject).to eq("Your Expertiza account and password has been created")
    end

    it 'should send reminder email to required email address with proper content' do
      Sidekiq::Testing.inline!
      Mailer.deliveries.clear
      worker = MailWorker.new
      worker.perform("1", "metareview", "2018-12-31 00:00:01")
      expect(Mailer.deliveries.size).to eq(1)
      email = Mailer.deliveries.first
      expect(email.from[0]).to eq("expertiza.debugging@gmail.com")
      expect(email.bcc[0]).to eq("psingh22@ncsu.edu")
      expect(email.subject).to eq("Message regarding teammate review for assignment no assignment")
      expect(email.body).to eq("This is a reminder to complete teammate review for assignment no assignment.\nPlease follow the link: http://expertiza.ncsu.edu/student_task/view?id=1\nDeadline is 2018-12-31 00:00:01. If you have already done the teammate review, then please ignore this mail.")
    end

    it 'should expect the queue size of one' do
      Sidekiq::Testing.fake!
      MailWorker.perform_in(3.hours, '1', 'metareview', '2018-12-31 00:00:01')
      queue = Sidekiq::Queues['mailers']
      expect(queue.size).to eq(1)
    end

    # Commented out because dependency PlagiarismCheckerHelper contains an uninitialized variable request
    # it "should not return email if deadline is compare_files_with_simicheck" do
    #   Sidekiq::Testing.inline!
    #   Mailer.deliveries.clear
    #   worker = MailWorker.new

    # Calls PlagiarismCheckerHelper.run method
    #   worker.perform('1', 'compare_files_with_simicheck', '2018-12-31 00:00:01')
    #   expect(Mailer.deliveries.size).to eq(0)
    # end

    it "should not return email if deadline is drop_outstanding_reviews" do
      Sidekiq::Testing.inline!
      Mailer.deliveries.clear
      worker = MailWorker.new
      worker.perform("1", "drop_outstanding_reviews", "2018-12-31 00:00:01")
      expect(Mailer.deliveries.size).to eq(0)
    end
  end
end
