require 'rails_helper'

describe Leaderboard do
  #let(:leaderboard) { Leaderboard.new questionnaire_type_id: 1, name: "test", qtype: "qtype" }
  before(:each) do
    @student1 = create(:student, name: "Student1", fullname: "Student1 Test", email: "student1@mail.com" )
    @student2 = create(:student, name: "Student2", fullname: "Student2 Test", email: "student2@mail.com" )
    @instructor = create(:instructor)
    @course = create(:course)
    @assignment = create(:assignment, name: "Assign1", course: nil)
    @assignment2 = create(:assignment, name: "Assign2")
    @participant = create(:participant, parent_id: @assignment.id, user_id: @student1.id)
    @participant2 = create(:participant, parent_id: @assignment2.id, user_id: @student2.id)
    @questionnaire=create(:questionnaire)
    @assignment_questionnaire1 =create(:assignment_questionnaire, user_id: @student1.id, assignment: @assignment)
    @assignment_questionnaire2 =create(:assignment_questionnaire, user_id: @student2.id, assignment: @assignment2)
    @assignment_team = create(:assignment_team, name: "TestTeam", parent_id: @assignment.id)
    @team_user = create(:team_user, team_id: @assignment_team.id, user_id: @student1.id)
  end
  #let(:student){create(:student)}
  #let(:instructor){create(:instructor)}
  #let(:course){create(:course)}
  #let(:assignment){create(:assignment)}
  #let(:participant){create(:participant)}
  #let(:questionnaire){create(:questionnaire)}
  #let(:assignment_questionnaire){create(:assignment_questionnaire)}


  it "getIndependantAssignment should return no assignments" do
    expect(Leaderboard.get_independant_assignments(@student2.id)).to have(0).items

  end

  it "getIndependantAssignment should return an assignments" do
    #puts Assignment.where(course_id: nil).inspect
    #puts AssignmentParticipant.where(user_id: @student1.id).inspect
    expect(Leaderboard.get_independant_assignments(@student1.id)).to have(1).items



  end

  it "getAssignmentsInCourses should return an assignment" do
    expect(Leaderboard.get_assignments_in_courses(1)).to have(1).items
  end

  # This method currently fails because there is no ScoreCache define anywhere in the program
  # This is called in get_participants_score method
  it "get_part_entries_in_courses should return two entries" do
    expect(Leaderboard.get_part_entries_in_courses(1,@student1.id)).to have(2).items
  end

  #This method currently fails because there is no get_participant_entries_in_assignment_list.
  it "get_part_entries_in_assignment should return one entries" do
    assign_list = []
    assign_list << Assignment.find(@assignment.id)
    part_list = []
    part_list << AssignmentParticipant.where(id: @participant.id)
    allow(Leaderboard).to receive(:get_participant_entries_in_assignment_list).and_return(part_list).with(assign_list)
    expect(Leaderboard.get_part_entries_in_assignment(@assignment.id)).to have(1).items

  end

  it "get_part_entries_in_assignment should return two entries" do
    assign_list = []
    assign_list << Assignment.find(@assignment.id)
    part_list = []
    part_list << AssignmentParticipant.where(id: @participant.id)
    team_list = []
    team_list << AssignmentTeam.where(id: 1)
    allow(AssignmentParticipant).to receive(:id).and_return(1)
    allow(AssignmentParticipant).to receive(:parent_id).and_return(1)
    allow(AssignmentTeam).to receive(:id).and_return(1)
    allow(AssignmentTeam).to receive(:parent_id).and_return(1)
    #puts team_list.inspect
    expect(Leaderboard.get_assignment_mapping(assign_list, part_list, team_list)).to have(2).items

  end

  it "leaderboard_heading should return No Entry with invalid input" do
    expect(Leaderboard.leaderboard_heading("test")).to eq("No Entry")
  end

  it "leaderboard_heading should return name" do
    allow(Leaderboard).to receive(:find_by_qtype).and_return(@questionnaire).with(@questionnaire.id)
    expect(Leaderboard.leaderboard_heading(@questionnaire.id)).to eq("Test questionaire")
  end

  it "Leaderboard responds to get_independant_assignments" do

    expect(Leaderboard).to respond_to(:get_independant_assignments).with(1).argument

  end

  it "Leaderboard responds to get_assignments_in_courses" do

    expect(Leaderboard).to respond_to(:get_assignments_in_courses).with(1).argument

  end
  it "Leaderboard responds to get_part_entries_in_courses" do

    expect(Leaderboard).to respond_to(:get_part_entries_in_courses).with(2).argument

  end

  it "Leaderboard responds to get_part_entries_in_assignment" do

    expect(Leaderboard).to respond_to(:get_part_entries_in_assignment).with(1).argument

  end

  it "Leaderboard responds to get_participants_score" do

    expect(Leaderboard).to respond_to(:get_participants_score).with(1).argument

  end

  it "Leaderboard responds to add_score_to_resultant_hash" do

    expect(Leaderboard).to respond_to(:add_score_to_resultant_hash).with(5).argument

  end
  it "Leaderboard responds to get_assignment_mapping" do

    expect(Leaderboard).to respond_to(:get_assignment_mapping).with(3).argument

  end

  it "Leaderboard responds to sort_hash" do

    expect(Leaderboard).to respond_to(:sort_hash).with(1).argument

  end
  it "Leaderboard responds to extract_personal_achievements" do

    expect(Leaderboard).to respond_to(:extract_personal_achievements).with(3).argument

  end

  it "Leaderboard responds to leaderboard_heading" do

    expect(Leaderboard).to respond_to(:leaderboard_heading).with(1).argument

  end


end