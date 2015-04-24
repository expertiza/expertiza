require 'rails_helper'

describe Assignment do 
  let(:assignment) { Assignment.new }

  it "should be invalid without a name" do
    assert !assignment.valid?
  end

  it "should be valid with a name" do
    assignment.name = "New Student"
    assert assignment.valid?
  end

  it "should raise 'Path cannot be created...' Error if course_id and instructor_id are nil" do 
    assignment.instructor_id = nil
    assignment.course_id = nil
    expect{assignment.path}.to raise_error('Path cannot be created. The assignment must be associated with either a course or an instructor.')
  end

  it "should raise PathError if wiki_type is not 1" do 
    assignment.instructor_id = 10
    assignment.course_id = nil
    assignment.wiki_type_id = 2
    expect{assignment.path}.to raise_error(PathError)
  end

end