describe Participant do
  let(:student) { build(:student, name: "Student", fullname: "Test, Student") }
  let(:participant) { build(:participant, user: student) }
  
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
  
  # verify pull request
  #describe "#team" do
   #it "returns the team name" do
   #end
   
   describe '.sort_by_name' do
     it 'sorts a set of participants based on their user names' do
       stu1 = build(:student, name: "Student1")
       stu2 = build(:student, name: "Student2")
       stu3 = build(:student, name: "Student3")
       p1 = build(:participant, user: stu1) 
       p2 = build(:participant, user: stu2)
       p3 = build(:participant, user: stu3)
       participants = [ p2, p1, p3]
       
       expect(Participant.sort_by_name(participants).length).to eql(3)
       expect(Participant.sort_by_name(participants)).to match_array([p1, p2, p3])
     end  
   end
end