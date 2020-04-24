describe ReviewBid do
  let(:test) { build(:review_bid, priority: 1, participant_id: 1,  topic_id: 1,assignment_id: 1) }
  let(:test1) { build(:review_bid, priority: 1, participant_id: 'b',  topic_id: 'c',assignment_id: 'd') }
  let(:assignment) { build(:assignment, id: 1, instructor_id: 6, due_dates: [due_date], microtask: true, staggered_deadline: true) }
  let(:instructor) { build(:instructor, id: 6) }
  let(:student) { build(:student, id: 8) }
  let(:participant) { build(:participant, id: 16, user_id: 6, assignment: assignment) }
  let(:topic) { build(:topic, id: 1) }

  describe "#priority" do
    it "returns the priority of the ReviewBid" do
      expect(test.priority).to eq(1)
    end
  end

  describe "#participant_id" do
    it "returns the participant_id of the ReviewBid" do
      expect(test.participant_id).to eq(1)
    end

it "validate participant_id is integer" do
      expect(test1.participant_id).not_to eq('b')
    end
  end

  describe "#topic_id" do
    it "returns the topic_id of the ReviewBid" do
      expect(test.topic_id).to eq(1)
    end

it "validate topic_id is integer" do
      expect(test1.topic_id).not_to eq('c')
    end
  end
 
  describe "#assignment_id" do
    it "returns the assingment_id of the ReviewBid" do
      expect(test.assignment_id).to eq(1)
end  
 
it "validate assignment_id is integer" do
      expect(test1.assignment_id).not_to eq('d')
    end
  end
 
  describe '.assignment_reviewers' do
    it 'check if array is being returned for assignment_reviewers' do
      expect(ReviewBid.assignment_reviewers(test.assignment_id)).to be_an_instance_of(Array)
    end
  end
 
 
  describe '.assignment_bidding_data' do
    it 'check if hash is being returned for assignment_bidding_data' do
      val = ReviewBid.assignment_reviewers(test.assignment_id)
      expect(ReviewBid.assignment_bidding_data(test.assignment_id,val)).to be_a_kind_of(Hash)
    end
  end

  describe '.reviewer_bidding_data' do
    it 'check if hash is being returned for reviwer_bidding_data' do
      allow(Participant).to receive(:reviewer).with(8).and_return(7)
      val = ReviewBid.reviewer_bidding_data(test.participant_id,test.assignment_id)
      expect(val).to be_a_kind_of(Hash)
    end
  end

  describe '.reviewer_self_topic' do
    it 'check if integer or nil is being returned for reviewer_self_topic' do
      allow(Participant).to receive(:reviewer).with(5).and_return(10)
      val = ReviewBid.reviewer_self_topic(test.participant_id,test.assignment_id)
      expect(val).to be_a_kind_of(Integer) or be_nil
    end
  end

end 
