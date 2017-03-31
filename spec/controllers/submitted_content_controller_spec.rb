require 'rspec'

describe SubmittedContentController do
  describe "review deadline" do
    it "should an email before the last round and the deadline" do
      review_attributes = FactoryGirl.attributes_for(:to, :subject, :body)
      mailer = mock(Mailer)
      mailer.should_receive(:deliver).with(accept_invitation(review_attributes))
    end
  end
end