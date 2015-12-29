require "rspec"

describe "VmQuestionResponse behaviour" do
  before do
    @participant = AssignmentParticipant.find(28634)
    @assignment = @participant.assignment
    @team_id = TeamsUser.team_id(@participant.parent_id, @participant.user_id)
    @team = Team.find(@team_id)
    @questionnaires = @assignment.questionnaires_with_questions
    @questionnaire =  @questionnaires[0] #Questionnaire.find(214)
    @questions = @questionnaire.questions
    @vm = VmQuestionResponse.new(@questionnaire,1,3)
    @vm.addQuestions(@questions)
    @vm.addReviews(@participant,@team,false)
    @vm.get_number_of_comments_greater_than_10_words()

  end

  it "should check correct questionnaire name" do
    expect(@vm.name).to eq "CSC/ECE 506 Wiki Custom review"
  end

  it "should check correct # of questions" do
    expect(@vm.listofrows.length).to eq(26)
  end

  it "should check correct # of reviews" do
    expect(@vm.listofreviews.length).to eq(15)
  end

  it "should check correct # of comments > char10" do
    expect(@vm.listofrows[0].countofcomments).to eq(12)
  end

  it "should check correct # of comments > char10" do
    expect(@vm.listofrows[0].score_row[0].color_code).to eq("c4")
  end

  it "should check correct review total" do
    expect(@vm.get_total_review_scores[0]).to eq(43)
  end

  it "should check correct review total" do
    expect(@vm.listofrows[0].average_score_for_row).to eq(4.53)
  end

  it "rounds eq" do
    expect(@vm.rounds).to eq(3)
  end

end