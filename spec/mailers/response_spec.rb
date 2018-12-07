require "rails_helper"

RSpec.describe Mailer, :type => :mailer do
  describe "notify_grade_conflict_message" do

    it "renders the headers" do
      expect(mail.subject).to eq("Expertiza Notification: A review score is outside the acceptable range")
      expect(mail.to).to eq(["cshinde57@gmail.com"])
      expect(mail.from).to eq(["expertiza-support@lists.ncsu.edu"])
    end

  end
end