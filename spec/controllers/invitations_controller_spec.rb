require 'rails_helper'

RSpec.describe InvitationsController, type: :controller do

  before(:each) do
    @instructor = create(:instructor)
    @student = create(:student)
    @assignment = create(:assignment)
    @assignment_team = create(:assignment_team, assignment: @assignment)
    @team_user = create(:team_user)
    @participant = create(:participant)
    @invitation = create(:invitation)
  end



  describe "GET /decline" do
    it "must decline invitation with invitation_id" do
      @inv = Invitation.new
      @inv.assignment_id = @assignment.id
      @inv.reply_status = 'W'
      @inv.save!
      get :decline, {:inv_id => @inv.id, :student_id => @student.id}
      expect(Invitation.find_by(assignment_id: @assignment.id).reload.reply_status).to eq('D')
    end
  end

  describe "check_decline_call" do
    it "must check something!" do
      expect(Invitation).to receive(:decline)
    end
  end



end
