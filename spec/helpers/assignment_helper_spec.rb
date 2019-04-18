describe AssignmentHelper do

  before(:each) do
    # Factory creates an assignment with default:
    # name 'final2'
    @assignment = create(:assignment)
    # Factory creates a questionnaire with default:
    # name 'questionnaire[some number]'
    # type 'ReviewQuestionnaire'
    @q_round_nil_topic_nil = create(:questionnaire, id: 1001)
    @q_round_1_topic_nil = create(:questionnaire, id: 1002)
    @q_round_nil_topic_1 = create(:questionnaire, id: 1003)
    @q_round_1_topic_1 = create(:questionnaire, id:1004)
    @questionnaire_ids = [
      @q_round_nil_topic_nil.id,
      @q_round_1_topic_nil.id,
      @q_round_nil_topic_1.id,
      @q_round_1_topic_1.id
    ]
    # Factory creates an assignment-questionnaire relationship with default:
    # links together the first assignment found and the first questionnaire found
    # used_in_round nil
    # topic_id nil
    @aq_round_nil_topic_nil = create(:assignment_questionnaire, questionnaire: @q_round_nil_topic_nil)
    @aq_round_1_topic_nil = create(:assignment_questionnaire, questionnaire: @q_round_1_topic_nil, used_in_round: 1)
    @aq_round_nil_topic_1 = create(:assignment_questionnaire, questionnaire: @q_round_nil_topic_1, topic_id: 1)
    @aq_round_1_topic_1 = create(:assignment_questionnaire, questionnaire: @q_round_1_topic_1, used_in_round: 1, topic_id: 1)
    @assignment_questionnaire_ids = [
      @aq_round_nil_topic_nil.id,
      @aq_round_1_topic_nil.id,
      @aq_round_nil_topic_1.id,
      @aq_round_1_topic_1.id
    ]
  end

  # Method signature: questionnaire(assignment, questionnaire_type, round_number, topic_id)
  describe "#questionnaire" do

    questionnaire_type = "ReviewQuestionnaire"

    it "throws exception if assignment argument nil" do
      expect {questionnaire(nil, questionnaire_type, 1, 1)}.to raise_exception(NoMethodError)
    end

    it "throws exception if all arguments nil except for assignment" do
      expect {questionnaire(@assignment, nil, nil, nil)}.to raise_exception(TypeError)
    end

    it "finds by type if round number & topic id not given" do
      expect(questionnaire(@assignment, questionnaire_type, nil, nil).id).to eql @q_round_nil_topic_nil.id
    end

    it "throws exception if round number & topic id not given, no luck finding by type" do
      expect {questionnaire(@assignment, "Nonsense", nil, nil)}.to raise_exception(NameError)
    end

    it "finds by round number alone if round number alone is given" do
      expect(questionnaire(@assignment, "type_is_ignored", 1, nil).id).to eql @q_round_1_topic_nil.id
    end

    it "creates new questionnaire of given type if round number alone is given, no luck finding by round" do
      returned_questionnaire = questionnaire(@assignment, questionnaire_type, 2, nil)
      expect(@questionnaire_ids).not_to include returned_questionnaire.id
    end

    it "finds by topic id alone if topic id alone is given" do
      expect(questionnaire(@assignment, "type_is_ignored", nil, 1).id).to eql @q_round_nil_topic_1.id
    end

    it "creates new questionnaire of given type if topic id alone is given, no luck finding by topic" do
      returned_questionnaire = questionnaire(@assignment, questionnaire_type, nil, 2)
      expect(@questionnaire_ids).not_to include returned_questionnaire.id
    end

    it "finds by round number and topic id if both are given" do
      expect(questionnaire(@assignment, "type_is_ignored", 1, 1).id).to eql @q_round_1_topic_1.id
    end

    it "creates new questionnaire of given type if round and topic are given, no luck finding by round and topic" do
      returned_questionnaire = questionnaire(@assignment, questionnaire_type, 2, 2)
      expect(@questionnaire_ids).not_to include returned_questionnaire.id
    end

  end

  # Method signature: assignment_questionnaire(assignment, questionnaire_type, round_number, topic_id)
  describe "assignment_questionnaire" do

    questionnaire_type = "ReviewQuestionnaire"

    it "throws exception if assignment argument nil" do
      expect {assignment_questionnaire(nil, questionnaire_type, 1)}.to raise_exception(NoMethodError)
    end

    it "finds by type if round number & topic id not given" do
      expect(assignment_questionnaire(@assignment, questionnaire_type, nil, nil).id).to eql @aq_round_nil_topic_nil.id
    end

    it "creates a new assignment_questionnaire if no luck with given type (type nil)" do
      returned_assignment_questionnaire = assignment_questionnaire(@assignment, nil, 1, 1)
      expect(@assignment_questionnaire_ids).not_to include returned_assignment_questionnaire.id
    end

    it "creates a new assignment_questionnaire if no luck with given type (all arguments nil except for assignment)" do
      returned_assignment_questionnaire = assignment_questionnaire(@assignment, nil, nil, nil)
      expect(@assignment_questionnaire_ids).not_to include returned_assignment_questionnaire.id
    end

    it "creates a new assignment_questionnaire if no luck with given type (type not found)" do
      returned_assignment_questionnaire = assignment_questionnaire(@assignment, "Nonsense", nil, nil)
      expect(@assignment_questionnaire_ids).not_to include returned_assignment_questionnaire.id
    end

    it "finds by round number alone if round number alone is given" do
      expect(assignment_questionnaire(@assignment, questionnaire_type, 1, nil).id).to eql @aq_round_1_topic_nil.id
    end

    it "find by type if round number alone is given, no luck finding by round" do
      expect(assignment_questionnaire(@assignment, questionnaire_type, 2, nil).id).to eql @aq_round_nil_topic_nil.id
    end

    it "finds by topic id alone if topic id alone is given" do
      expect(assignment_questionnaire(@assignment, questionnaire_type, nil, 1).id).to eql @aq_round_nil_topic_1.id
    end

    it "find by type if topic id alone is given, no luck finding by topic" do
      expect(assignment_questionnaire(@assignment, questionnaire_type, nil, 2).id).to eql @aq_round_nil_topic_nil.id
    end

    it "finds by round number and topic id if both are given" do
      expect(assignment_questionnaire(@assignment, questionnaire_type, 1, 1).id).to eql @aq_round_1_topic_1.id
    end

    it "find by type if round and topic are given, no luck finding by round and topic" do
      expect(assignment_questionnaire(@assignment, questionnaire_type, 2, 2).id).to eql @aq_round_nil_topic_nil.id
    end

  end

end
