require 'spec_helper'



def valid_sign_up_topic
  SignUpTopic.new(topic_name: 'foo',
                  assignment_id: 1,
                  max_choosers: 1,
                  category: 'foobar',
                  topic_identifier: 1)
end

def valid_due_date
  DueDate.new(deadline_type_id: 1,
              assignment_id: 1,
              round: 1)
end

def valid_assignment
  Assignment.new(:name => "assignment",
                 :course_id           => 1,
                 :directory_path      => "assignment",
                 :review_questionnaire_id    => 1,
                 :review_of_review_questionnaire_id => 1,
                 :author_feedback_questionnaire_id  => 1,
                 :instructor_id => 1,
                 :course_id => 1,
                 :wiki_type_id => 1)
end

describe AssignmentFormObject do
  # Make sure that we can get a valid sign_up_topic
  describe "when there is a valid sign_up_topic" do
    before do
      @sign_up_topic = valid_sign_up_topic
    end
    subject{@sign_up_topic}
    it {should be_valid}
  end

  # Make sure that we can get a valid due_date
  describe "when there is a valid due_date" do
    before do
      @due_date = valid_due_date
    end
    subject{@due_date}
    it {should be_valid}
  end

  # Make sure that we can get a valid assignment
  describe "when there is a valid assignment" do
    before do
      @assignment = valid_assignment
    end
    subject{@assignment}
    it {should be_valid}
  end

  describe "assignment form object" do
    before do
      @form = AssignmentFormObject.new()
    end

    subject{@form}

    it {should respond_to(:assignment)}
    it {should respond_to(:due_dates_list)}
    it {should respond_to(:topics_list)}

    describe "when assignment is missing" do
      before {@form.assignment = nil}
      it {should_not be_valid}
    end

    describe "when assignment is present" do
      before do
        @form = AssignmentFormObject.new(assignment: valid_assignment)
      end

      it {should be_valid}
      specify{ expect(@form.assignment.valid?).to eq true}
      specify{ expect(@form.assignment.name).to eq valid_assignment.name }
      specify{ expect(@form.assignment.course_id).to eq valid_assignment.course_id}
    end

    describe "when adding signup topics" do

      describe "and signup topics are all valid" do
        before do
          topic = valid_sign_up_topic
          @form = AssignmentFormObject.new(assignment: valid_assignment)
          @form.add_topic(topic)
        end

        it{should be_valid}
      end

      describe "and signup topics are not valid" do
        before do
          invalid_topic = valid_sign_up_topic
          invalid_topic.topic_name = nil
          @form = AssignmentFormObject.new(assignment: valid_assignment)
          @form.add_topic(invalid_topic)
        end

        it {should_not be_valid}
      end

    end

    describe "when adding due dates" do

      describe "and due dates are all valid" do
        before do
          due_date = valid_due_date
          @form = AssignmentFormObject.new(assignment: valid_assignment)
          @form.add_due_date(due_date)
        end

        it {should be_valid}
      end

      describe "and due dates are not valid" do
        # Not sure how to create an invalid due_date. It only validates 'due_at', but I couldn't get that
        # to be invalid
      end
    end

  end




end
