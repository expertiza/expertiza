require 'rspec'

describe InvitationsController do
  describe "invitation request" do
    context "when an user sends an invitation" do
      it "calls the send_mail_about_invitation method" do
        expect(send_mail_about_invitation).with(AssignmentParticipant.find(params[:student_id][:email]),params[:student
        ][:email],"invitation_pending")
      end
      end

    context "when an user accepts an invitation" do
      it "calls the send_mail_about_invitation method" do
        expect(send_mail_about_invitation).with(AssignmentParticipant.find(params[:student_id][:email]),params[:student
        ][:email],"invitation_accepted")
      end
    end

    context "when an user declines an invitation" do
      it "calls the send_mail_about_invitation method" do
        expect(send_mail_about_invitation).with(AssignmentParticipant.find(params[:student_id][:email]),params[:student
        ][:email],"invitation_declined")
      end
    end
  end

  describe "create invitation" do
    it "should deliver an invitation an invitation mail to user" do
      invitation_attributes = FactoryGirl.attributes_for(:to,:body)
      mailer = mock(mailer)
      mailer.should_receive(:deliver).with(send_mail_about_invitation(invitation_attributes))
    end
    end

  describe "respond invitation" do
    it "should deliver a response mail to user" do
      invitation_attributes = FactoryGirl.attributes_for(:to,:body)
      mailer = mock(mailer)
      mailer.should_receive(:deliver).with(send_mail_about_invitation(invitation_attributes))
    end
  end


end