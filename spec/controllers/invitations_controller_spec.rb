require 'rails_helper'

RSpec.describe InvitationsController, type: :controller do

  before(:each) do
    @instructor = create(:instructor)
    @student = create(:student)
    @assignment = create(:assignment)
    @assignment_team = create(:assignment_team, assignment: @assignment)
    @team_user = create(:team_user)
    @participant = create(:participant)
  end

  describe "decline_invitation" do
    it "must decline invitation with invitation_id" do
      @inv = Invitation.new(assignment_id: @assignment.id, reply_status: 'W')
      @inv.save!
      get :decline, :inv_id => @inv.id, :student_id => @student.id
      temp = Invitation.find(@inv.id)
      expect(temp.reply_status).to eq('D')
    end
  end

end
