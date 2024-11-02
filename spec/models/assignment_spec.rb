describe Assignment do
  let(:assignment) { build(:assignment, id: 1, name: 'no assignment', participants: [participant], teams: [team], max_team_size: 2) }
  let(:instructor) { build(:instructor, id: 6) }
  let(:student) { build(:student, id: 3, username: 'no one') }
  let(:review_response_map) { build(:review_response_map, response: [response], reviewer: build(:participant), reviewee: build(:assignment_team)) }
  let(:teammate_review_response_map) { build(:review_response_map, type: 'TeammateReviewResponseMap') }
  let(:participant) { build(:participant, id: 1) }
  let(:question) { double('Question') }
  let(:team) { build(:assignment_team, id: 1, name: 'no team') }
  let(:response) { build(:response) }
  let(:course) { build(:course) }
  let(:assignment_due_date) do
    build(:assignment_due_date, due_at: '2011-11-11 11:11:11', deadline_name: 'Review',
                                description_url: 'https://expertiza.ncsu.edu/', round: 1)
  end
  let(:topic_due_date) { build(:topic_due_date, deadline_name: 'Submission', description_url: 'https://github.com/expertiza/expertiza') }
  let(:deadline_type) { build(:deadline_type, id: 1) }
  let(:assignment_questionnaire1) { build(:assignment_questionnaire, id: 1, assignment_id: 1, questionnaire_id: 1) }
  let(:assignment_questionnaire2) { build(:assignment_questionnaire, id: 2, assignment_id: 1, questionnaire_id: 2) }
  let(:questionnaire1) { build(:questionnaire, id: 1, type: 'ReviewQuestionnaire') }
  let(:questionnaire2) { build(:questionnaire, id: 2, type: 'MetareviewQuestionnaire') }

  describe '#user_on_team?' do
    context 'when the user is not on a team associated with the assignment' do
      it 'returns false' do
        allow_any_instance_of(Team).to receive(:users).and_return([instructor])
        expect(assignment.user_on_team?(student)).to be_falsey
      end
    end
    context 'when the user is on a team associated with the assignment' do
      it 'returns true' do
        allow_any_instance_of(Team).to receive(:users).and_return([student])
        expect(assignment.user_on_team?(student)).to be_truthy
      end
    end
  end

  describe '.max_outstanding_reviews' do
    it 'returns 2 by default' do
      expect(Assignment.max_outstanding_reviews).to eq(2)
    end
  end

  describe '#team_assignment?' do
    it 'checks an assignment has team' do
      expect(assignment.team_assignment?).to be true
    end
  end

  describe '#topics?' do
    context 'when sign_up_topics array is not empty' do
      it 'says current assignment has topics' do
        assignment.sign_up_topics << build(:topic)
        expect(assignment.topics?).to be true
      end
    end

    context 'when sign_up_topics array is empty' do
      it 'says current assignment does not have a topic' do
        assignment.sign_up_topics = []
        expect(assignment.topics?).to be false
      end
    end
  end

  describe '.assign_courses_to_assignment' do
    it 'fetches all courses belong to current instructor and with the order of course names' do
      course = double('Course')
      allow(Course).to receive_message_chain(:where, :order).with(instructor_id: 6).with(:name).and_return([course])
      expect(Assignment.assign_courses_to_assignment(instructor)).to eq([course])
    end
  end

  describe '#teams?' do
    context 'when teams array is not empty' do
      it 'says current assignment has teams' do
        assignment.teams << build(:assignment_team)
        expect(assignment.teams?).to be true
      end
    end

    context 'when teams array is empty' do
      it 'says current assignment does not have a team' do
        assignment.teams = []
        expect(assignment.teams?).to be false
      end
    end
  end

  describe '#remove_empty_teams' do
    before :each do
      @assignment = create(:assignment)
      @student = create(:student)
      @empty_team = create(:assignment_team, assignment: @assignment, teams_users: [])
      @non_empty_team = create(:assignment_team, assignment: @assignment, teams_users: [create(:team_user, user: @student)])
    end
    it 'should reduce the number of teams by the number of empty teams in the assignment' do
      expect(@assignment.teams).to include @empty_team
      @assignment.remove_empty_teams
      expect(@assignment.teams).to_not include @empty_team
      expect(@assignment.teams).to include @non_empty_team
    end
  end

  describe '#vary_rubrics_by_round?' do
    context 'when rubrics varies over rounds' do
      it 'should return true' do
        assignment_questionnaire1.used_in_round = 2
        assignment_questionnaire2.used_in_round = 2
        allow(AssignmentQuestionnaire).to receive(:where).and_return([assignment_questionnaire1, assignment_questionnaire2])
        expect(assignment.varying_rubrics_by_round?).to be true
      end
    end

  end

  describe '#valid_num_review' do
    context 'when num_reviews_allowed is not -1 and num_reviews_allowed is less than num_reviews_required' do
      it 'adds an error message to current assignment object' do
        assignment.num_reviews_allowed = 1
        assignment.num_reviews_required = 2
        expect(assignment.errors[:message]).to eq []
        expect { assignment.valid_num_review }.to change { assignment.errors[:message] }.from([])
                                                                                        .to(['Num of reviews required cannot be greater than number of reviews allowed'])
      end
    end

    context 'when the first if condition is false, num_metareviews_allowed is not -1, and num_metareviews_allowed less than num_metareviews_required' do
      it 'adds an error message to current assignment object' do
        assignment.num_reviews_allowed = -1
        assignment.num_metareviews_allowed = 1
        assignment.num_metareviews_required = 2
        expect(assignment.errors[:message]).to eq []
        expect { assignment.valid_num_review }.to change { assignment.errors[:message] }.from([])
                                                                                        .to(['Number of Meta-Reviews required cannot be greater than number of meta-reviews allowed'])
      end
    end
  end

  describe '#assign_metareviewer_dynamically' do
    it 'returns true when assigning successfully' do
      meta_reviewer = double('AssignmentParticipant')
      response_map = double('MetareviewResponseMap')
      allow(assignment).to receive(:response_map_to_metareview).with(meta_reviewer).and_return(response_map)
      allow(response_map).to receive(:assign_metareviewer).with(meta_reviewer).and_return(true)
      expect(assignment.assign_metareviewer_dynamically(meta_reviewer)).to be true
    end
  end

  describe '#response_map_to_metareview' do
    it 'does not raise any errors and returns the first review response map' do
      metareviewer = double('AssignmentParticipant', name: 'metareviewer')
      allow(assignment).to receive(:review_mappings).and_return([review_response_map])
      allow(Array).to receive(:new).with([review_response_map]).and_return([review_response_map])
      allow(review_response_map).to receive(:metareviewed_by?).with(metareviewer).and_return(false)
      allow(review_response_map).to receive(:metareview_response_maps).and_return([double('MetareviewResponseMap')])
      expect(assignment.response_map_to_metareview(metareviewer)).to eq(review_response_map)
    end
  end

  describe '#metareview_mappings' do
    it 'returns review mapping' do
      review_response_map = double('ReviewResponseMap', id: 1)
      metareview_response_map = double('MetareviewResponseMap')
      allow(assignment).to receive(:review_mappings).and_return([review_response_map])
      allow(MetareviewResponseMap).to receive(:find_by).with(reviewed_object_id: 1).and_return(metareview_response_map)
      expect(assignment.metareview_mappings).to eq([metareview_response_map])
    end
  end

  describe '#dynamic_reviewer_assignment?' do
    context 'when review_assignment_strategy of current assignment is Auto-Selected' do
      it 'returns true' do
        expect(assignment.dynamic_reviewer_assignment?).to be true
      end
    end

    context 'when review_assignment_strategy of current assignment is Instructor-Selected' do
      it 'returns false' do
        assignment.review_assignment_strategy = 'Instructor-Selected'
        expect(assignment.dynamic_reviewer_assignment?).to be false
      end
    end
  end

  describe '#questionnaire_ids' do
    context 'when the assignment does not have rounds' do
      it 'it returns the ids of the associated questionnaires' do
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: 1).and_return([assignment_questionnaire1])
        expect(assignment.questionnaire_ids(nil)).to eq([assignment_questionnaire1])
      end
    end
    context 'when the assignment has rounds' do
      it 'it returns the id of the associated questionnaires from the round' do
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: 1, used_in_round: 1).and_return([assignment_questionnaire1])
        expect(assignment.questionnaire_ids(1)).to eq([assignment_questionnaire1])
      end
    end
    context 'when the assignment has no associated questionnaires' do
      it 'returns a review questionnaire' do
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: 1, used_in_round: 1).and_return([])
        arr = [assignment_questionnaire1, assignment_questionnaire2]
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: 1).and_return(arr)
        allow(arr).to receive(:find_each).and_yield(assignment_questionnaire1).and_yield(assignment_questionnaire2)
        allow(assignment_questionnaire1).to receive(:questionnaire).and_return(questionnaire1)
        allow(assignment_questionnaire2).to receive(:questionnaire).and_return(questionnaire2)
        expect(assignment.questionnaire_ids(1)).to eq([assignment_questionnaire1])
      end
    end
  end

  describe '#path' do
    context 'when both course_id and instructor_id are nil' do
      it 'raises an error' do
        assignment.course_id = nil
        assignment.instructor_id = nil
        expect { assignment.path }.to raise_error('The path cannot be created. The assignment must be associated with either a course or an instructor.')
      end
    end

    context 'when course_id is not nil and course_id is larger than 0' do
      it 'returns path with course directory path' do
        allow(Rails).to receive(:root).and_return('/root')
        allow(User).to receive(:find).with(1).and_return(instructor)
        allow(Course).to receive(:find).with(1).and_return(course)
        expect(assignment.path).to eq('/root/pg_data/instructor6/csc517/test/final_test')
      end
    end

    context 'when course_id is nil' do
      it 'returns path without course directory path' do
        assignment.course_id = nil
        allow(Rails).to receive_message_chain(:root, :to_s).and_return('/root')
        allow(User).to receive(:find).with(1).and_return(instructor)
        expect(assignment.path).to eq('/root/pg_data/instructor6/final_test')
      end
    end
  end

  describe '#check_condition' do
    context 'when the next due date is nil' do
      it 'returns false ' do
        allow(DueDate).to receive(:get_next_due_date).with(1, nil).and_return(nil)
        expect(assignment.check_condition('review_allowed_id')).to be false
      end
    end

    context 'when the next due date is allowed to review submissions' do
      it 'returns true' do
        assignment_due_date = double('AssignmentDueDate')
        allow(DueDate).to receive(:get_next_due_date).with(1, nil).and_return(assignment_due_date)
        allow(assignment_due_date).to receive(:send).with('review_allowed_id').and_return(1)
        allow(DeadlineRight).to receive(:find).with(1).and_return(double('DeadlineRight', name: 'OK'))
        expect(assignment.check_condition('review_allowed_id')).to be true
      end
    end
  end

  describe '#submission_allowed' do
    it 'returns true when the next topic due date is allowed to submit sth' do
      allow(assignment).to receive(:check_condition).with('submission_allowed_id', 123).and_return(true)
      expect(assignment.submission_allowed(123)).to be true
    end
  end

  describe '#quiz_allowed' do
    it 'returns false when the next topic due date is not allowed to do quiz' do
      allow(assignment).to receive(:check_condition).with('quiz_allowed_id', 456).and_return(false)
      expect(assignment.quiz_allowed(456)).to be false
    end
  end

  describe '#can_review' do
    it "returns false when the next assignment due date is not allowed to review other's work" do
      allow(assignment).to receive(:check_condition).with('review_allowed_id', nil).and_return(true)
      expect(assignment.can_review).to be true
    end
  end

  describe '#metareview_allowed' do
    it 'returns true when the next assignment due date is not allowed to do metareview' do
      allow(assignment).to receive(:check_condition).with(any_args).and_return(false)
      expect(assignment.metareview_allowed).to be false
    end
  end

  describe '#delete' do
    before(:each) do
      allow(ReviewResponseMap).to receive(:where).with(reviewed_object_id: 1).and_return([review_response_map])
      allow(TeammateReviewResponseMap).to receive(:where).with(reviewed_object_id: 1).and_return([teammate_review_response_map])
    end
    context 'when there is at least one review response in current assignment' do
      it 'raises an error message and current assignment cannot be deleted' do
        allow(review_response_map).to receive(:delete).with(nil)
                                                      .and_raise('Mysql2::Error: Cannot delete or update a parent row: a foreign key constraint fails')
        expect { assignment.delete }.to raise_error('There is at least one review response that exists for no assignment.')
      end
    end

    context 'when there is no review response in current assignment and at least one teammate review response in current assignment' do
      it 'raises an error message and current assignment cannot be deleted' do
        allow(review_response_map).to receive(:delete).with(nil).and_return(true)
        allow(teammate_review_response_map).to receive(:delete).with(nil).and_raise('Something wrong during deletion')
        expect { assignment.delete }.to raise_error('There is at least one teammate review response that exists for no assignment.')
      end
    end

    context 'when ReviewResponseMap and TeammateReviewResponseMap can be deleted successfully' do
      it 'deletes other corresponding db records and current assignment' do
        allow(review_response_map).to receive(:delete).with(nil).and_return(true)
        allow(teammate_review_response_map).to receive(:delete).with(nil).and_return(true)
        allow(teammate_review_response_map).to receive(:delete).with(nil).and_return(true)
        allow(Rails).to receive(:root).and_return('/root')
        directory = double('Dir')
        allow(Dir).to receive(:entries).with('/root/pg_data/final_test').and_return(directory)
        allow(directory).to receive(:size).and_return(2)
        allow(Dir).to receive(:delete).with('/root/pg_data/final_test').and_return(true)
        allow(assignment).to receive(:destroy).and_return(true)
        expect(assignment.delete).to be true
      end
    end
  end

  describe '#microtask?' do
    context 'when microtask is not nil' do
      it 'returns microtask status (false by default)' do
        expect(assignment.microtask?).to be false
      end

      it 'returns microtask status true if microtask of assignment was reset from default value' do
        assignment = build(:assignment, microtask: true)
        expect(assignment.microtask?).to be true
      end
    end

    context 'when microtask is nil' do
      it 'returns false ' do
        allow(assignment).to receive(:microtask).and_return(nil)
        expect(assignment.microtask?).to be false
      end
    end
  end

  describe '#add_participant' do
    context 'when user is nil' do
      it 'raises an error' do
        allow(User).to receive(:find_by).with(username: 'no one').and_return(nil)
        allow_any_instance_of(Assignment).to receive(:url_for).with(controller: 'users', action: 'new').and_return('users/new/1')
        expect { assignment.add_participant('no one', nil, nil, nil, nil) }.to raise_error(RuntimeError, %r{a href='users/new/1'>create</a> the user first})
      end
    end

    context 'when the user is already a participant of current assignment' do
      it 'raises an error' do
        allow(User).to receive(:find_by).with(username: 'no one').and_return(student)
        allow(AssignmentParticipant).to receive(:find_by).with(parent_id: 1, user_id: 3).and_return(participant)
        expect { assignment.add_participant('no one', nil, nil, nil, nil) }.to raise_error(RuntimeError, /The user no one is already a participant/)
      end
    end

    context 'when AssignmentParticipant was created successfully' do
      it 'returns true' do
        allow(User).to receive(:find_by).with(username: 'no one').and_return(student)
        allow(AssignmentParticipant).to receive(:find_by).with(parent_id: 1, user_id: 3).and_return(nil)
        allow(AssignmentParticipant).to receive(:create).with(parent_id: 1, user_id: 3, permission_granted: 0,
                                                              can_submit: true, can_review: true, can_take_quiz: false, can_mentor: false).and_return(participant)
        expect { assignment.add_participant('no one', true, true, false, false) }.to change { AssignmentParticipant.count }.from(0).to(1)
      end
    end
  end

  describe '#create_node' do
    it 'will save node' do
      allow(CourseNode).to receive(:find_by).with(node_object_id: 1).and_return(double('CourseNode', id: 1))
      expect { assignment.create_node }.to change { AssignmentNode.count }.from(0).to(1)
      expect(AssignmentNode.first.parent_id).to eq(1)
      expect(AssignmentNode.table).to eq('assignments')
      expect(AssignmentNode.first.is_leaf).to eq(true)
      allow(Assignment).to receive(:find_by).with(id: 1).and_return(assignment)
      expect(AssignmentNode.first.get_private).to eq(false)
    end
  end

  describe '#number_of_current_round' do
    context 'when next_due_date is nil' do
      it 'returns 0' do
        allow(DueDate).to receive(:get_next_due_date).with(1, 1).and_return(nil)
        expect(assignment.number_of_current_round(1)).to eq(0)
      end
    end

    context 'when next_due_date is not nil' do
      it 'returns the round of next_due_date' do
        allow(DueDate).to receive(:get_next_due_date).with(1, 1).and_return(double('DueDate', round: 2))
        expect(assignment.number_of_current_round(1)).to eq(2)
      end
    end
  end

  describe '#current_stage_name' do
    context 'when assignment has staggered deadline' do
      before(:each) { allow(assignment).to receive(:staggered_deadline?).and_return(true) }
      context 'topic_id is nil' do
        it 'returns Unknow' do
          expect(assignment.current_stage_name(nil)).to eq('Unknown')
        end
      end

      context 'topic_id is not nil' do
        it 'returns Submission' do
          allow(assignment).to receive(:current_stage).with(123).and_return('Submission')
          expect(assignment.current_stage_name(123)).to eq('Submission')
        end
      end
    end

    context 'when assignment does not have staggered deadline' do
      before(:each) { allow(assignment).to receive(:staggered_deadline?).and_return(false) }
      context "when due date is not equal to 'Finished', due date is not nil and its deadline name is not nil" do
        it 'returns the deadline name of current due date' do
          allow(assignment).to receive(:find_current_stage).with(123).and_return(assignment_due_date)
          expect(assignment.current_stage_name(123)).to eq('Review')
        end
      end
      context "when due date is equal to 'Finished'" do
        it 'returns Submission' do
          allow(assignment).to receive(:find_current_stage).with(123).and_return('Finished')
          allow(assignment).to receive(:current_stage).with(123).and_return('Submission')
          expect(assignment.current_stage_name(123)).to eq('Submission')
        end
      end
    end
  end

  describe '#link_for_current_stage' do
    context 'when current assignment has staggered deadline and topic id is nil' do
      it 'returns nil' do
        allow(assignment).to receive(:staggered_deadline?).and_return(true)
        expect(assignment.link_for_current_stage(nil)).to eq(nil)
      end
    end

    context 'when current assignment does not have staggered deadline' do
      before(:each) { allow(assignment).to receive(:staggered_deadline?).and_return(false) }
      context 'when due date is a TopicDueDate' do
        it 'returns nil' do
          allow(assignment).to receive(:find_current_stage).with(123).and_return(topic_due_date)
          expect(assignment.link_for_current_stage(123)).to eq(nil)
        end
      end

      context 'when due_date is not nil, not finished and is not a TopicDueDate' do
        it 'returns description url of current due date' do
          allow(assignment).to receive(:find_current_stage).with(123).and_return(assignment_due_date)
          expect(assignment.link_for_current_stage(123)).to eq('https://expertiza.ncsu.edu/')
        end
      end
    end
  end

  describe '#stage_deadline' do
    context 'when topic id is nil and current assignment has staggered deadline' do
      it 'returns Unknown' do
        allow(assignment).to receive(:staggered_deadline?).and_return(true)
        expect(assignment.stage_deadline).to eq('Unknown')
      end
    end

    context 'when current assignment does not have staggered deadline' do
      context 'when due date is nil' do
        it 'returns nil' do
          allow(assignment).to receive(:find_current_stage).with(123).and_return(nil)
          expect(assignment.stage_deadline(123)).to be nil
        end
      end

      context 'when due date is not nil and due date is not equal to Finished' do
        it 'returns due date' do
          allow(assignment).to receive(:find_current_stage).with(123).and_return(assignment_due_date)
          expect(assignment.stage_deadline(123)).to match('2011-11-11 11:11:11')
        end
      end
    end
  end

  describe '#num_review_rounds' do
    it 'returns max round number in all due dates of current assignment' do
      allow(AssignmentDueDate).to receive(:where).with(parent_id: 1).and_return([assignment_due_date])
      expect(assignment.num_review_rounds).to eq(1)
    end
  end

  describe '#find_current_stage' do
    context 'when next due date is nil' do
      it 'returns Finished' do
        allow(DueDate).to receive(:get_next_due_date).with(1, 123).and_return(nil)
        expect(assignment.find_current_stage(123)).to eq('Finished')
      end
    end

    context 'when next due date is nil' do
      it 'returns next due date object' do
        allow(DueDate).to receive(:get_next_due_date).with(1, 123).and_return(assignment_due_date)
        expect(assignment.find_current_stage(123)).to eq(assignment_due_date)
      end
    end
  end

  describe '#review_questionnaire_id' do
    context 'when corresponding active record for assignment_questionnaire is found' do
      before(:each) do
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment.id).and_return(
          [assignment_questionnaire1, assignment_questionnaire2]
        )
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment.id, used_in_round: 2).and_return([])
        allow(Questionnaire).to receive(:find).with(1).and_return(questionnaire1)
      end

      it 'returns correct questionnaire id found by used_in_round and topic_id if both used_in_round and topic_id are given' do
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment.id, used_in_round: 1, topic_id: 1).and_return(
          [assignment_questionnaire1]
        )
        allow(Questionnaire).to receive(:find_by).with(id: 1).and_return(questionnaire1)
        expect(assignment.review_questionnaire_id(1, 1)).to eq(questionnaire1.id)
      end

      it 'returns correct questionnaire id found by used_in_round if only used_in_round is given' do
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment.id, used_in_round: 1, topic_id: nil).and_return(
          [assignment_questionnaire1]
        )
        allow(Questionnaire).to receive(:find_by).with(id: 1).and_return(questionnaire1)
        expect(assignment.review_questionnaire_id(1, nil)).to eq(questionnaire1.id)
      end

      it 'returns correct questionnaire id found by topic_id if only topic_id is given and there is no current round used in the due date' do
        allow(DueDate).to receive(:get_next_due_date).with(assignment.id).and_return(nil)
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment.id, used_in_round: nil, topic_id: 1).and_return(
          [assignment_questionnaire1]
        )
        allow(Questionnaire).to receive(:find_by).with(id: 1).and_return(questionnaire1)
        expect(assignment.review_questionnaire_id(nil, 1)).to eq(questionnaire1.id)
      end

      it 'returns correct questionnaire id found by used_in_round and topic_id if only topic_id is given, but current round is found by the due date' do
        allow(DueDate).to receive(:get_next_due_date).with(assignment.id).and_return(assignment_due_date)
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment.id, used_in_round: 1, topic_id: 1).and_return(
          [assignment_questionnaire1]
        )
        allow(Questionnaire).to receive(:find_by).with(id: 1).and_return(questionnaire1)
        expect(assignment.review_questionnaire_id(nil, 1)).to eq(questionnaire1.id)
      end
    end

    context 'when corresponding active record for assignment_questionnaire is not found' do
      it 'returns correct questionnaire id found by type' do
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment.id).and_return(
          [assignment_questionnaire1, assignment_questionnaire2]
        )
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment.id, used_in_round: 2).and_return([])
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment.id, used_in_round: 1, topic_id: 1).and_return([])
        allow(AssignmentQuestionnaire).to receive(:where).with(user_id: anything, assignment_id: nil, questionnaire_id: nil).and_return([])
        allow(Questionnaire).to receive(:find_by).with(id: 1).and_return(nil)
        allow(Questionnaire).to receive(:find).with(1).and_return(questionnaire1)
        allow(Questionnaire).to receive(:find).with(2).and_return(questionnaire2)
        expect(assignment.review_questionnaire_id(1, 1)).to eq(questionnaire1.id)
      end
    end

    context 'when corresponding active record for assignment_questionnaire is found, but for questionnaire is not found' do
      it 'returns nil' do
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment.id).and_return(
          [assignment_questionnaire1, assignment_questionnaire2]
        )
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment.id, used_in_round: 2).and_return([])
        allow(AssignmentQuestionnaire).to receive(:where).with(assignment_id: assignment.id).and_return(
          [assignment_questionnaire1]
        )
        allow(assignment_questionnaire1).to receive(:questionnaire_id).and_return(nil)
        allow(AssignmentQuestionnaire).to receive(:where).with(user_id: anything, assignment_id: nil, questionnaire_id: nil).and_return([])
        expect(assignment.review_questionnaire_id(1, 1)).to eq(nil)
      end
    end
  end

  describe 'has correct csv values?' do
    before(:each) do
      create(:assignment)
      create(:assignment_team, name: 'team1')
      @student = create(:student, username: 'student1')
      create(:participant, user: @student)
      create(:questionnaire)
      create(:question)
      create(:review_response_map)
      create(:response)
      @options = { 'team_id' => 'true', 'team_name' => 'true',
                   'reviewer' => 'true', 'question' => 'true',
                   'question_id' => 'true', 'comment_id' => 'true',
                   'comments' => 'true', 'score' => 'true' }
    end

    def generated_csv(t_assignment, t_options)
      delimiter = ','
      CSV.generate(col_sep: delimiter) do |csv|
        csv << Assignment.export_headers(t_assignment.id)
        csv << Assignment.export_details_fields(t_options)
        Assignment.export_details(csv, t_assignment.id, t_options)
      end
    end

    it 'checks_if_csv has the correct data' do
      create(:answer, comments: 'Test comment')
      expected_csv = File.read('spec/features/assignment_export_details/expected_details_csv.txt')
      expect(generated_csv(assignment, @options)).to eq(expected_csv)
    end

    it 'checks csv with some options' do
      create(:answer, comments: 'Test comment')
      @options['team_id'] = 'false'
      @options['question_id'] = 'false'
      @options['comment_id'] = 'false'
      expected_csv = File.read('spec/features/assignment_export_details/expected_details_some_options_csv.txt')
      expect(generated_csv(assignment, @options)).to eq(expected_csv)
    end

    it 'checks csv with no data' do
      expected_csv = File.read('spec/features/assignment_export_details/expected_details_no_data_csv.txt')
      expect(generated_csv(assignment, @options)).to eq(expected_csv)
    end

    it 'checks csv with data and no options' do
      create(:answer, comments: 'Test comment')
      @options['team_id'] = 'false'
      @options['team_name'] = 'false'
      @options['reviewer'] = 'false'
      @options['question'] = 'false'
      @options['question_id'] = 'false'
      @options['comment_id'] = 'false'
      @options['comments'] = 'false'
      @options['score'] = 'false'
      expected_csv = File.read('spec/features/assignment_export_details/expected_details_no_options_csv.txt')
      expect(generated_csv(assignment, @options)).to eq(expected_csv)
    end
  end

  describe 'find_due_dates' do
    context 'if deadline is of assignment' do
      it ' return assignment due_date' do
        assignment = create(:assignment)
        dead_rigth = create(:deadline_right)
        @deadline_type = create(:deadline_type)
        @assignment_due_date = create(:assignment_due_date, parent_id: assignment.id, review_allowed_id: dead_rigth.id, review_of_review_allowed_id: dead_rigth.id, submission_allowed_id: dead_rigth.id, deadline_type: @deadline_type)
        expect(assignment.find_due_dates('submission').first).to eq(@assignment_due_date)
      end
    end

    context 'if deadline is of assignment' do
      it ' return assignment nil' do
        assignment = create(:assignment)
        expect(assignment.find_due_dates('submission').first).to eq(nil)
      end
    end
  end

  describe 'find_review_period' do
    context 'if round number is specified' do
      it 'returns the start date and end date for that round' do
        assignment = create(:assignment)
        dead_right = create(:deadline_right)
        @deadline_type_sub = create(:deadline_type, name: 'submission')
        @deadline_type_rev = create(:deadline_type, name: 'review')
        @assignment_due_date_sub = create(:assignment_due_date, parent_id: assignment.id, review_allowed_id: dead_right.id, review_of_review_allowed_id: dead_right.id, submission_allowed_id: dead_right.id, deadline_type: @deadline_type_sub)
        @assignment_due_date_rev = create(:assignment_due_date, parent_id: assignment.id, review_allowed_id: dead_right.id, review_of_review_allowed_id: dead_right.id, submission_allowed_id: dead_right.id, deadline_type: @deadline_type_rev)
        expect(assignment.find_review_period(1)).to eql([[@assignment_due_date_sub], [@assignment_due_date_rev]])
      end
    end
    context 'if round number is nil' do
      it 'returns all start dates and end dates for that assignment' do
        assignment = create(:assignment)
        dead_right = create(:deadline_right)
        @deadline_type_sub = create(:deadline_type, name: 'submission')
        @deadline_type_rev = create(:deadline_type, name: 'review')
        @assignment_due_date_sub1 = create(:assignment_due_date, round: 1, parent_id: assignment.id, review_allowed_id: dead_right.id, review_of_review_allowed_id: dead_right.id, submission_allowed_id: dead_right.id, deadline_type: @deadline_type_sub)
        @assignment_due_date_rev1 = create(:assignment_due_date, round: 1, parent_id: assignment.id, review_allowed_id: dead_right.id, review_of_review_allowed_id: dead_right.id, submission_allowed_id: dead_right.id, deadline_type: @deadline_type_rev)
        @assignment_due_date_sub2 = create(:assignment_due_date, round: 2, parent_id: assignment.id, review_allowed_id: dead_right.id, review_of_review_allowed_id: dead_right.id, submission_allowed_id: dead_right.id, deadline_type: @deadline_type_sub)
        @assignment_due_date_rev2 = create(:assignment_due_date, round: 2, parent_id: assignment.id, review_allowed_id: dead_right.id, review_of_review_allowed_id: dead_right.id, submission_allowed_id: dead_right.id, deadline_type: @deadline_type_rev)
        expect(assignment.find_review_period(nil)).to eql([[@assignment_due_date_sub1, @assignment_due_date_sub2], [@assignment_due_date_rev1, @assignment_due_date_rev2]])
      end
    end
  end
  describe '#calibrated?' do
    context 'when the assignment is not a calibrated assignment' do
      it 'returns false' do
        assignment = create(:assignment)
        allow(assignment).to receive(:is_calibrated).and_return(false)
        expect(assignment.calibrated?).to be_falsey
      end
    end
    context 'when the assignment is a calibrated assignment' do
      it 'returns true' do
        assignment = create(:assignment)
        allow(assignment).to receive(:is_calibrated).and_return(true)
        expect(assignment.calibrated?).to be_truthy
      end
    end
  end
  describe '#remove_assignment_from_course' do
    it 'sets the course_id to nil' do
      assignment = create(:assignment)
      assignment.course_id = 2
      expect(assignment.course_id).to eq(2)
      assignment.remove_assignment_from_course
      expect(assignment.course_id).to be_nil
    end
  end

  describe '#pair_programming_enabled?' do
    let(:assignment1) { build(:assignment, id: 1, name: 'assignment 1', enable_pair_programming: false) }
    let(:assignment2) { build(:assignment, id: 2, name: 'assignment 2', enable_pair_programming: true) }
    context 'checks if pair_programming is enabled' do
      it 'returns false' do
        expect(assignment1.pair_programming_enabled?).to be_falsey
      end

      it 'returns true' do
        expect(assignment2.pair_programming_enabled?).to be_truthy
      end
    end
  end
end

