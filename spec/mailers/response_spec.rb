require "rails_helper"

RSpec.describe Mailer, :type => :mailer do
  describe "notify_grade_conflict_message" do
  
	let(:mail) { Mailer.notify_grade_conflict_message }

    it "renders the subject" do
      expect(mail.subject).to eq("Expertiza Notification: A review score is outside the acceptable range")
	end
	
	it "renders the receiver email" do
      expect(mail.to).to eq(["cshinde57@gmail.com"])
	end

	it "renders the sender email" do
      expect(mail.from).to eq(["expertiza.development@gmail.com"])
    end

  end
end