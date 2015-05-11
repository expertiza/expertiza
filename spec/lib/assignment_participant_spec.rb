require 'rails_helper'

describe AssignmentParticipant do 
  let(:ap) { AssignmentParticipant.new }

  it "should be invalid without a handle" do
    assert !ap.valid?
  end

  it "should be valid with a handle" do
    ap.handle = "stu4"
    assert ap.valid?
  end

  it "should raise ArgumentError when no row passed in" do
    expect {AssignmentParticipant.import([],[],1)}.to raise_error(ArgumentError)
  end

  it "should raise ArgumentError when user is nil and row length less than 4" do
    User.stub(:where)
    expect {AssignmentParticipant.import(["not found"],[],1)}.to raise_error(ArgumentError)
  end

  it "should raise ImportError when assignment id is not found" do
    User.stub(:where).with(name: "a").and_return(stub(name: "D"))
    Assignment.stub(:find)
    expect {AssignmentParticipant.import(["a"],[],1)}.to raise_error(ImportError)
  end

  it "AssignmentParticipant should response to set_handle()" do
    a = AssignmentParticipant.create(user_id: 1, parent_id: 10)
    a.should respond_to(:set_handle)
  end

end