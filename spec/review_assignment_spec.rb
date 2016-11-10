#require 'spec_helper'
require 'rails_helper'


describe Assignment do include ReviewAssignment
  before(:all) do
  	@assign = Assignment.new
  	@assign.extend(ReviewAssignment)
  	@review = AssignmentParticipant.new
  end 
  	it "give the list of contributors" do
	 expect(@assign.candidate_assignment_teams_to_review(@review)).to be_kind_of(Array)
	end 
end
