describe Participant do
  let(:student) { build(:student, name: "Student", fullname: "Test, Student") }
  let(:participant) { build(:participant, user: student) }
  #let (:team_user1) {TeamsUser.new user_id, team_id}
  #let (:team_user1) { build(:team_user, student: participant)}
  let(:response_map1) { build(:review_response_map, reviewer: participant2, id: 10) }
  let(:response_map2) { build(:review_response_map, reviewer: participant2, id: 20) }
  let(:response1) { build(:response, id: 1, map_id: 10, response_map: response_map1) }
  let(:response2) { build(:response, id: 2, map_id: 20, response_map: response_map2) }
  let(:participant3) { build(:participant) }
  
  describe "#team" do
   it "returns the team id for the user" do
#	   student= build(:student, id: 1, name: 'no name', fullname: 'no one') 
#     team = build(:team, id: 1, name: 'no team') 
#     participant = build(:participant, user: student) 
#	   team_user = build(:team_user, id: 1, user:student , team: team)
#	   expect(participant.user_id).to eq(1) 
#     expect(participant.team).to eq(1) 
     
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
     #it 'returns scores obtained by the participant for given questions' do
     #expect(questionnaire.name).to eql('Test questionnaire')
     #expect(assignment1.assignment).to be_valid
     #expect(participant2.scores). to eql("ssss")
   end
   
   describe '#topic_name' do     
     context 'when the participant has an assignment without a topic' do
       it 'returns error message' do
         expect(participant.topic_name).to eql('<center>&#8212;</center>')
       end
     end

     context 'when the participant has an assignment with an unnamed topic' do
       it 'returns error message' do
         topic = build(:topic, topic_name: '')
         allow(participant3).to receive(:topic).and_return(topic)
         expect(participant3.topic_name).to eql('<center>&#8212;</center>')
       end
     end
     
     context 'when the participant has an assignment with a named topic' do
       it 'returns the name of the topic associated to the assignment of the participant' do
         topic = build(:topic, topic_name: 'Test topic name')
         allow(participant3).to receive(:topic).and_return(topic)
         expect(topic.topic_name).to eql('Test topic name')
         expect(participant3.topic_name).to eql('Test topic name')
       end
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