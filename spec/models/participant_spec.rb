describe Participant do
  let(:student) { build(:student, name: "Student", fullname: "Test, Student") }
  let(:student2) { build(:student, name: "Student2") }
  let(:participant) { build(:participant, user: student) }
  let(:assignment) { build(:assignment) }
  let(:participant2) { build(:participant, assignment: assignment) }
  let(:assignment_team) { build(:assignment_team) }
  let(:team_user) { build(:team_user, user: student, team: assignment_team)}
  let(:response) { build(:response, response_map: response_map)}
  let(:response_map) { build(:review_response_map, assignment: assignment, reviewer: participant2, reviewee: assignment_team)}
  let(:question) { build(:question) }
  let(:review_questionnaire) { build(:questionnaire, id: 2) }
  #let(:response_map1) { build(:review_response_map, reviewer: participant2, id: 10) }
  #et(:response_map2) { build(:review_response_map, reviewer: participant2, id: 20) }
  #let(:response1) { build(:response, id: 1, map_id: 10, response_map: response_map1) }
  #let(:response2) { build(:response, id: 2, map_id: 20, response_map: response_map2) }
  #let(:team_user1) {TeamsUser.new user_id, team_id}
  
  describe "#team" do
   it "returns the team id for the user" do
    allow(TeamsUser).to receive(:find_by).with(user: student).and_return(team_user)
    expect(participant.team).to eq(nil)
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
      allow(assignment).to receive(:questionnaires).and_return([review_questionnaire])
      allow(AssignmentQuestionnaire).to receive_message_chain(:find_by, :used_in_round).with(assignment_id: 1, questionnaire_id: 2)\
          .with(no_args).and_return(2)
       allow(review_questionnaire).to receive(:get_assessments_for).with(participant2).and_return([response])
       allow(Answer).to receive(:compute_scores).and_return(max: 95, min: 88, avg: 90)
       allow(assignment).to receive(:compute_total_score).with(any_args).and_return(100)
       expect(participant2.assignment.compute_total_score(:test)).to eql(100)
       puts participant2.scores(question)
       expect(participant2.scores(question).inspect).to eq("{:participant=>#<AssignmentParticipant id: nil, can_submit: true, can_review: true, user_id: 2, parent_id: nil, submitted_at: nil, permission_granted: nil, penalty_accumulated: 0, grade: nil, type: \"AssignmentParticipant\", handle: \"handle\", time_stamp: nil, digital_signature: nil, duty: nil, can_take_quiz: true, Hamer: 1.0, Lauw: 0.0>, :review2=>{:assessments=>nil, :scores=>{:max=>95, :min=>88, :avg=>90}}, :total_score=>100}")
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
         allow(participant2).to receive(:topic).and_return(topic)
         expect(participant2.topic_name).to eql('<center>&#8212;</center>')
       end
     end
     
     context 'when the participant has an assignment with a named topic' do
       it 'returns the name of the topic associated to the assignment of the participant' do
         topic = build(:topic, topic_name: 'Test topic name')
         allow(participant2).to receive(:topic).and_return(topic)
         expect(topic.topic_name).to eql('Test topic name')
         expect(participant2.topic_name).to eql('Test topic name')
       end
     end   
   end
   
   describe '#able_to_review' do
     it 'returns true if the participant can review' do
       expect(participant.able_to_review).to eql(true)
     end
   end
   
   describe '#email' do
    it 'sends email to the current user' do
      allow(User).to receive(:find_by).with(id: nil).and_return(student)
      allow(participant).to receive(:assignment_id).and_return(nil)
      allow(Assignment).to receive(:find_by).with(id: nil).and_return(assignment)
      expect(participant.email('password', 'home_page').subject).to eq("You have been registered as a participant in the Assignment final2")
      expect(participant.email('password', 'home_page').to[0]).to eq ("expertiza.development@gmail.com")
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
  
  describe '.get_authorization'  do
    context 'when input is true for can_review and can_take quiz' do
      it 'returns authorization as reader' do
        expect(Participant.get_authorization(false, true, true )).to eq('reader')
      end
    end
    
    context 'when input is true only for can_submit' do
      it 'returns authorization submitter' do
        expect(Participant.get_authorization(true, false, false)).to eq('submitter')
      end
    end
    
    context 'when the input is true for only for can_review' do
      it 'returns authorization as reviewer' do
        expect(Participant.get_authorization(false, true, false)).to eq('reviewer')
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
       
       ids = []
       sorted_participants.each do |p|
         ids << p.id
       end
       expect(ids).to match_array([2, 3, 1]) 
     end  
   end
   
   describe "#delete" do
    it " should remove a participant if there is no pre-existing association" do
      expect(participant.delete(true)).to eq(participant)
    end
  end
end