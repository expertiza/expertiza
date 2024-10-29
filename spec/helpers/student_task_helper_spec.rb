describe StudentTaskHelper do
  let(:student_task_helper) { Class.new { extend StudentTaskHelper } }
  let(:user) { create(:student) }
  let(:user2) { create(:student, name: 'qwertyui', id: 5) }
  let(:user3) { create(:student, name: 'qwertyui1234', id: 6) }
  let(:deadline_type) { build(:deadline_type, id: 1) }
  let(:due_date) { build(:assignment_due_date, deadline_type_id: 1) }
  let(:assignment) { build(:assignment, name: 'assignment', directory_path: 'assignment') }
  let(:assignment2) { build(:assignment, name: 'assignment2', directory_path: 'assignment2') }
  let(:participant) { build(:participant, id: 1, user_id: user.id, parent_id: assignment.id) }
  let(:participant2) { build(:participant, id: 2, user_id: user2.id, parent_id: assignment.id) }
  let(:participant3) { instance_double('Participant', assignment: assignment, topic: topic, current_stage: 'submission', stage_deadline: '2024-12-31 12:00:00') }
  let(:participant4) { instance_double('Participant1', assignment: assignment, topic: topic, current_stage: 'review', stage_deadline: '2024-12-01 12:00:00') }
  let(:participant5) { instance_double('Participant1', assignment: assignment, topic: topic, current_stage: 'submission', stage_deadline: '2024-11-01 12:00:00') }
  let(:team) { create(:assignment_team, id: 1, name: 'team 1', parent_id: assignment.id, users: [user, user2]) }
  let(:team2) { create(:assignment_team, id: 2, name: 'team 2', parent_id: assignment2.id, users: [user3]) }
  let(:course) { build(:course) }
  let(:course_team) { create(:course_team, id: 3, name: 'course team 1', parent_id: course.id) }
  let(:review_response_map) { build(:review_response_map, assignment: assignment, reviewer: participant, reviewee: team2) }
  let(:response) { build(:response, id: 1, map_id: 1, response_map: review_response_map) }
  let(:topic) { instance_double('Topic') }
  let(:response_modifier) do
    ->(response, label) {
      {
        id: response.id,
        label: label,
        updated_at: response.updated_at.strftime('%a, %d %b %Y %H:%M')
      }
    }
  end
  
  # Gets the due dates of an assignment
  describe '#for_each_due_date_of_assignment' do
    let(:due_date_modifier) do
      ->(dd) {
        { label: (dd.deadline_type.name + ' Deadline').humanize,
          updated_at: dd.due_at.strftime('%a, %d %b %Y %H:%M')
        }
      }
    end
    context 'when called with assignment having empty due dates' do
      it 'return empty time_list array' do
        timeline_list = []
        student_task_helper.for_each_due_date_of_assignment(assignment) do |due_date|
          timeline_list << due_date_modifier.call(due_date)
        end
        expect(timeline_list).to eq([])
      end
    end
    context 'when called with assignment having due date' do
      context 'and due_at value nil' do
        it 'return empty time_list array' do
          allow(due_date).to receive(:deadline_type).and_return(deadline_type)
          timeline_list = []
          due_date.due_at = nil
          assignment.due_dates = [due_date]
          student_task_helper.for_each_due_date_of_assignment(assignment) do |due_date|
            timeline_list << due_date_modifier.call(due_date)
          end
          expect(timeline_list).to eq([])
        end
      end
      context 'and due_at value not nil' do
        it 'return time_list array' do
          allow(due_date).to receive(:deadline_type).and_return(deadline_type)
          timeline_list = []
          assignment.due_dates = [due_date]
          student_task_helper.for_each_due_date_of_assignment(assignment) do |due_date|
            timeline_list << due_date_modifier.call(due_date)
          end
          expect(timeline_list).to eq([{
                                        label: (due_date.deadline_type.name + ' Deadline').humanize,
                                        updated_at: due_date.due_at.strftime('%a, %d %b %Y %H:%M')
                                      }])
        end
      end
    end
  end

  # Verifies fetching of peer review data of a user and a timeline
  describe '#for_each_peer_review' do
    context 'when no review response mapped' do
      it 'returns empty' do
        timeline_list = []
        for_each_peer_review(user2) do |response|
          timeline_list << response_modifier.call(response, "Round #{response.round} Peer Review".humanize)
        end
        expect(timeline_list).to eq([])
      end
    end
    context 'when mapped to review response map' do
      it 'returns timeline array' do
        timeline_list = []
        allow(ReviewResponseMap).to receive_message_chain(:where, :find_each).with(reviewer_id: 1).with(no_args).and_yield(review_response_map)
        allow(review_response_map).to receive(:id).and_return(1)
        allow(Response).to receive_message_chain(:where, :last).with(map_id: 1).with(no_args).and_return(response)
        allow(response).to receive(:round).and_return(1)
        allow(response).to receive(:updated_at).and_return(Time.new(2019))
        timevalue = Time.new(2019).strftime('%a, %d %b %Y %H:%M')
        for_each_peer_review(1) do |resp|
          timeline_list << response_modifier.call(resp, "Round #{resp.round} Peer Review".humanize)
        end
        expect(timeline_list).to eq([{ id: 1, label: 'Round 1 peer review', updated_at: timevalue }])
      end
    end
  end

  # Verifies retrieval of feedback from author
  describe '#for_each_author_feedback' do
    context 'when no feedback response mapped' do
      it 'returns empty' do
        timeline_list = []
        for_each_author_feedback(user2) do |response|
          timeline_list << response_modifier.call(response, "Author feedback")
        end
        expect(timeline_list).to eq([])
      end
    end
    context 'when mapped to feedback response map' do
      it 'returns timeline array' do
        timeline_list = []
        allow(FeedbackResponseMap).to receive_message_chain(:where, :find_each).with(reviewer_id: 1).with(no_args).and_yield(review_response_map)
        allow(review_response_map).to receive(:id).and_return(1)
        allow(Response).to receive_message_chain(:where, :last).with(map_id: 1).with(no_args).and_return(response)
        allow(response).to receive(:updated_at).and_return(Time.now)
        timevalue = Time.now.strftime('%a, %d %b %Y %H:%M')
        timeline_list = []
        for_each_author_feedback(1) do |response|
          timeline_list << response_modifier.call(response, "Author feedback")
        end
        expect(timeline_list).to eq([{ id: 1, label: 'Author feedback', updated_at: timevalue }])
      end
    end
  end

  # Verifies retrieval of timeline data
  describe '#generate_timeline' do
    context 'when no timeline data mapped' do
      it 'returns nil' do
        allow(participant).to receive(:get_reviewer).and_return(participant)
        expect(student_task_helper.generate_timeline(assignment, participant)).to eq([])
      end
    end
  end

    describe '#create_student_task_for_participant' do
    it 'creates a StudentTask with the correct attributes' do
      student_task = student_task_helper.create_student_task_for_participant(participant3)
      expect(student_task).to be_an_instance_of(StudentTask)
      expect(student_task.participant).to eq(participant3)
      expect(student_task.assignment).to eq(assignment)
      expect(student_task.topic).to eq(topic)
      expect(student_task.current_stage).to eq('submission')
      expect(student_task.stage_deadline).to eq(Time.parse('2024-12-31 12:00:00'))
    end
  end

  describe '#retrieve_tasks_for_user' do
    before do
      allow(user).to receive_message_chain(:assignment_participants, :includes).and_return([participant4, participant5])
    end

    it 'retrieves and sorts tasks by stage_deadline' do
      tasks = student_task_helper.retrieve_tasks_for_user(user)
      
      expect(tasks.size).to eq(2)
      expect(tasks.first.stage_deadline).to eq(Time.parse('2024-11-01 12:00:00'))
      expect(tasks.last.stage_deadline).to eq(Time.parse('2024-12-01 12:00:00'))
    end

    it 'creates StudentTask objects for each participant' do
      tasks = student_task_helper.retrieve_tasks_for_user(user)
      
      tasks.each do |task|
        expect(task).to be_an_instance_of(StudentTask)
        expect(task.participant).to be_in([participant4, participant5])
        expect(task.assignment).to eq(assignment)
        expect(task.topic).to eq(topic)
      end
    end
  end

  describe '#parse_stage_deadline' do
  context 'If a valid time value is given' do
    it 'parse the provided time correctly' do
      given_time = '2024-12-31 12:00:00'
      parsed_time = student_task_helper.parse_stage_deadline(given_time)
      expect(parsed_time).to eq(Time.parse(given_time))
    end
  end

  context 'If given time string is invalid' do
    it 'return current time plus 1 year' do
      given_time = 'invalid-time-string'
      overhead_time = Time.now + 1.year
      parsed_time = student_task_helper.parse_stage_deadline(given_time)
      expect(parsed_time).to be_within(1.second).of(overhead_time)
    end
  end
end

  # Tests teamed students method which returns the unique students that are paired with the student at some point
  # within their course
  describe '#group_teammates_by_course_for_user' do
    context 'when not in any team' do
      it 'returns empty' do
        expect(student_task_helper.group_teammates_by_course_for_user(user3)).to eq({})
      end
    end
    context 'when assigned in a course_team ' do
      it 'returns empty' do
        allow(user).to receive(:teams).and_return([course_team])
        expect(student_task_helper.group_teammates_by_course_for_user(user)).to eq({})
      end
    end
    context 'when assigned in a assignment_team ' do
      it 'returns the students they are teamed with' do
        allow(user).to receive(:teams).and_return([team])
        allow(AssignmentParticipant).to receive(:find_by).with(user_id: 1, parent_id: assignment.id).and_return(participant)
        allow(AssignmentParticipant).to receive(:find_by).with(user_id: 5, parent_id: assignment.id).and_return(participant2)
        allow(Assignment).to receive(:find_by).with(id: team.parent_id).and_return(assignment)
        expect(student_task_helper.group_teammates_by_course_for_user(user)).to eq(assignment.course_id => [user2.fullname])
      end
    end
  end
end
