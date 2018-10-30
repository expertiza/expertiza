describe MailWorker do
  let(:assignment) { build(:assignment, id: 1, name: "no assignment", participants: [participant], teams: [team]) }
  let(:participant) { build(:participant, id: 1, parent_id: 1, user: user) }
  let(:team) { build(:assignment_team, id: 1, name: 'no team', users: [user], parent_id: 1) }
  let(:user) { build(:student, id: 1, email: 'psingh22@ncsu.edu') }
  
  
  before(:each) do
    allow(Assignment).to receive(:find).with('1').and_return(assignment)
    allow(Participant).to receive(:where).with(parent_id: '1').and_return([participant])
  end

  describe 'Tests mailer with sidekiq' do
    before do
      Sidekiq::Testing.inline!
    end
    it "should send email to required email address with proper content" do
      MailWorker.perform_async("1", "metareview", "2018-12-31 00:00:01")
      email = ActionMailer::Base.deliveries.first
      expect(email.from[0]).to eq("expertiza.development@gmail.com")
      expect(email.bcc[0]).to eq(user.email)
      expect(email.subject).to eq('Message regarding teammate review for assignment '+ assignment.name)
    end
  end
end