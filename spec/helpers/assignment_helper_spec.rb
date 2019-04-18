describe AssignmentHelper do

  before(:each) do
    # Factory creates an assignment with default:
    # name 'final2'
    @assignment = create(:assignment)
    # Factory creates a questionnaire with default:
    # name 'Test questionnaire'
    # type 'ReviewQuestionnaire'
    @questionnaire1 = create(:questionnaire, id: 1001)
    @questionnaire2 = create(:questionnaire, id: 1002)
    # Factory creates an assignment-questionnaire relationship with default:
    # links together the first assignment found and the first questionnaire found
    # used_in_round nil
    @assignment_questionnaire1 = create(:assignment_questionnaire, questionnaire: @questionnaire1)
    @assignment_questionnaire2 = create(:assignment_questionnaire, questionnaire: @questionnaire2, used_in_round: 1)
  end

  describe "#questionnaire" do

    questionnaire_type = "ReviewQuestionnaire"

    it "throws exception if assignment argument nil" do
      expect {questionnaire(nil, questionnaire_type, 1)}.to raise_exception(NoMethodError)
    end

    it "throws exception if type and round arguments nil" do
      expect {questionnaire(@assignment, nil, nil)}.to raise_exception(TypeError)
    end

    it "returns a questionnaire of the given type if round argument nil" do
      expect(questionnaire(@assignment, questionnaire_type, nil).id).to eql @questionnaire1.id
    end

    it "returns a new questionnaire of the given type if one with the given round does not exist" do
      returned_questionnaire = questionnaire(@assignment, questionnaire_type, 2)
      expect(returned_questionnaire.id).not_to eql @questionnaire1.id
      expect(returned_questionnaire.id).not_to eql @questionnaire2.id
    end

    it "returns a questionnaire of the given round if one exists (type argument nil)" do
      expect(questionnaire(@assignment, nil, 1).id).to eql @questionnaire2.id
    end

    it "returns a questionnaire of the given round if one exists (type argument ignored)" do
      expect(questionnaire(@assignment, "Nonsense", 1).id).to eql @questionnaire2.id
    end

  end

  describe "assignment_questionnaire" do

    questionnaire_type = "ReviewQuestionnaire"

    it "throws exception if assignment argument nil" do
      expect {assignment_questionnaire(nil, questionnaire_type, 1)}.to raise_exception(NoMethodError)
    end

    it "creates a new assignment questionnaire if type argument nil" do
      returned_assignment_questionnaire = assignment_questionnaire(@assignment, nil, 1)
      expect(returned_assignment_questionnaire.id).not_to eql @assignment_questionnaire1.id
      expect(returned_assignment_questionnaire.id).not_to eql @assignment_questionnaire2.id
    end

    it "creates a new assignment questionnaire if type and round arguments nil" do
      returned_assignment_questionnaire = assignment_questionnaire(@assignment, nil, nil)
      expect(returned_assignment_questionnaire.id).not_to eql @assignment_questionnaire1.id
      expect(returned_assignment_questionnaire.id).not_to eql @assignment_questionnaire2.id
    end

    it "creates a new assignment questionnaire if no questionnaires of given type exist" do
      returned_assignment_questionnaire = assignment_questionnaire(@assignment, "Nonsense", nil)
      expect(returned_assignment_questionnaire.id).not_to eql @assignment_questionnaire1.id
      expect(returned_assignment_questionnaire.id).not_to eql @assignment_questionnaire2.id
    end

    it "returns an assignment questionnaire for questionnaire of given type if round argument nil" do
      expect(assignment_questionnaire(@assignment, questionnaire_type, nil).id).to eql @assignment_questionnaire1.id
    end

    it "returns an assignment questionnaire for questionnaire of given type if questionnaire of the given round does not exist" do
      expect(assignment_questionnaire(@assignment, questionnaire_type, 2).id).to eql @assignment_questionnaire1.id
    end

    it "returns an assignment questionnaire for questionnaire of given round if one exists" do
      expect(assignment_questionnaire(@assignment, questionnaire_type, 1).id).to eql @assignment_questionnaire2.id
    end

  end

end
