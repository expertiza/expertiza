require 'rspec'

describe InvitationController do
  describe "invitation request" do
    context "when a user sends an invitation" do
      it "calls the accept_invitation method" do
        expect(accept_invitation).with(AssignmentParticipant.find(params[:student_id][:email]))
      end
    end

    context "when a user accepts the invitation" do
      it "calls the accepted_invitation method" do
        expect(accepted_invitation).with(Participant.find(params[:student_id]))
      end
    end
  end

  describe "create invitation" do
    it "should deliver an invitation email to the user" do
      invitation_attributes = FactoryGirl.attributes_for(:to, :subject, :body)
      mailer = mock(Mailer)
      mailer.should_receive(:deliver).with(accept_invitation(invitation_attributes))
    end
  end

  describe "respond invitation" do
    it "should deliver an reponse to invitation email to the requested user" do
      invitation_attributes = FactoryGirl.attributes_for(:to, :subject, :body)
      mailer = mock(Mailer)
      mailer.should_receive(:deliver).with(accepted_invitation(invitation_attributes))
    end
  end
end

