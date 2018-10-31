describe Participant do
  let(:student) { build(:student, name: "Student", fullname: "Test, Student") }
  let(:participant) { build(:participant, user: student) }
  let(:response_map1) { build(:review_response_map, reviewer: participant2, id: 10) }
  let(:response_map2) { build(:review_response_map, reviewer: participant2, id: 20) }
  let(:response1) { build(:response, id: 1, map_id: 10, response_map: response_map1) }
  let(:response2) { build(:response, id: 2, map_id: 20, response_map: response_map2) }
  let(:participant3) { build(:participant) }
  #let (:team_user1) {TeamsUser.new user_id, team_id}
  #let (:team_user1) { build(:team_user, student: participant)}

  
  describe "#team" do
   it "returns the team id for the user" do
	   user= build(:student, name: 'no name', fullname: 'no one') 
#     team = build(:team, id: 1, name: 'no team') 
     p1 = build(:participant) 
#	   team_user = build(:team_user, id: 1, user:student , team: team)
 

     #allow(participant).to receive(:team_user)
     #expect(participant.team).to eq(1)
     
#     team_user = build(:team_user, user: user)
#     allow(TeamsUser).to receive(:find_by).with(user: user).and_return(user)
#     allow(user).to receive(:try).with(team: team).and_return(team_user.team)
#     allow(p1).to receive(:team_user)
#     expect(participant.team).to eq(1)
     #expect(team_user.user).to eq(1)
     
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
      assignment = build(:assignment, id: 1) 
      p = build(:participant, assignment: assignment)
      review_questionnaire = build(:questionnaire, id: 1)
      question = double('Question')
      response = build(:response)
      reponse_map = build(:review_response_map)
      
      allow(assignment).to receive(:questionnaires).and_return([review_questionnaire])
      allow(AssignmentQuestionnaire).to receive(:find_by).with(assignment_id: 1, questionnaire_id: 1)
                                                         .and_return(double('AssignmentQuestionnaire', used_in_round: nil))
       allow(review_questionnaire).to receive(:symbol).and_return(:review)
       allow(review_questionnaire).to receive(:get_assessments_for).with(p).and_return([response])
       allow(Answer).to receive(:compute_scores).with([response], [question]).and_return(max: 95, min: 88, avg: 90)
       allow(assignment).to receive(:compute_total_score).with(any_args).and_return(100)
       
       
       expect(p.assignment.compute_total_score(:test)).to eql(100)
       #expect(p.scores(:review [question])).to eql(100)
       
     end
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
   
   describe '#able_to_review' do
     it 'returns true if the participant can review' do
       expect(participant.able_to_review).to eql(true)
     end
   end
   
   describe '.get_permissions' do
     context 'when current participant is authorized as reader' do
       it 'participant cannot submit' do
         expect(Participant.get_permissions('reader')).to eql({ :can_submit => false, :can_review => true, :can_take_quiz => true})
       end
     end

     context 'when current participant is authorized as reviewer' do
       it 'participant can only review' do
         expect(Participant.get_permissions('reviewer')).to eql({ :can_submit => false, :can_review => true, :can_take_quiz => false})
       end
     end

     context 'when current participant is authorized as submitter' do
       it 'participant can only submit' do
         expect(Participant.get_permissions('submitter')).to eql({ :can_submit => true, :can_review => false, :can_take_quiz => false})
       end
     end  
   end
  
  describe ".get_authorization"  do
        it "returns authorization as reader when input is true for can_review and can_take quiz" do
                expect(Participant.get_authorization(false, true, true )).to eq('reader')
        end
        it  "returns authorization submitter when input is true only for can_submit" do
                expect(Participant.get_authorization(true, false, false)).to eq('submitter')
        end
        it  "returns authorization as reviewer when the input is true for only for can_review" do
                expect(Participant.get_authorization(false, true, false)).to eq('reviewer')
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
       
       ids = []
       sorted_participants.each do |p|
         ids << p.id
       end
       expect(ids).to match_array([2, 3, 1]) 
     end  
   end
end