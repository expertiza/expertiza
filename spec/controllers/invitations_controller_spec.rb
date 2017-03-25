require 'rails_helper'

RSpec.describe InvitationsController, type: :controller do

  describe "Invitaton decline" do
    it "should change status to D" do
      @inv = Invitation.new(reply_status: 'W')
      @inv.save
      get :decline, params = {inv_id: @inv.id}
      expect(@inv.reply_status).to eq('D')
    end
  end
end
