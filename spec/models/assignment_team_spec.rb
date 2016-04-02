require 'rails_helper'

RSpec.describe AssignmentTeam, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"

  # let(:team){AssignmentTeam.new name: "Wikipedia contribution_Team2", parent_id: 754, type: "AssignmentTeam", submitted_hyperlinks: "---\n- http://water.com\n- http://shed.com" }

  let(:assignment_fac){FactoryGirl.create(:assignment_fac)}
  let(:team){FactoryGirl.create(:team)}

  describe "#hyperlinks" do

    it "should have a valid parent id" do
      expect(team.parent_id).to be_instance_of(Fixnum)
    end

    it "should return the hyperlinks submitted by the team as a text" do
      # expect(team.submitted_hyperlinks.size).to be > 0
      expect(team.submitted_hyperlinks).to be_instance_of(String)
    end

  end
  before(:each) do
    @my_submitted_hyperlinks = team.submitted_hyperlinks.split("\n")
  end

  describe "#submit_hyperlink" do

    it "should not allow team members to upload same link twice" do
      # my_submitted_hyperlinks = team.submitted_hyperlinks.split("\n")
      expect(@my_submitted_hyperlinks.uniq.length).to eql(@my_submitted_hyperlinks.length)
    end

    it "should upload only valid links" do
      if @my_submitted_hyperlinks.length > 1
        @my_submitted_hyperlinks.each do |line|
          @url = line[2, line.size]

          if line.size > 3
            # expect(@url).to match(/\A#{URI::regexp}\z/)
            expect(@url).to match(/\A#{URI::regexp(['http', 'https'])}\z/)
          end

        end

      end
    end

  end

  describe "#has_submissions?" do
    it "checks if a team has submitted hyperlinks" do
      # assignment = build(:assignment)
      assign_team = build(:assignment_team)
      assign_team.submitted_hyperlinks << "\n- https://www.harrypotter.ncsu.edu"
      expect(assign_team.has_submissions?).to be true
    end
  end

  describe "#remove_hyperlink" do
    it "should allow team member to delete a previously submitted hyperlink" do
      assign_team = build(:assignment_team)
      @selected_hyperlink = "https://www.h2.ncsu.edu"
      assign_team.submitted_hyperlinks << "\n- https://www.h2.ncsu.edu"
      assign_team.remove_hyperlink(@selected_hyperlink)
      expect(assign_team.submitted_hyperlinks.split("\n").include? @assign_team).to be false
      # print assign_team.submitted_hyperlinks.split("\n").include? @assign_team
    end

  end

end