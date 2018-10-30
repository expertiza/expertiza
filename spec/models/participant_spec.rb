describe Participant do
  let(:student) { build(:student, name: "Student", fullname: "Test, Student") }
  let(:participant) { build(:participant, user: student, can_review: false) }

  describe "#name" do
    it "returns the name of the user" do
      expect(participant.name).to eq "Student"
    end
  end

  describe "#fullname" do
    it "returns the full name of the user" do
      expect(participant.fullname).to eq "Test, Student"
    end
  end

  describe "#able_to_review" do
    it "returns whether the current participant has permission to review others' work" do
      #allow(participant).to receive(:can_review).with(nil).and_return(true)
      expect(participant.able_to_review).to be false
    end
  end

end