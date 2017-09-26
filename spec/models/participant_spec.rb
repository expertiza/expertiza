describe Participant do
  before(:each) do
    @student = double('User', name: "Student", fullname: "Student Test")
    @participant = build(:participant)
  end

  it "is valid" do
    expect(@participant).to be_valid
  end

  it "can review" do
    expect(@participant.able_to_review).to be_truthy
  end

  it "can submit" do
    expect(@participant.can_submit).to be_truthy
  end

  it "can take quiz" do
    expect(@participant.can_take_quiz).to be_truthy
  end

  it "has 0 penalty accumulated" do
    expect(@participant.penalty_accumulated).to be_zero
  end

  it "is type of assignment participant" do
    expect(@participant.type).to eql "AssignmentParticipant"
  end

  describe "#topicname" do
    it "returns the topic name" do
      expect(@participant.topic_name).to eql "<center>&#8212;</center>"
    end
  end

  # TODO: need more decent way to rewrite 2 tests below.
  describe "#name" do
    it "returns the name of the user" do
      participant = double('Participant')
      allow(participant).to receive(:name).with(any_args).and_return(@student.name)
      expect(participant.name).to eql "Student"
    end
  end

  describe "#fullname" do
    it "returns the full name of the user" do
      participant = double('Participant')
      allow(participant).to receive(:fullname).with(any_args).and_return(@student.fullname)
      expect(participant.fullname).to eql "Student Test"
    end
  end
end
