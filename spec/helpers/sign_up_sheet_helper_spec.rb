require 'rails_helper'

describe "SignUpSheetHelper" do

  describe "#check_topic_due_date_value" do
    it "The check_topic_due_date_value method should return the assignment due date" do

    end
  end

  describe "#get_topic_deadline" do
    it "The get_topic_deadline method should return the deadline for a topic" do

    end
  end

  describe "#get_suggested_topics" do
    it "The get_suggested_topics method should return the suggested topics" do
      @assignment = create(:assignment)
      session[:user] = create(:student)
      topic = helper.get_suggested_topics(@assignment.id)
      expect(topic).to be_empty
    end
  end

  describe "#get_intelligent_topic_row" do
    it "The get_intelligent_topic_row method should render topic row for intelligent topic selection" do

    end
  end

  describe "#get_topic_bg_color" do
    it "The get_topic_bg_color method should return the topic background color" do

    end
  end

  describe "#render_participant_info" do
    it "The render_participant_info method should return participant info for a topic and assignment" do
      #@assignment = create(:assignment)
      #session[:user] = create(:student)
      #@AssignmentParticipant = create(parent_id: assignment.id, user_id: user.id)
      #render_participant_info(@assignment.topic, @assignment, @AssignmentParticipant.user.id)
      #expect(name_html).to be_valid
    end
  end

end