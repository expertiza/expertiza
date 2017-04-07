require 'rspec'

describe SuggestionController do
  describe "created suggestion" do
    context "when a new suggestion is created" do
      it "calls the send_email_to_instructor method" do
        expect(accepted_invitation).with(User.where(["role_id = ?", 2]).select("email").first)
      end
    end
  end

  describe "suggestion notification" do
    it "should deliver an notification email to the instructor" do
      suggestion_attributes = FactoryGirl.attributes_for(:to, :subject, :body, :suggested_topic_name, :proposer)
      mailer = mock(Mailer)
      mailer.should_receive(:deliver).with(accept_invitation(suggestion_attributes))
    end
  end
end
