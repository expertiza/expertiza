require 'rails_helper'

describe "validations" do
  before(:each) do
    @assignment = build(:assignment)
  end

  it "assignment is valid" do
    expect(@assignment).to be_valid
  end

  it "assignment without name is not valid" do
    @assignment.name = nil
    @assignment.save
    expect(@assignment).not_to be_valid
  end

  it "checks whether Assignment Team is created or not" do
    expect(create(:assignment_team)).to be_valid
  end

  it "checks whether signed up topic is created or not" do
    expect(create(:topic)).to be_valid
  end

  it "checks whether num_reviews_allowed and num_reviews_required is valid or not" do
    @assignment.num_reviews_required = 2
    @assignment.num_reviews_allowed = 5
    expect(@assignment).to be_valid
    # indicated infinite upperbouned
    @assignment.num_reviews_allowed = -1
    expect(@assignment).to be_valid
  end

  it "checks whether num_meta_reviews_allowed and num_meta_reviews_required is valid or not" do
    @assignment.num_metareviews_allowed = 3
    @assignment.num_metareviews_required = 1
    expect(@assignment).to be_valid
    @assignment.num_metareviews_allowed = -1 # indicated infinite upperbouned
    expect(@assignment).to be_valid
  end

  it "check whether assignment doesnot accept required value greater than allowed value - Review" do
    @assignment.num_reviews_allowed = 2
    @assignment.num_reviews_required = 5
    expect(@assignment).not_to be_valid
  end

  it "check whether assignment doesnot accept required value greater than allowed value - Meta-Review" do
    @assignment.num_metareviews_allowed = 1
    @assignment.num_metareviews_required = 3
    expect(@assignment).not_to be_valid
  end
end

describe "#team_assignment" do
  it "checks an assignment has team" do
    assignment = build(:assignment)
    expect(assignment.team_assignment).to be true
  end
end

describe "#has_teams?" do
  it "checks an assignment has a team" do
    assignment = build(:assignment)
    assign_team = build(:assignment_team)
    assignment.teams << assign_team
    expect(assignment.has_teams?).to be true
  end
end

describe "#has_topics?" do
  it "checks an assignment has a topic" do
    assignment = build(:assignment)
    topic = build(:topic)
    assignment.sign_up_topics << topic
    expect(assignment.has_topics?).to be true
  end
end

describe "#is_google_doc" do
  it "checks whether assignment is a google doc" do
    skip('#is_google_doc no longer exists in assignment.rb file.')
    assignment = build(:assignment)
    res = assignment.is_google_doc
    expect(res).to be false
  end
end

describe "#is_microtask?" do
  it "checks whether assignment is a micro task" do
    assignment = build(:assignment, microtask: true)
    expect(assignment.is_microtask?).to be true
  end
end

describe "#dynamic_reviewer_assignment?" do
  it "checks the Review Strategy Assignment" do
    assignment = build(:assignment)
    expect(assignment.dynamic_reviewer_assignment?).to be true
  end
end

describe "#is_coding_assignment?" do
  it "checks assignment is coding assignment or not" do
    assignment = build(:assignment)
    expect(assignment.is_coding_assignment?).to be false
  end
end

describe "#candidate_assignment_teams_to_review" do
  it "returns nil if if there are no contributors" do
    assignment = build(:assignment)
    reviewer = build(:participant)
    cand_team = assignment.candidate_assignment_teams_to_review(reviewer)
    expect(cand_team).to be_empty
  end
end

describe "#candidate_topics_for_quiz" do
  it "returns nil if sign up topic is empty" do
    assignment = build(:assignment)
    cand_topic = assignment.candidate_topics_for_quiz
    expect(cand_topic).to be_nil
  end
end

describe "#check if the assignment belongs to a course" do
  it "returns false if assignment does not have a course" do
    assignment_node = AssignmentNode.new
    assignment = build(:assignment)
    assignment.course_id = nil
    assignment.save
    assignment_node.node_object_id = assignment.id
    expect(assignment_node.belongs_to_course?).to be false
  end

  it "returns true if assignment does have a course" do
    assignment_node = AssignmentNode.new
    assignment = build(:assignment)
    assignment.course_id = 1
    assignment.save
    assignment_node.node_object_id = assignment.id
    expect(assignment_node.belongs_to_course?).to be true
  end
end

describe "has correct csv values?" do
  before(:each) do
    @assignment = create(:assignment)
    create(:assignment_team, name: "team1")
    @student = create(:student, name: "student1")
    create(:participant, user: @student)
    create(:questionnaire)
    create(:question)
    create(:review_response_map)
    create(:response)
    @options = {"team_id" => "true", "team_name" => "true",
                "reviewer" => "true", "question" => "true",
                "question_id" => "true", "comment_id" => "true",
                "comments" => "true", "score" => "true"}
  end

  def generated_csv(t_assignment, t_options)
    delimiter = ","
    CSV.generate(col_sep: delimiter) do |csv|
      csv << Assignment.export_headers(t_assignment.id)
      csv << Assignment.export_details_fields(t_options)
      Assignment.export_details(csv, t_assignment.id, t_options)
    end
  end

  it "checks_if_csv has the correct data" do
    create(:answer, comments: "Test comment")
    expected_csv = File.read('spec/features/assignment_export_details/expected_details_csv.txt')
    expect(generated_csv(@assignment, @options)).to eq(expected_csv)
  end

  it "checks csv with some options" do
    create(:answer, comments: "Test comment")
    @options["team_id"] = "false"
    @options["question_id"] = "false"
    @options["comment_id"] = "false"
    expected_csv = File.read('spec/features/assignment_export_details/expected_details_some_options_csv.txt')
    expect(generated_csv(@assignment, @options)).to eq(expected_csv)
  end

  it "checks csv with no data" do
    expected_csv = File.read('spec/features/assignment_export_details/expected_details_no_data_csv.txt')
    expect(generated_csv(@assignment, @options)).to eq(expected_csv)
  end

  it "checks csv with data and no options" do
    create(:answer, comments: "Test comment")
    @options["team_id"] = "false"
    @options["team_name"] = "false"
    @options["reviewer"] = "false"
    @options["question"] = "false"
    @options["question_id"] = "false"
    @options["comment_id"] = "false"
    @options["comments"] = "false"
    @options["score"] = "false"
    expected_csv = File.read('spec/features/assignment_export_details/expected_details_no_options_csv.txt')
    expect(generated_csv(@assignment, @options)).to eq(expected_csv)
  end
end
