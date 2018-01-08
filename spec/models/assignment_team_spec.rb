describe 'AssignmentTeam' do
  let(:assignment) { create(:assignment) }
  let(:team) { create(:assignment_team) }

  describe "#hyperlinks" do
    it "should have a valid parent id" do
      expect(team.parent_id).to be_kind_of(Integer)
    end

    it "should return the hyperlinks submitted by the team as a text" do
      expect(team.submitted_hyperlinks.size).to be > 0
      expect(team.submitted_hyperlinks).to be_instance_of(String)
    end
  end

  describe "#submit_hyperlink" do
    before(:each) do
      @my_submitted_hyperlinks = team.submitted_hyperlinks.split("\n")
    end

    it "should not allow team members to upload same link twice" do
      expect(@my_submitted_hyperlinks.uniq.length).to eql(@my_submitted_hyperlinks.length)
    end

    it "should upload only valid links" do
      if @my_submitted_hyperlinks.length > 1
        @my_submitted_hyperlinks.each do |line|
          @url = line[2, line.size]
          expect(@url).to match(/\A#{URI.regexp(%w[http https])}\z/) if line.size > 3
        end
      end
    end
  end

  describe "#has_submissions?" do
    it "checks if a team has submitted hyperlinks" do
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
      expect(assign_team.submitted_hyperlinks.split("\n").include?(@assign_team)).to be false
    end
  end

  describe "copy assignment team to course team" do
    it "should allow assignment team to be copied to course team" do
      course_team = CourseTeam.new
      course_team.save!
      assign_team = build(:assignment_team)
      assign_team.copy(course_team.id)
      expect(CourseTeam.create_team_and_node(course_team.id))
      expect(course_team.copy_members(course_team.id))
    end
  end
end
