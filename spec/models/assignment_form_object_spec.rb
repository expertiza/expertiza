require 'spec_helper'

# Note that at the time of this writing, something is wrong
# with have 'describe AssignmentFormObject' without quotes
# around class name.
describe "AssignmentFormObject" do
  it "should pass trivial test" do
    true_value = true
    true_value.should == true
  end
end
