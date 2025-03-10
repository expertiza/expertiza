describe GradingHistoriesController do

  let(:grading_history) { build(:grading_history, graded_member_id: 1, graded_item_type: 'Submission') }
  let(:grading_history_review) { build(:grading_history, graded_member_id: 2, graded_item_type: 'Review') }
  let(:admin) { build(:admin) }
  let(:instructor) { build(:instructor, id: 6) }
  let(:ta) { build(:teaching_assistant, id: 8) }
  let(:student) { build(:student, id: 2, name: 'Joe') }
  let(:team) { build(:assignment_team, id: 1, assignment: assignment, users: [instructor], name: 'Team 1') }
  let(:assignment) do
    build(:assignment, id: 1, name: 'test assignment', instructor_id: 6, staggered_deadline: true, directory_path: 'test_assignment',
                       participants: [build(:participant)], teams: [build(:assignment_team)], course_id: 1)
  end

  describe "#action_allowed?" do
    context "when the current user is a super-administrator or an administrator" do
      it "returns true" do
        stub_current_user(admin, admin.role.name, admin.role)
        expect(controller.send(:action_allowed?)).to be true
      end
    end
  
    context "when the current user is an instructor" do
      it "returns true if the current user is the instructor of the assignment" do
        allow(GradingHistory).to receive(:assignment_for_history).and_return(assignment)
        stub_current_user(instructor, instructor.role.name, instructor.role)
        expect(controller.send(:action_allowed?)).to be true
      end
  
      it "returns true if the current user is a TA for the assignment" do
        stub_current_user(ta, ta.role.name, ta.role)
        allow(GradingHistory).to receive(:assignment_for_history).and_return(assignment)
        allow(TaMapping).to receive(:exists?).with(ta_id: 8, course_id: 1).and_return(true)
        allow(TaMapping).to receive(:where).and_return(ta)
        allow(ta).to receive(:first).and_return(ta)
        allow(ta).to receive(:include?).with(ta).and_return(true)
        expect(controller.send(:action_allowed?)).to be true
      end
  
      it "returns true if the current user is the instructor of the course" do
        stub_current_user(instructor, instructor.role.name, instructor.role)
        allow(GradingHistory).to receive(:assignment_for_history).and_return(assignment)
        allow(Course).to receive(:find).with(1).and_return(double('Course', instructor_id: 6))
        expect(controller.send(:action_allowed?)).to be true
      end
    end
  
    context "when the current user is not a super-administrator, administrator, instructor, or TA" do
      it "returns false" do
        stub_current_user(student, student.role.name, student.role)
        allow(GradingHistory).to receive(:assignment_for_history).and_return(assignment)
        expect(controller.send(:action_allowed?)).to be false
      end
    end
  
    context "when the type is 'Submission'" do
      it "sets @assignment to the assignment of the grade receiver" do
        allow(GradingHistory).to receive(:assignment_for_history).and_return(assignment)
        controller.params = { grade_type: 'Submission', graded_member_id: 2, participant_id: 1 }
        stub_current_user(instructor, instructor.role.name, instructor.role)
        expect(controller.send(:action_allowed?)).to be true
        expect(controller.instance_variable_get(:@assignment)).to be assignment
      end
    end
  
    context "when the type is 'Review'" do
      it "sets @assignment to the assignment of the grade receiver's parent" do
        allow(GradingHistory).to receive(:assignment_for_history).and_return(assignment)
        controller.params = { grade_type: 'Review', graded_member_id: 2, participant_id: 1 }
        stub_current_user(instructor, instructor.role.name, instructor.role)
        expect(controller.send(:action_allowed?)).to be true
        expect(controller.instance_variable_get(:@assignment)).to be assignment
      end
    end
  end
  describe "index" do
    context "when there are no grading histories" do
      it "sets @receiver and @assignment to empty strings" do
        request_params = { graded_member_id: 1, grade_type: 'Submission' }
        allow(GradingHistory).to receive(:assignment_for_history).and_return(assignment)
        empty_list = []
        allow(GradingHistory).to receive(:where).and_return(empty_list)
        allow(empty_list).to receive(:reverse_order).and_return([])
        stub_current_user(instructor, instructor.role.name, instructor.role)
        get :index, params: request_params
        expect(controller.instance_variable_get(:@assignment)).to eq ""
        expect(controller.instance_variable_get(:@receiver)).to eq ""
      end
    end

    context "when the most recent grading history is for a submission" do
      it "sets @receiver to the name of the team and @assignment to the name of the submission" do
        request_params = { graded_member_id: 1, grade_type: 'Submission' }
        allow(GradingHistory).to receive(:assignment_for_history).and_return(assignment)
        grading_history_list = [grading_history]
        allow(GradingHistory).to receive(:where).and_return(grading_history_list)
        allow(grading_history_list).to receive(:reverse_order).and_return(grading_history_list)
        allow(Team).to receive(:where).and_return(team)
        team_name = team.name
        allow(team).to receive(:pluck).and_return(team_name)
        allow(team_name).to receive(:first).and_return(team_name)
        allow(Assignment).to receive(:where).and_return(assignment)
        assignment_name = assignment.name
        allow(assignment).to receive(:pluck).and_return(assignment_name)
        allow(assignment_name).to receive(:first).and_return(assignment_name)
        stub_current_user(instructor, instructor.role.name, instructor.role)
        get :index, params: request_params
        expect(controller.instance_variable_get(:@assignment)).to eq "test assignment"
        expect(controller.instance_variable_get(:@receiver)).to eq "Graded Team: Team 1"
      end
    end
  
    context "when the most recent grading history is for a review" do
      it "sets @receiver to the name of the user and @assignment to the name of the assignment" do
        request_params = { graded_member_id: 2, grade_type: 'Review' }
        allow(GradingHistory).to receive(:assignment_for_history).and_return(assignment)
        grading_history_list = [grading_history_review]
        allow(GradingHistory).to receive(:where).and_return(grading_history_list)
        allow(grading_history_list).to receive(:reverse_order).and_return(grading_history_list)
        allow(User).to receive(:where).and_return(student)
        user_name = student.name
        allow(student).to receive(:pluck).and_return(user_name)
        allow(user_name).to receive(:first).and_return(user_name)
        allow(Assignment).to receive(:where).and_return(assignment)
        assignment_name = assignment.name
        allow(assignment).to receive(:pluck).and_return(assignment_name)
        allow(assignment_name).to receive(:first).and_return(assignment_name)
        stub_current_user(instructor, instructor.role.name, instructor.role)
        get :index, params: request_params
        expect(controller.instance_variable_get(:@assignment)).to eq "review for test assignment"
        expect(controller.instance_variable_get(:@receiver)).to eq "Graded User: Joe"
      end
    end
  end
end
