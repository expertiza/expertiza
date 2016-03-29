require 'rails_helper'

RSpec.describe AssignmentTeam, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"

  # let(:team){AssignmentTeam.new name: "Wikipedia contribution_Team2", parent_id: 754, type: "AssignmentTeam", submitted_hyperlinks: "---\n- http://water.com\n- http://shed.com" }

  let(:team){FactoryGirl.create(:team)}

  describe "#hyperlinks" do

    it "should have a valid parent id" do
      expect(team.parent_id).to eq(754)
    end

    it "should retun the hyperlinks submitted by the team as a text" do
      # expect(team.submitted_hyperlinks.size).to be > 0
      expect(team.submitted_hyperlinks).to be_instance_of(String)
    end

  end
  before(:each) do
    @my_submitted_hyperlinks = team.submitted_hyperlinks.split("\n")
  end

  describe "#submit_hyperlink" do

    it "team members should not be able to upload same link twice" do
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


end