# As scoped for issue E1781, we will test the aspects of the assessment360
# controller used for the course_student_grade_summary view and feature.
# We aren't going to write the tests for functions used for all_students_all_reviews.
# If you are a student writing that functionality, feel free to remove this comment!

describe Assessment360Controller do
  # course_student_grade_summary
  # Inputs: course_id
  # Returns: doesn't matter
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

    context 'when course has participants' do
      let(:instructor) { build(:instructor, id: 6) }

      before(:each) do
        stub_current_user(instructor, instructor.role.name, instructor.role)
        @course = create(:course, name: 'test course')
        @assignment = create(:assignment, course: @course)
        @topic = create(:topic, assignment: @assignment)
        @student = create(:student)
        @course.add_participant(@student.name)
        @assignment_participant = create(:participant)
        @signed_up_team = create(:signed_up_team)
        params = {course_id: @course.id}
        get "course_student_grade_summary", params
      end

      # We need to reference CourseParticipant.first because we can't find a CourseParticipant
      # by the @student's name.
      it 'puts course_participant in :course_participants' do
        expect(assigns(:course_participants)).to include CourseParticipant.first
      end

      it 'puts the assignment\'s topic id in :topic_id{}' do
        expect(assigns(:topic_id)).to include @topic.id
      end

      it 'puts the assignment\'s topic name in :topic_name{}' do
        # expect(assigns(:topic_name)).to include @topic.topic_name
      end

      it 'makes assignment grades not empty' do

      end

      it 'makes peer review scores not empty' do

      end

      it 'makes final grades not empty' do

      end

      it 'makes final peer review scores not empty' do

      end

    end
  end
end

