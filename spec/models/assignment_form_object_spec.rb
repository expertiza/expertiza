require 'spec_helper'

# Note that at the time of this writing, something is wrong
# with have 'describe AssignmentFormObject' without quotes
# around class name.
describe AssignmentFormObject do

  before{@form = AssignmentFormObject.new(assignment_name: 'name')}

  subject{@form}

  it {should respond_to(:assignment)}
  it {should respond_to(:due_dates)}
  it {should respond_to(:topics)}
  it {should respond_to(:assignment_name)}

  describe "when assignment_name is not present" do
    before{@form.assignment_name = " "}
    it {should_not be_valid}
  end
end
