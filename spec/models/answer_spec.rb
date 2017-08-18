describe Answer do
  let(:questionnaire) { create(:questionnaire, id: 1) }
  let(:question1) { create(:question, questionnaire: questionnaire, weight: 1, id: 1) }
  let(:question2) { create(:question, questionnaire: questionnaire, weight: 2, id: 2) }
  let(:response_map) { create(:review_response_map, id: 1, reviewed_object_id: 1) }
  let!(:response_record) { create(:response, id: 1, response_map: response_map) }
  let!(:answer) { create(:answer, question: question1, response_id: 1) }

  describe "# test dependancy between question.rb and answer.rb"
  it { should belong_to(:question) }

  describe "#test get total score" do
    it "returns total score when required conditions are met" do
      # stub for ScoreView.find_by_sql to revent prevent unit testing sql db queries
      allow(ScoreView).to receive(:find_by_sql).and_return([double("scoreview", weighted_score: 20, sum_of_weights: 5, q1_max_question_score: 4)])
      allow(Answer).to receive(:where).and_return([double("row1", question_id: 1, answer: "1")])
      expect(Answer.get_total_score(response: [response_record], questions: [question1])).to eq 100.0
      # output calculation is (weighted_score / (sum_of_weights * max_question_score)) * 100
      # 4.0
    end

    it "returns total score when one answer is nil for scored question and its weight gets removed from sum_of_weights" do
      allow(ScoreView).to receive(:find_by_sql).and_return([double("scoreview", weighted_score: 20, sum_of_weights: 5, q1_max_question_score: 4)])
      allow(Answer).to receive(:where).and_return([double("row1", question_id: 1, answer: nil)])
      expect(Answer.get_total_score(response: [response_record], questions: [question1])).to be_within(0.01).of(125.0)
    end

    it "returns -1 when answer is nil for scored question which makes sum of weights = 0" do
      allow(ScoreView).to receive(:find_by_sql).and_return([double("scoreview", weighted_score: 20, sum_of_weights: 1, q1_max_question_score: 5)])
      allow(Answer).to receive(:where).and_return([double("row1", question_id: 1, answer: nil)])
      expect(Answer.get_total_score(response: [response_record], questions: [question1])).to eq -1.0
    end

    it "returns -1 when weighted_score of questionnaireData is nil" do
      allow(ScoreView).to receive(:find_by_sql).and_return([double("scoreview", weighted_score: nil, sum_of_weights: 5, q1_max_question_score: 5)])
      allow(Answer).to receive(:where).and_return([double("row1", question_id: 1, answer: nil)])
      expect(Answer.get_total_score(response: [response_record], questions: [question1])).to eq -1.0
    end

    xit "checks if submission_valid? is called" do
      allow(ScoreView).to receive(:find_by_sql).and_return([double("scoreview", weighted_score: nil, sum_of_weights: 5, q1_max_question_score: 5)])
      allow(Answer).to receive(:where).and_return([double("row1", question_id: 1, answer: nil)])
      expect(Answer).to receive(:submission_valid?)
      Answer.get_total_score(response: [response_record], questions: [question1])
    end
  end

  describe "#test compute scores" do
    let(:response1) { double("respons1") }
    let(:response2) { double("respons2") }

    before(:each) do
      @total_score = 100.0
      allow(Answer).to receive(:get_total_score).and_return(@total_score)
    end

    it "returns nil if list of assessments is empty" do
      assessments = []
      scores = Answer.compute_scores(assessments, [question1])
      expect(scores[:max]).to eq nil
      expect(scores[:min]).to eq nil
      expect(scores[:avg]).to eq nil
    end

    it "returns scores when a single valid assessment of total score 100 is give" do
      assessments = [response1]
      Answer.instance_variable_set(:@invalid, 0)
      scores = Answer.compute_scores(assessments, [question1])
      expect(scores[:max]).to eq @total_score
      expect(scores[:min]).to eq @total_score
      expect(scores[:avg]).to eq @total_score
    end

    it "returns scores when two valid assessments of total scores 80 and 100 are given" do
      assessments = [response1, response2]
      Answer.instance_variable_set(:@invalid, 0)
      total_score1 = 100.0
      total_score2 = 80.0
      allow(Answer).to receive(:get_total_score).and_return(total_score1, total_score2)
      scores = Answer.compute_scores(assessments, [question1])
      expect(scores[:max]).to eq total_score1
      expect(scores[:min]).to eq total_score2
      expect(scores[:avg]).to eq (total_score1 + total_score2) / 2
    end

    it "returns scores when an invalid assessments is given" do
      assessments = [response1]
      Answer.instance_variable_set(:@invalid, 1)
      scores = Answer.compute_scores(assessments, [question1])
      expect(scores[:max]).to eq @total_score
      expect(scores[:min]).to eq @total_score
      expect(scores[:avg]).to eq 0
    end

    it "returns scores when invalid flag is nil" do
      assessments = [response1]
      Answer.instance_variable_set(:@invalid, nil)
      scores = Answer.compute_scores(assessments, [question1])
      expect(scores[:max]).to eq @total_score
      expect(scores[:min]).to eq @total_score
      expect(scores[:avg]).to eq @total_score
    end

    it "checks if get_total_score function is called" do
      assessments = [response1]
      expect(Answer).to receive(:get_total_score).with(response: assessments, questions: [question1]).and_return(@total_score)
      scores = Answer.compute_scores(assessments, [question1])
    end
  end

  describe "#test sql queries in answer.rb" do
    before(:each) do
      @assignment_id = 1
      @reviewee_id = 1
      @q_id = 1
      @round = 1
    end
    it "returns answer by question record from db which is not empty" do
      expect(Answer.answers_by_question(@assignment_id, @q_id)).not_to be_empty
    end

    it "returns answers by question for reviewee from the db which is not empty" do
      expect(Answer.answers_by_question_for_reviewee(@assignment_id, @reviewee_id, @q_id)).not_to be_empty
    end

    it "returns answers by question for reviewee in round from db which is not empty" do
      expect(Answer.answers_by_question_for_reviewee_in_round(@assignment_id, @reviewee_id, @q_id, @round)).not_to be_empty
    end
  end

  # A bug was reported to TAs regarding submission_valid? function.
  # The line 106 in answers.rb enters if sorted deadline is nil but if that is the case, line 113 	will throw an error.
  # So the following test cases will make no sense once the bug is fixed. These have to changed.
  describe "submission valid?" do
    xit "Checking for when valid due date objects are passed back to @sorted_deadlines" do
      response_record.id = 1
      response_record.additional_comment = "Test"
      due_date1 = AssignmentDueDate.new
      due_date2 = AssignmentDueDate.new
      due_date1.due_at = Time.new - 24
      due_date2.due_at = Time.new - 24
      due_date1.deadline_type_id = 4
      due_date2.deadline_type_id = 2
      ResubmissionTime1 = Time.new - 24
      ResubmissionTime2 = Time.new - 48
      expect(Answer.submission_valid?(response_record)).to eq nil
    end

    it "Checking when no due date objects are passed back to @sorted_deadlines" do
      response_record.id = 1
      response_record.additional_comment = "Test"
      allow(AssignmentDueDate).to receive(:where).and_return(nil)
      allow(AssignmentDueDate).to receive(:order).and_return(nil)
      expect { Answer.submission_valid?(response_record) }.to raise_error
    end
  end
end
