require 'rails_helper'

describe AssignmentForm do
  let(:assignment) { Assignment.new }
  let(:assignment_questionnaire) { AssignmentQuestionnaire.new }
  let(:due_date) { DueDate.new }
  let(:user) { User.new }
  let(:assignment_form) do
    AssignmentForm.new(
      assignment: assignment,
      assignment_questionnaires: [assignment_questionnaire],
      due_dates: [due_date]
    )
  end

  describe ".create_form_object" do
    it "creates a new form object" do
      expect(Assignment).to receive(:find).and_return assignment
      expect(assignment).to receive(:staggered_deadline)
      expect(assignment).to receive(:staggered_deadline=)
      expect(assignment).to receive(:availability_flag)
      expect(assignment).to receive(:availability_flag=)
      expect(assignment).to receive(:microtask)
      expect(assignment).to receive(:microtask=)
      expect(assignment).to receive(:reviews_visible_to_all)
      expect(assignment).to receive(:reviews_visible_to_all=)
      expect(assignment).to receive(:review_assignment_strategy)
      expect(assignment).to receive(:review_assignment_strategy=)
      expect(assignment).to receive(:require_quiz)
      expect(assignment).to receive(:require_quiz=)
      expect(assignment).to receive(:num_quiz_questions=)
      expect(assignment).to receive(:find_due_dates).at_least(:once).and_return due_date
      # expect(due_date).to receive(:+).at_least(:once).and_return due_date
      expect(due_date).to receive(:count).at_least(:once)
      expect(assignment).to receive(:rounds_of_reviews=)
      expect(assignment).to receive(:directory_path)
      expect(assignment).to receive(:rounds_of_reviews)
      AssignmentForm.create_form_object 0
    end
  end

  describe "#create_assignment_node" do
    it "creates an assignment node" do
      expect(Assignment).to receive(:new).and_return assignment
      expect(assignment).to receive(:create_node)
      assignment_form.create_assignment_node
    end
  end

  describe ".set_up_defaults" do
    it "sets up default values" do
      expect(Assignment).to receive(:new).and_return assignment
      expect(assignment).to receive(:staggered_deadline)
      expect(assignment).to receive(:staggered_deadline=)
      expect(assignment).to receive(:availability_flag)
      expect(assignment).to receive(:availability_flag=)
      expect(assignment).to receive(:microtask)
      expect(assignment).to receive(:microtask=)
      expect(assignment).to receive(:reviews_visible_to_all)
      expect(assignment).to receive(:reviews_visible_to_all=)
      expect(assignment).to receive(:review_assignment_strategy)
      expect(assignment).to receive(:review_assignment_strategy=)
      expect(assignment).to receive(:require_quiz)
      expect(assignment).to receive(:require_quiz=)
      expect(assignment).to receive(:num_quiz_questions=)
      assignment_form.set_up_defaults
    end
  end

  describe "#set_up_assignment_review" do
    it "set up assignment review" do
      expect(Assignment).to receive(:new).and_return assignment
      expect(assignment).to receive(:staggered_deadline)
      expect(assignment).to receive(:staggered_deadline=)
      expect(assignment).to receive(:availability_flag)
      expect(assignment).to receive(:availability_flag=)
      expect(assignment).to receive(:microtask)
      expect(assignment).to receive(:microtask=)
      expect(assignment).to receive(:reviews_visible_to_all)
      expect(assignment).to receive(:reviews_visible_to_all=)
      expect(assignment).to receive(:review_assignment_strategy)
      expect(assignment).to receive(:review_assignment_strategy=)
      expect(assignment).to receive(:require_quiz)
      expect(assignment).to receive(:require_quiz=)
      expect(assignment).to receive(:num_quiz_questions=)
      expect(assignment).to receive(:find_due_dates).at_least(:once).and_return due_date
      # expect(due_date).to receive(:+).at_least(:once).and_return due_date
      expect(due_date).to receive(:count).at_least(:once)
      expect(assignment).to receive(:rounds_of_reviews=)
      expect(assignment).to receive(:directory_path)
      expect(assignment).to receive(:rounds_of_reviews)
      assignment_form.set_up_assignment_review
    end
  end
end
