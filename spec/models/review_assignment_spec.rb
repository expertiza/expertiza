require 'rails_helper'


describe ReviewAssignment do
  before(:all) do
	
	@assign = Assignment.new
	@assign.extend(ReviewAssignment)
	@review = AssignmentParticipant.new
end
	it "give the list of contributors" do
	 expect(@test.candidate_assignment_teams_to_review(@review)).should be_kind_of "Array"
	end 
end
