# As scoped for issue E1781, we will test the aspects of the assessment360
# controller used for the course_student_grade_summary view and feature.
# We aren't going to write the tests for functions used for all_students_all_reviews.
# If you are a student writing that functionality, feel free to remove this comment!

describe Assessment360Controller do
  let(:instructor) { build(:instructor, id: 6) }
  let(:course) { double('Course', instructor_id: 6, path: '/cscs', name: 'abc', id: 1) }
  let(:assignment) { build(:assignment, id: 1, instructor_id: 6, due_dates: [due_date], microtask: true, staggered_deadline: true) }
  let(:assignment_list) { [assignment] }
  let(:due_date) { build(:assignment_due_date, deadline_type_id: 1) }
  let(:course_participant) { build(:course_participant) }
  let(:student1) { build(:student, id: 1, name: :lily) }

  describe '#all_students_all_reviews' do
    context 'when course does not have participants' do
      before(:each) do
        request.env['HTTP_REFERER'] = 'http://example.com'
        get "all_students_all_reviews"
      end

      it 'redirects to back' do
        expect(response).to redirect_to(:back)
      end

      it 'flashes an error' do
        expect(flash[:error]).to be_present
      end
    end

    context 'method is called' do
      before(:each) do
        request.env['HTTP_REFERER'] = 'http://example.com'
        get "course_student_grade_summary"
      end

      it 'redirects to back and flashes error as there are no participants' do
        allow(Course).to receive(:find).with("1").and_return(course)
        allow(course).to receive(:assignments).and_return(assignment_list)
        allow(assignment_list).to receive(:reject).and_return(assignment_list)
        allow(course).to receive(:get_participants).and_return([]) #no participants
        params = {course_id: 1}
        session = {user: instructor}
        get :all_students_all_reviews, params, session
        expect(controller.send(:action_allowed?)).to be true
        expect(response).to redirect_to(:back)
        expect(flash[:error]).to be_present
      end

      it 'has participants, next assignment participant does not exist, and avoids divide by zero' do
        allow(Course).to receive(:find).with("1").and_return(course)
        allow(course).to receive(:assignments).and_return(assignment_list)
        allow(assignment_list).to receive(:reject).and_return(assignment_list)
        allow(course).to receive(:get_participants).and_return([course_participant]) #has participants
        allow(StudentTask).to receive(:teamed_students).with(course_participant.user).and_return(student1)
        params = {course_id: 1}
        session = {user: instructor}
        get :all_students_all_reviews, params, session
        expect(controller.send(:action_allowed?)).to be true
        expect(response.status).to eq(200)
      end
    end
  end

  describe '#course_student_grade_summary' do
    context 'when course does not have participants' do
      before(:each) do
        request.env['HTTP_REFERER'] = 'http://example.com'
        get "course_student_grade_summary"
      end

      it 'redirects to back' do
        expect(response).to redirect_to(:back)
      end

      it 'flashes an error' do
        expect(flash[:error]).to be_present
      end
    end

    context 'method is called' do
      before(:each) do
        request.env['HTTP_REFERER'] = 'http://example.com'
        get "course_student_grade_summary"
      end

      it 'redirects to back and flashes error as there are no participants' do
        allow(Course).to receive(:find).with("1").and_return(course)
        allow(course).to receive(:assignments).and_return([assignment])
        allow(assignment).to receive(:reject).and_return(assignment)
        allow(course).to receive(:get_participants).and_return([]) #no participants
        params = {course_id: 1}
        session = {user: instructor}
        get :course_student_grade_summary, params, session
        expect(controller.send(:action_allowed?)).to be true
        expect(response).to redirect_to(:back)
        expect(flash[:error]).to be_present
      end
    end
  end
end

