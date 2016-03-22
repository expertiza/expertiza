require 'rails_helper'

RSpec.describe AssignmentTeam, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"

  let(:team){AssignmentTeam.new name: "Wikipedia contribution_Team2", parent_id: 754, type: "AssignmentTeam", submitted_hyperlinks: "---\n- http://water.com/\nhttp://shed.com" }

  describe "#hyperlinks" do

    it "should have a valid parent id" do
    expect(team.parent_id).to eq(754)
    end

  #   Check this later:
     it "should retun the hyperlinks submitted by the team as a text" do
       # expect(team.submitted_hyperlinks.size).to be > 0
       expect(team.submitted_hyperlinks).to be_instance_of(String)
     end

  end

  before(:each) do
    @my_submitted_hyperlinks = team.submitted_hyperlinks.split("\n")
  end

  describe "#submit_hyperlink" do


    it "should not be able to able to upload without selecting a hyperlink in the UI" do

    end


    it "team members should not be able to upload same link twice" do
      # my_submitted_hyperlinks = team.submitted_hyperlinks.split("\n")
      expect(@my_submitted_hyperlinks.uniq.length).to eql(@my_submitted_hyperlinks.length)
    end

    it "should upload only valid links" do

    end

  end


end
