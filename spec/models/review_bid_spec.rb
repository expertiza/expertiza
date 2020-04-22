describe ReviewBid do
  let(:test) { build(:review_bid, priority: 1, participant_id: 1,  signuptopic_id: 1,assignment_id: 1) }
  let(:assignment) { build(:assignment, id: 1, instructor_id: 6, due_dates: [due_date], microtask: true, staggered_deadline: true) }
  let(:instructor) { build(:instructor, id: 6) }
  let(:student) { build(:student, id: 8) }
  let(:participant) { build(:participant, id: 1, user_id: 6, assignment: assignment) }
  let(:topic) { build(:topic, id: 1) }

  describe "#priority" do
    it "returns the priority of the ReviewBid" do
      expect(test.name).to eq(1)
    end
  end	
	
  describe "#participant_id" do
    it "returns the priority of the ReviewBid" do
      expect(test.participant_id).to eq(2)
    end
	
	  it "validate participant_id is integer" do
      expect(test.participant_id).to eq(2)
      test.participant_id = 'a'
      expect(test).not_to be_valid
    end
  end

  describe "#signuptopic_id" do
    it "returns the priority of the ReviewBid" do
      expect(test.signuptopic_id).to eq(1)
    end
	
	  it "validate participant_id is integer" do
      expect(test.signuptopic_id).to eq(1)
      test.signuptopic_id = 'a'
      expect(test).not_to be_valid
    end
  end
  
  describe "#assignment_id" do
    it "returns the priority of the ReviewBid" do
      expect(assignment_id).to eq(2)
	end  
	  
	it "validate participant_id is integer" do
      expect(test.assignment_id).to eq(2)
      test.signuptopic_id = 'a'
      expect(test).not_to be_valid
    end
  end
  
  describe '.assignment_reviewers' do
    it 'check if array is being returned' do
	  arrayReturned = ReviewBid.assignment_bidding_data(assignment.id)
      expect(test.assignment_reviewers(assignment.id)).to be_an_instance_of(Array)
    end
  end
  
  
  describe '.reviewer_self_topic' do
    it 'check if value is integer or nil is being returned' do
	  val = ReviewBid.reviewer_self_topic(test.participant_id,assignment.id)
      expect(val).to be_a_kind_of(Integer)
    end
  end
end	
