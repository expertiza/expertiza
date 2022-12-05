describe StudentQuizzesController do
    let(:assignment_participant) do  #Creating participants for assignment
        build(:assignment_participant, id: 36226, can_submit: true, can_review: true, user_id: 5, parent_id: 848)
    end
    let(:assignment) do #Creating assignment
        build(:assignment, id: 848, name: "Test 1", directory_path: "Test_1", submitter_count: 0, course_id: 68, instructor_id: 6, private: true, reviews_visible_to_all: false, num_reviewers: 0)
    end
    let(:response) do  #creating response for assignment
        build(:response, id: 96252, map_id: 130389, additional_comment: nil)
    end
    let(:question) do  #creating quiz question
        build(:question, id: 5841, txt: "Question - 1", weight: 1, questionnaire_id: 572 )
    end
    let(:quiz_questionnaire) { QuizQuestionnaire.new }  #creating questionnaire for assignment question
    let(:quiz_response_map) { build(:quiz_response_map, id: 130389, quiz_questionnaire: quiz_questionnaire, reviewee_id: 28012, reviewed_object_id: 572) }
    let(:student) do  #creating student
        build(:student, id: 5)
    end
    let(:student1) do #creating student1
        build(:student, id: 55)
    end
    let(:admin) {
        build(:admin, id: 7) #creating admin
    }
    let(:instructor) {
        build(:instructor, id: 6) #creating admin
    }
    describe "#action_allowed?" do
        it "when the current user is admin" do
            # To stub the user into session
            stub_current_user(admin, admin.role.name, admin.role)
            expect(controller.send(:action_allowed?)).to be true
        end

        it "when the current user is student" do
            # To stub the user into session
            stub_current_user(student, student.role.name, student.role)
            expect(controller.send(:action_allowed?)).to be true
        end
        
        it "when the current user is teaching assistant" do
            # To stub the user into session
            stub_current_user(student, student.role.name, student.role)
            expect(controller.send(:action_allowed?)).to be true
        
        it "when the current user is instructor" do
            # To stub the user into session
            stub_current_user(instructor, instructor.role.name, instructor.role)
            expect(controller.send(:action_allowed?)).to be true
        end
    end

    describe "GET index" do
        render_views
        it "call index method" do
            stub_current_user(student, student.role.name, student.role)
            controller.params = { id: '36226'}
            allow(AssignmentParticipant).to receive(:find).with('36226').and_return assignment_participant
            allow(Assignment).to receive(:find).with(848).and_return assignment
            allow(QuizResponseMap).to receive(:where).with(reviewer_id: 36226).and_return([quiz_response_map])
            result = get :index
            expect(response).to redirect_to('/')
            expect(result.status).to eq 302
        end
    end
end
