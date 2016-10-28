require 'rails_helper'

describe "CourseParticipant" do

  describe "validations" do
    before(:each) do
      @course_participant = build(:course_participant)
    end
  end

  describe "#copy" do
    it "create a copy of participant" do
      assignment = build(:assignment)
      course_participant = build(:course_participant)
      course_participant2 = build(:course_participant)
      print course_participant["parent_id"]
      print course_participant2["parent_id"]
      csv = []
      options = {}
      options["personal_details"] = true
      options["role"] = true0000
      options["handle"] = true
      CourseParticipant.export(csv,course_participant["parent_id"],options)
      assignment_participant = build(:assignment_participant)
      #course_participant.copy(nil)
      #expect(course_participant.copy(assignment.id)).to be_nil
      #CourseParticipant.import(nil,nil,nil,nil)

    end
  end

  describe "#import" do

    it "raise error if record is empty" do
      row = []
      expect {CourseParticipant.import(row,nil,nil,nil)}.to raise_error("No user id has been specified.")
    end

    it "raise error if record does not have enough items " do
      row = ["user_name","user_fullname","name@email.com"]
      expect {CourseParticipant.import(row,nil,nil,nil)}.to raise_error("The record containing #{row[0]} does not have enough items.")
    end
  end

  it "raise error if course with id not found" do
    course = build(:course)
    session = {}
    row =[]
    allow(Course).to receive(:find).and_return(nil)
    allow(session[:user]).to receive(:id).and_return(1)
    row = ["user_name","user_fullname","name@email.com","user_role_name","user_parent_name"]
    expect {CourseParticipant.import(row,nil,session,2)}.to raise_error("The course with the id \"2\" was not found.")
  end

  it "creates course participant form record" do
    course = build(:course)
    session = {}
    row =[]
    allow(Course).to receive(:find).and_return(course)
    allow(session[:user]).to receive(:id).and_return(1)
    row = ["user_name","user_fullname","name@email.com","user_role_name","user_parent_name"]
    course_part = CourseParticipant.import(row,nil,session,2)
    expect(course_part).to be_an_instance_of(CourseParticipant)
  end

end