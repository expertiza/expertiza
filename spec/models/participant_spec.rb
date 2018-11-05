describe Participant do
  let(:student) { build(:student, name: 'Student', fullname: 'Test, Student') }
  let(:student2) { build(:student, name: 'Student2') }
  let(:student3) { build(:student, name: 'Student3') }
  let(:assignment) { build(:assignment) }
  let(:assignment_team) { build(:assignment_team) }
  let(:participant) { build(:participant, user: student) }
  let(:participant2) { build(:participant, assignment: assignment, user: student2) }
  let(:participant3) { build(:participant, user: student3) }
  let(:team_user) { build(:team_user, user: student, team: assignment_team) }
  let(:response) { build(:response, response_map: response_map) }
  let(:response_map) { build(:review_response_map, assignment: assignment, reviewer: participant2, reviewee: assignment_team) }
  let(:question) { build(:question) }
  let(:review_questionnaire) { build(:questionnaire, id: 2) }
  let(:topic1) { build(:topic, topic_name: '') }
  let(:topic2) { build(:topic, topic_name: 'Test topic name') }
  
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
     context 'when the round is nil' do
       it 'returns scores obtained by the participant for given questions' do
         allow(assignment).to receive(:questionnaires).and_return([review_questionnaire])
         allow(AssignmentQuestionnaire).to receive_message_chain(:find_by, :used_in_round)\
         .with(assignment_id: 1, questionnaire_id: 2).with(no_args).and_return(nil)
         allow(review_questionnaire).to receive(:get_assessments_for).with(participant2).and_return([response])
         allow(Answer).to receive(:compute_scores).and_return(max: 95, min: 88, avg: 90)
         allow(assignment).to receive(:compute_total_score).with(any_args).and_return(100)
         expect(participant2.assignment.compute_total_score(:test)).to eql(100)
         #puts participant2.scores(question)
         expect(participant2.scores(question)).to include(:total_score=>100)
         expect(participant2.scores(question).inspect).to eq("{:participant=>#<AssignmentParticipant id: nil, can_submit: true, "\
         "can_review: true, user_id: nil, parent_id: nil, submitted_at: nil, permission_granted: nil, penalty_accumulated: 0, "\
         "grade: nil, type: \"AssignmentParticipant\", handle: \"handle\", time_stamp: nil, digital_signature: nil, duty: nil, "\
         "can_take_quiz: true, Hamer: 1.0, Lauw: 0.0>, :review=>{:assessments=>[#<Response id: nil, map_id: nil, additional_comment: nil,"\
         " created_at: nil, updated_at: nil, version_num: nil, round: 1, is_submitted: false>], :scores=>{:max=>95, :min=>88, :avg=>90}}, "\
         ":total_score=>100}")
       end
     end
     
     context 'when the round is not nil' do
       it 'returns scores obtained by the participant for given questions' do
         allow(assignment).to receive(:questionnaires).and_return([review_questionnaire])
         allow(AssignmentQuestionnaire).to receive_message_chain(:find_by, :used_in_round)\
         .with(assignment_id: 1, questionnaire_id: 2).with(no_args).and_return(2)
         allow(review_questionnaire).to receive(:get_assessments_for).with(participant2).and_return([response])
         allow(Answer).to receive(:compute_scores).and_return(max: 95, min: 88, avg: 90)
         allow(assignment).to receive(:compute_total_score).with(any_args).and_return(100)
         expect(participant2.assignment.compute_total_score(:test)).to eql(100)
         #puts participant2.scores(question)
         expect(participant2.scores(question).inspect).to eq("{:participant=>#<AssignmentParticipant id: nil, can_submit: true, "\
         "can_review: true, user_id: nil, parent_id: nil, submitted_at: nil, permission_granted: nil, penalty_accumulated: 0, "\
         "grade: nil, type: \"AssignmentParticipant\", handle: \"handle\", time_stamp: nil, digital_signature: nil, duty: nil, "\
         "can_take_quiz: true, Hamer: 1.0, Lauw: 0.0>, :review2=>{:assessments=>[#<Response id: nil, map_id: nil, additional_comment: nil,"\
         " created_at: nil, updated_at: nil, version_num: nil, round: 1, is_submitted: false>], :scores=>{:max=>95, :min=>88, :avg=>90}},"\
         " :total_score=>100}")
       end
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
         allow(participant2).to receive(:topic).and_return(topic1)
         expect(participant2.topic_name).to eql('<center>&#8212;</center>')
       end
     end
     
     context 'when the participant has an assignment with a named topic' do
       it 'returns the name of the topic associated to the assignment of the participant' do
         allow(participant2).to receive(:topic).and_return(topic2)
         expect(topic2.topic_name).to eql('Test topic name')
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
       expect(Participant.sort_by_name([participant, participant3, participant2])).to match_array([participant, participant2, participant3])
       
       names = []
       sorted_participants = Participant.sort_by_name([participant, participant3, participant2])
       expect(sorted_participants.length).to eql(3)
       sorted_participants.each do |p|
         names << p.user.name
       end
       expect(names).to match_array(["Student", "Student2", "Student3"]) 
     end  
   end
   
   describe "#delete" do
    it " should remove a participant if there is no pre-existing association" do
      expect(participant.delete(true)).to eq(participant)
    end
  end
end