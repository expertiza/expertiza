describe MailWorker do
  let(:assignment) { build(:assignment, id: 1, name: 'no assignment', participants: [participant], teams: [team]) }
  let(:participant) { build(:participant, id: 1, parent_id: 1, user: user) }
  let(:team) { build(:assignment_team, id: 1, name: 'no team', users: [user], parent_id: 1) }
  let(:user) { build(:student, id: 1, email: 'psingh22@ncsu.edu') }

  before(:each) do
    allow(Assignment).to receive(:find).with('1').and_return(assignment)
    allow(Participant).to receive(:where).with(parent_id: '1').and_return([participant])
    allow(User).to receive(:where).with(email: "psingh22@ncsu.edu").and_return([user])
    allow(Participant).to receive(:where).with(user_id: '1', parent_id: '1').and_return([participant])
  end

  describe 'Tests mailer with sidekiq' do
    it "should have sent welcome email after user was created" do
      email = ActionMailer::Base.deliveries.first
      expect(email.from[0]).to eq("expertiza.development@gmail.com")
      expect(email.to[0]).to eq("expertiza.development@gmail.com")
      expect(email.subject).to eq("Your Expertiza account and password has been created")
    end

    it 'should send reminder email to required email address with proper content' do
      Sidekiq::Testing.inline!
      ActionMailer::Base.deliveries.clear
      worker = MailWorker.new
      worker.perform("1", "metareview", "2018-12-31 00:00:01")
      expect(ActionMailer::Base.deliveries.size).to eq(1)
      email = ActionMailer::Base.deliveries.first
      expect(email.from[0]).to eq("expertiza.development@gmail.com")
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
  end
end
