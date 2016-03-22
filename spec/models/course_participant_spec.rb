describe CourseParticipant do
  describe "#accessible attributes" do
    it { should allow_mass_assignment_of(:can_submit) }
    it { should allow_mass_assignment_of(:can_review) }
    it { should allow_mass_assignment_of(:user_id) }
    it { should allow_mass_assignment_of(:parent_id) }
    it { should allow_mass_assignment_of(:submitted_at) }
    it { should allow_mass_assignment_of(:permission_granted) }
    it { should allow_mass_assignment_of(:penalty_accumulated) }
    it { should allow_mass_assignment_of(:grade) }
    it { should allow_mass_assignment_of(:type) }
    it { should allow_mass_assignment_of(:handle) }
    it { should allow_mass_assignment_of(:time_stamp) }
    it { should allow_mass_assignment_of(:digital_signature) }
    it { should allow_mass_assignment_of(:duty) }
    it { should allow_mass_assignment_of(:can_take_quiz) }
  end

  describe "#export_fields" do
    it "returns export fields for a csv based on radio buttons checked" do
      options = {"personal_details"=>"true", "role"=>"true", "parent"=>"true", "email_options"=>"true", "handle"=>"true"}
      fields = ["name", "full name", "email", "role", "parent", "email on submission", "email on review", "email on metareview", "handle"]
      expect(CourseParticipant.export_fields(options)).to match_array(fields)
    end

  end

end
