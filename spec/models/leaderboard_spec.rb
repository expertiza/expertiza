require 'rails_helper'

describe Leaderboard do
  #let(:leaderboard) { Leaderboard.new questionnaire_type_id: 1, name: "test", qtype: "qtype" }
  before(:each) do
    @student = create(:student)
    @instructor = create(:instructor)
    @course = create(:course)
    @assignment = create(:assignment, course: nil)
    @assignment2 = create(:assignment)
    @participant = create(:participant)
    @questionnaire=create(:questionnaire)
    @assignment_questionnaire =create(:assignment_questionnaire, user_id: @student.id, assignment: @assignment)
    @leaderboard = Leaderboard.new questionnaire_type_id: 1, name: "test", qtype: "qtype"
  end
  #let(:student){create(:student)}
  #let(:instructor){create(:instructor)}
  #let(:course){create(:course)}
  #let(:assignment){create(:assignment)}
  #let(:participant){create(:participant)}
  #let(:questionnaire){create(:questionnaire)}
  #let(:assignment_questionnaire){create(:assignment_questionnaire)}


  it "getIndependantAssignment should return no assignments" do
    expect(Leaderboard.getIndependantAssignments(1)).to have(0).items

  end

  it "getIndependantAssignment should return an assignments" do
    #student = build(:student)
    #instructor = build(:instructor)
    #course = build(:course)
    #assignment = build(:assignment, course: nil)
    #participant = build(:participant)
    #questionnaire=build(:questionnaire)
    #assignment_questionnaire =build(:assignment_questionnaire)
        expect(Leaderboard.getIndependantAssignments(@student.id)).to have(1).items

  end

  it "getAssignmentsInCourses should return an assignment" do


    expect(Leaderboard.getAssignmentsInCourses(1)).to have(1).items

  end

  it "leaderboardHeading should return No Entry" do
    leaderboard = Leaderboard.new questionnaire_type_id: 1, name: "test", qtype: "qtype"
    expect(Leaderboard.leaderboardHeading("test")).to eq("No Entry")

  end
  it "leaderboardHeading should return name" do
    #@leaderboard = Leaderboard.new questionnaire_type_id: 1, name: "test", qtype: "qtype"
    expect(Leaderboard.leaderboardHeading(@leaderboard.qtype)).to eq("test")
  end

  it "Leaderboard responds to getIndependantAssignment" do

    expect(Leaderboard).to respond_to(:getIndependantAssignments).with(1).argument

  end

  it "Leaderboard responds to getAssignmentsInCourses" do

    expect(Leaderboard).to respond_to(:getAssignmentsInCourses).with(1).argument

  end
  it "Leaderboard responds to getParticipantEntriesInCourses" do

    expect(Leaderboard).to respond_to(:getParticipantEntriesInCourses).with(2).argument

  end

  it "Leaderboard responds to getParticipantEntriesInAssignment" do

    expect(Leaderboard).to respond_to(:getParticipantEntriesInAssignment).with(1).argument

  end

  it "Leaderboard responds to getParticipantsScore" do

    expect(Leaderboard).to respond_to(:getParticipantsScore).with(1).argument

  end

  it "Leaderboard responds to addScoreToResultantHash" do

    expect(Leaderboard).to respond_to(:addScoreToResultantHash).with(5).argument

  end
  it "Leaderboard responds to getAssignmentMapping" do

    expect(Leaderboard).to respond_to(:getAssignmentMapping).with(3).argument

  end

  it "Leaderboard responds to sortHash" do

    expect(Leaderboard).to respond_to(:sortHash).with(1).argument

  end
  it "Leaderboard responds to extractPersonalAchievements" do

    expect(Leaderboard).to respond_to(:extractPersonalAchievements).with(3).argument

  end

  it "Leaderboard responds to leaderboardHeading" do

    expect(Leaderboard).to respond_to(:leaderboardHeading).with(1).argument

  end

end