require "rails_helper"
require "response"

describe Response do
	
	describe "significant_difference?" do
		it "calculate score difference between reviews" do
			res = Response.new
			expect(Response.scores_and_count_for_prev_reviews(res.existing_response,res.current_response,10,15)).to eql([78707,78706],2)
		end
	end
end


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