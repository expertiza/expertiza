describe 'AssignmentTeam' do
  let(:team_without_submitted_hyperlinks) { build(:assignment_team, submitted_hyperlinks: '') }
  let(:team) { build(:assignment_team, id: 1, parent_id: 1) }
  let(:assignment) { build(:assignment, id: 1) }
  let(:participant1) { build(:participant, id: 1) }
  let(:participant2) { build(:participant, id: 2) }
  let(:user1) { build(:student, id: 2) }
  let(:user2) { build(:student, id: 3) }
  let(:review_response_map) { build(:review_response_map, reviewed_object_id: 1, reviewer_id: 1, reviewee_id: 1) }
  let(:topic) { build(:topic, id: 1, topic_name: 'New Topic') }
  let(:signedupteam) { build(:signed_up_team) }

  describe '#hyperlinks' do
    context 'when current teams submitted hyperlinks' do
      it 'returns the hyperlinks submitted by the team' do
        expect(team.hyperlinks).to eq(['https://www.expertiza.ncsu.edu'])
      end
    end

    context 'when current teams did not submit hyperlinks' do
      it 'returns an empty array' do
        expect(team_without_submitted_hyperlinks.hyperlinks).to eq([])
      end
    end
  end

  describe '#includes?' do
    context 'when an assignment team has one participant' do
      it 'includes one participant' do
        allow(team).to receive(:users).with(no_args).and_return([user1])
        allow(AssignmentParticipant).to receive(:find_by).with(user_id: user1.id, parent_id: team.parent_id).and_return(participant1)
        expect(team.includes?(participant1)).to eq true
      end
    end

    context 'when an assignment team has no users' do
      it 'includes no participants' do
        allow(team).to receive(:users).with(no_args).and_return([])
        expect(team.includes?(participant1)).to eq false
      end
    end
  end

  describe '#parent_model' do
    it 'provides the name of the parent model' do
      expect(team.parent_model).to eq 'Assignment'
    end
  end

  describe '.parent_model' do
    it 'provides the instance of the parent model' do
      allow(Assignment).to receive(:find).with(1).and_return(assignment)
      expect(AssignmentTeam.parent_model(1)).to eq assignment
    end
  end

  describe '#fullname' do
    context 'when the team has a name' do
      it 'provides the name of the class' do
        team = build(:assignment_team, id: 1, name: 'abcd')
        expect(team.fullname).to eq 'abcd'
      end
    end
  end

  describe '.remove_team_by_id' do
    context 'when a team has an id' do
      it 'delete the team by id' do
        allow(AssignmentTeam).to receive(:find).with(team.id).and_return(team)
        expect(AssignmentTeam.remove_team_by_id(team.id)).to eq(team)
      end
    end
  end

  describe '.first_member' do
    context 'when team id is present' do
      it 'get first member of the  team' do
        allow(AssignmentTeam).to receive_message_chain(:find_by, :try, :try).with(id: team.id).with(:participant).with(:first).and_return(participant1)
        expect(AssignmentTeam.first_member(team.id)).to eq(participant1)
      end
    end
  end

  describe '#review_map_type' do
    it 'provides the review map type' do
      expect(team.review_map_type).to eq 'ReviewResponseMap'
    end
  end

  describe '.prototype' do
    it 'provides the instance of the AssignmentTeam' do
      expect(AssignmentTeam).to receive(:new).with(no_args)
      AssignmentTeam.prototype
    end
  end

  describe '#reviewed_by?' do
    context 'when a team has a reviewer' do
      it 'has been reviewed by this reviewer' do
        template = 'reviewee_id = ? && reviewer_id = ? && reviewed_object_id = ?'
        allow(ReviewResponseMap).to receive(:where).with(template, team.id, participant1.id, team.assignment.id).and_return([review_response_map])
        expect(team.reviewed_by?(participant1)).to eq true
      end
    end

    context 'when a team does not have any reviewers' do
      it 'has not been reviewed by this reviewer' do
        template = 'reviewee_id = ? && reviewer_id = ? && reviewed_object_id = ?'
        allow(ReviewResponseMap).to receive(:where).with(template, team.id, participant1.id, team.assignment.id).and_return([])
        expect(team.reviewed_by?(participant1)).to eq false
      end
    end
  end

  describe '#participants' do
    context 'when an assignment team has two participants' do
      it 'has those two participants' do
        allow(team).to receive(:users).with(no_args).and_return([user1, user2])
        allow(AssignmentParticipant).to receive(:find_by).with(user_id: user1.id, parent_id: team.parent_id).and_return(participant1)
        allow(AssignmentParticipant).to receive(:find_by).with(user_id: user2.id, parent_id: team.parent_id).and_return(participant2)
        expect(team.participants).to eq [participant1, participant2]
      end
    end

    context 'when an assignment team has a user but no participants' do
      it 'includes no participants' do
        allow(team).to receive(:users).with(no_args).and_return([user1])
        allow(AssignmentParticipant).to receive(:find_by).with(user_id: user1.id, parent_id: team.parent_id).and_return(nil)
        expect(team.participants).to eq []
      end
    end
  end

  describe '.export_fields' do
    context 'when team has name' do
      it 'exports the fields' do
        expect(AssignmentTeam.export_fields(team)).to eq(['Team Name', 'Assignment Name'])
      end
    end
  end

  describe '#copy' do
    context 'for given assignment team' do
      it 'copies the assignment team to course team' do
        assignment = team.assignment
        course = assignment.course
        expect(team.copy(course.id)).to eq([])
      end
    end
  end

  describe '#add_participant' do
    context 'when a user is not a part of the team' do
      it 'adds the user to the team' do
        user = build(:student, id: 10)
        assignment = team.assignment
        expect(team.add_participant(assignment.id, user)).to be_an_instance_of(AssignmentParticipant)
      end
    end

    context 'when a user is already a part of the team' do
      it 'returns without adding user to the team' do
        allow(team).to receive(:users).with(no_args).and_return([user1])
        allow(AssignmentParticipant).to receive(:find_by).with(user_id: user1.id, parent_id: team.parent_id).and_return(participant1)
        assignment = team.assignment
        expect(team.add_participant(assignment.id, user1)).to eq(nil)
      end
    end
  end

  describe '#topic' do
    context 'when the team has picked a topic' do
      it 'provides the topic id' do
        assignment = team.assignment
        allow(SignUpTopic).to receive(:find_by).with(assignment: assignment).and_return(topic)
        allow(SignedUpTeam).to receive_message_chain(:find_by, :try).with(team_id: team.id).with(:topic_id).and_return(topic.id)
        expect(team.topic).to eq(topic.id)
      end
    end
  end

  describe '#delete' do
    it 'deletes the team' do
      allow(team).to receive(:users).with(no_args).and_return([user1, user2])
      allow(AssignmentParticipant).to receive(:find_by).with(user_id: user1.id, parent_id: team.parent_id).and_return(participant1)
      allow(AssignmentParticipant).to receive(:find_by).with(user_id: user2.id, parent_id: team.parent_id).and_return(participant2)
      expect(team.delete).to eq(team)
    end
  end

  describe '.import' do
    context 'when an assignment team does not already exist with the same id' do
      it 'cannot be imported' do
        assignment_id = 1
        allow(Assignment).to receive(:find_by).with(id: assignment_id).and_return(nil)
        error_message = 'The assignment with the id "' + assignment_id.to_s + "\" was not found. <a href='/assignment/new'>Create</a> this assignment?"
        expect { AssignmentTeam.import([], assignment_id, []) }
          .to raise_error(ImportError, error_message)
      end
    end

    context 'when an assignment team with the same id already exists' do
      it 'gets imported through Team.import' do
        row = []
        assignment_id = 1
        options = []
        allow(Assignment).to receive(:find_by).with(id: assignment_id).and_return(assignment)
        allow(Team).to receive(:import).with(row, assignment_id, options, instance_of(AssignmentTeam))
        expect(Team).to receive(:import).with(row, assignment_id, options, instance_of(AssignmentTeam))
        AssignmentTeam.import(row, assignment_id, options)
      end
    end
  end

  describe '.export' do
    it 'redirects to Team.export with a new AssignmentTeam object' do
      allow(Team).to receive(:export).with([], 1, [], instance_of(AssignmentTeam))
      expect(Team).to receive(:export).with([], 1, [], instance_of(AssignmentTeam))
      AssignmentTeam.export([], 1, [])
    end
  end

  describe '#path' do
    it 'returns the path' do
      allow(team).to receive_message_chain(:assignment, :path).and_return('assignment_path')
      allow(team).to receive(:directory_num).and_return(5)
      expect(team.path).to eq 'assignment_path/5'
    end
  end

  describe '#set_student_directory_num' do
    it 'sets the directory for the team' do
      team = build(:assignment_team, id: 1, parent_id: 1, directory_num: -1)
      max_num = 0
      allow(AssignmentTeam).to receive_message_chain(:where, :order, :first, :directory_num)
        .with(parent_id: team.parent_id).with(:directory_num, :desc).with(no_args).with(no_args).and_return(max_num)
      expect(team.set_student_directory_num).to be true
    end
  end

  describe '#submit_hyperlink' do
    context 'when a hyperlink is empty' do
      it 'causes an exception to be raised' do
        expect { team.submit_hyperlink('') }.to raise_error('The hyperlink cannot be empty!')
      end
    end

    context 'when a hyperlink is invalid' do
      it 'causes an exception to be raised with the proper HTTP status code' do
        invalid_hyperlink = 'https://expertiza.ncsu.edu/not_a_valid_path'
        allow(Net::HTTP).to receive(:get_response).and_return('404')
        expect { team.submit_hyperlink(invalid_hyperlink) }.to raise_error('HTTP status code: 404')
      end
    end

    context 'when a valid hyperlink not in a certain improper format is submitted' do
      it 'it is fixed and is saved to the database' do
        allow(team).to receive(:hyperlinks).and_return(['https://expertiza.ncsu.edu'])
        allow(team).to receive(:submitted_hyperlinks=)
        allow(team).to receive(:save)
        allow(Net::HTTP).to receive(:get_response).and_return('0')
        allow(YAML).to receive(:dump).with(%w[https://expertiza.ncsu.edu www.ncsu.edu])
        expect(team).to receive(:submitted_hyperlinks=)
        expect(team).to receive(:save)
        expect(YAML).to receive(:dump).with(%w[https://expertiza.ncsu.edu http://www.ncsu.edu])
        team.submit_hyperlink('www.ncsu.edu  ')
      end
    end
  end

  describe '#remove_hyperlink' do
    context "when the hyperlink is in the assignment team's hyperlinks" do
      it "is removed from the team's list of hyperlinks" do
        allow(team).to receive(:hyperlinks).and_return(%w[https://expertiza.ncsu.edu https://www.ncsu.edu])
        expect(team).to receive(:submitted_hyperlinks=)
        expect(team).to receive(:save)
        expect(YAML).to receive(:dump).with(['https://expertiza.ncsu.edu'])
        team.remove_hyperlink('https://www.ncsu.edu')
      end
    end
  end

  describe '#received_any_peer_review?' do
    it 'checks if the team has received any reviews' do
      allow(ResponseMap).to receive_message_chain(:where, :any?).with(reviewee_id: team.id, reviewed_object_id: team.parent_id).with(no_args).and_return(true)
      expect(team.received_any_peer_review?).to be true
    end
  end

  describe '#submitted_files' do
    context 'given a path' do
      it 'returns submitted files' do
        files = ['file1.rb']
        path = 'assignment_path/5'
        allow(team).to receive(:path).with(path)
        allow(team).to receive(:files).with(path).and_return(files)
        expect(team.submitted_files(path)).to match_array(files)
      end
    end
  end

  describe '.team' do
    context 'when there is a participant' do
      it 'provides the team for participant' do
        teamuser = build(:team_user, id: 1, team_id: team.id, user_id: user1.id)
        allow(team).to receive(:users).with(no_args).and_return([user1])
        allow(AssignmentParticipant).to receive(:find_by).with(user_id: user1.id, parent_id: team.parent_id).and_return(participant1)
        allow(TeamsUser).to receive(:where).with(user_id: participant1.user_id).and_return([teamuser])
        allow(Team).to receive(:find).with(teamuser.team_id).and_return(team)
        expect(AssignmentTeam.team(participant1)).to eq(team)
      end
    end
  end

  describe '#files' do
    context 'when file is present in the directory' do
      it 'provides the list of files in directory and checks if file is present' do
        directory = 'spec/models'
        expect(team.files(directory)).to include('spec/models/assignment_team_spec.rb')
      end
    end

    context 'when file is not present in the directory' do
      it 'provides the list of files in directory and checks if file is not present' do
        directory = 'spec/controllers'
        expect(team.files(directory)).not_to include('spec/models/assignment_team_spec.rb')
      end
    end
  end

  describe '#assign_reviewer' do
    context 'when a reviewer is present' do
      it 'assign the reviewer to the team' do
        allow(Assignment).to receive(:find).with(team.parent_id).and_return(assignment)
        allow(ReviewResponseMap).to receive(:create)
          .with(reviewee_id: team.id, reviewer_id: participant1.id, reviewed_object_id: assignment.id, team_reviewing_enabled: false).and_return(review_response_map)
        expect(team.assign_reviewer(participant1)).to eq(review_response_map)
      end
    end
  end

  describe '#has_submissions?' do
    context 'when a team has submitted files' do
      it 'has submissions' do
        allow(team).to receive_message_chain(:submitted_files, :any?).with(no_args).with(no_args).and_return(true)
      end
    end

    context 'when the team has submitted hyperlink' do
      it 'checks if the team has submissions' do
        allow(team).to receive_message_chain(:submitted_hyperlinks, :present?).with(no_args).with(no_args).and_return(true)
      end
    end

    after(:each) do
      expect(team.has_submissions?).to be true
    end
  end

  describe '#destroy' do
    it 'delete the reviews' do
      expect(team).to receive_message_chain(:review_response_maps, :each).with(no_args).with(no_args)
      team.destroy
    end
  end

  describe 'create team with users' do
    before(:each) do
      @assignment = create(:assignment)
      @student = create(:student)
      @team = create(:assignment_team, parent_id: @assignment.id)
      @team_user = create(:team_user, team_id: @team.id, user_id: @student.id)
    end
    it 'should create a team with users' do
      new_team = AssignmentTeam.create_team_with_users(@assignment.id, [@student.id])
      expect(new_team.users).to include @student
    end

    it 'should remove user from previous team' do
      expect(@team.users).to include @student
      new_team = AssignmentTeam.create_team_with_users(@assignment.id, [@student.id])
      expect(@team.users).to_not include @student
    end
  end
end
