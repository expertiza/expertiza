#E1731: Some preliminary tests. Need to verify if correct. Also need to add more test cases
require 'rails_helper'
# include GradesHelper

describe GradesController do
  before :each do
    controller.class.skip_before_filter :authorize
  end

  xit 'return score for an assignment' do
    assignmentParticipant = double(AssignmentParticipant)
    assignment = double(Assignment)
    allow(AssignmentParticipant).to receive("find").and_return (AssignmentParticipant)
    allow(assignmentParticipant).to receive(:assignment).and_return(assignment)
    allow(assignment).to receive("questionnaires").and_return([])
    allow(assignmentParticipant).to receive("scores").and_return([1, 2])
    @params = {id: 1}
    expect { get :edit, @params }.to eq([1, 2])
  end

  xit 'Check if scores stored in db' do
    assignment = double(Assignment)
    allow(assignmentParticipant).to receive(:assignment).and_return(assignment)
    allow(assignment).to receive("questionnaires").and_return([])
    allow(assignmentParticipant).to receive("scores").and_return([1, 2])
    post :store_total_scores, {assignment: assignment}
    expect (LocalDbScore.where(assignment: assignment)).to exist
  end

end