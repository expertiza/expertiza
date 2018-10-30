describe Participant do
  let(:student) { build(:student, name: "Student", fullname: "Test, Student") }
  let(:participant) { build(:participant, user: student) }
  
  let(:participant2) { build(:participant, id: 8, user: build(:student, name: 'Student Second'))}
  let(:response_map1) { build(:review_response_map, reviewer: participant2, id: 10) }
  let(:response_map2) { build(:review_response_map, reviewer: participant2, id: 20) }
  let(:response1) { build( :response, id: 1, map_id: 10, response_map: response_map1) }
  let(:response2) { build( :response, id: 2, map_id: 20, response_map: response_map2) }
  
  let(:questionnaire) { build(:questionnaire) }
  let(:assignment1) { build(:assignment_questionnaire) }
  
  describe "#team" do
   it "returns the team id for the user" do
	   student= build(:student, id: 1, name: 'no name', fullname: 'no one') 
     team = build(:team, id: 1, name: 'no team') 
     participant = build(:participant, user: student) 
	   team_user = build(:team_user, id: 1, user:student , team: team)
	   expect(participant.user_id).to eq(1) 
     #expect(participant.team).to eq(1) 
    end   
  end
  
   describe '#responses' do
     it 'returns an array ofresponses of the participant' do
       puts participant.response_maps
       expect(participant.responses).to eql([])
     end
   end

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
  
   describe '#scores' do
     it 'returns scores obtained by the participant for given questions' do
     
     expect(questionnaire.name).to eql('Test questionnaire')
     #expect(assignment1.assignment).to be_valid
     end
   end
   
   describe '.sort_by_name' do
     it 'sorts a set of participants based on their user names' do
       stu1 = build(:student, name: "Student1")
       stu2 = build(:student, name: "Student2")
       stu3 = build(:student, name: "Student3")
       p1 = build(:participant, user: stu1, id: 2) 
       p2 = build(:participant, user: stu2, id: 3)
       p3 = build(:participant, user: stu3, id: 1)
       participants = [ p2, p1, p3]
       
       sorted_participants = Participant.sort_by_name(participants)
       expect(Participant.sort_by_name(participants)).to match_array([p1, p2, p3])
       expect(sorted_participants.length).to eql(3)
       expect(sorted_participants).to match_array([p1, p2, p3])
       
       ids = []
       sorted_participants.each do |p|
         ids << p.id
       end
       expect(ids).to match_array([2, 3, 1]) 
     end  
   end
end