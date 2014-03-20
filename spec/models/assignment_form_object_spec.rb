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
      #attributes = {}
      #attributes[:assignment] = valid_assignment
      @form = AssignmentFormObject.new()
    end

    subject{@form}

    it {should respond_to(:assignment)}
    it {should respond_to(:due_dates)}
    it {should respond_to(:topics)}

    describe "when assignment is missing" do
      before {@form.assignment = nil}
      it {should_not be_valid}
    end

    describe "when assignment is present" do
      before {@form.assignment = valid_assignment}
      it {should be_valid}
    end

    #it {should respond_to(:assignment_name)}

    #describe "when assignment_name is not present" do
    # before{@form.assignment_name = " "}
    # it {should_not be_valid}
    #end
  end




end
