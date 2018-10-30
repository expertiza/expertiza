describe Participant do
  #let(:student) { build(:student, name: "Student", fullname: "Test, Student") }
  #let(:participant) { build(:participant, user: student) }

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
end
