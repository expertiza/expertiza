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
  let(:team2) { create(:assignment_team, id: 2, name: 'team 2', parent_id: assignment2.id, users: [user3]) }
  let(:review_response_map) { build(:review_response_map, assignment: assignment, reviewer: participant, reviewee: team2) }
  let(:response) { build(:response, id: 1, map_id: 1, response_map: review_response_map) }

  # Gets the due dates of an assignment
  describe '#update_timeline_with_assignment_deadlines' do
    context 'when called with assignment having empty due dates' do
      it 'return empty time_list array' do
        timeline_list = []
        student_task_helper.update_timeline_with_assignment_deadlines(assignment, timeline_list)
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
          student_task_helper.update_timeline_with_assignment_deadlines(assignment, timeline_list)
          expect(timeline_list).to eq([])
        end
      end
      context 'and due_at value not nil' do
        it 'return time_list array' do
          allow(due_date).to receive(:deadline_type).and_return(deadline_type)
          timeline_list = []
          assignment.due_dates = [due_date]
          student_task_helper.update_timeline_with_assignment_deadlines(assignment, timeline_list)
          expect(timeline_list).to eq([{
                                        label: (due_date.deadline_type.name + ' Deadline').humanize,
                                        updated_at: due_date.due_at.strftime('%a, %d %b %Y %H:%M')
                                      }])
        end
      end
    end
  end

  # Verifies fetching of peer review data of a user and a timeline
  describe '#update_timeline_with_peer_reviews' do
    context 'when no review response mapped' do
      it 'returns empty' do
        timeline_list = []
        student_task_helper.update_timeline_with_peer_reviews(user2, timeline_list)
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
        expect(student_task_helper.update_timeline_with_peer_reviews(1, timeline_list)).to eq([{ id: 1, label: 'Round 1 peer review', updated_at: timevalue }])
      end
    end
  end

  # Verifies retrieval of feedback from author
  describe '#update_timeline_with_author_feedbacks' do
    context 'when no feedback response mapped' do
      it 'returns empty' do
        timeline_list = []
        student_task_helper.update_timeline_with_author_feedbacks(user2, timeline_list)
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
        expect(student_task_helper.update_timeline_with_author_feedbacks(1, timeline_list)).to eq([{ id: 1, label: 'Author feedback', updated_at: timevalue }])
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
end
