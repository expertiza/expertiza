describe MailWorker do
  let(:assignment) { build(:assignment, id: 1, name: "no assignment", participants: [participant], teams: [team]) }
  let(:participant) { build(:participant, id: 1) }
  let(:team) { build(:assignment_team, id: 1, name: 'no team', users: [user], parent_id: 1) }
  let(:user) { build(:student, id: 1, email: 'psingh22@ncsu.edu') }
  
  
  before(:each) do
    allow(Assignment).to receive(:find).with('1').and_return(assignment)
    allow(Team).to receive(:where).with(parent_id: '1').and_return([team])
  end

  describe 'Tests mailer with sidekiq' do
    before do
      Sidekiq::Testing.inline!
    end
    it "should send email to required email address with proper content" do
      MailWorker.perform_async("1", "metareview", "2018-12-31 00:00:01")
    end
  end
end

