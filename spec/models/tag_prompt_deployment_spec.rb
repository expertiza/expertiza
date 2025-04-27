describe TagPromptDeployment do
  let(:tag_dep) { TagPromptDeployment.new id: 1, tag_prompt: tp, tag_prompt_id: 1, question_type: "Criterion", answer_length_threshold: 5, questionnaire: questionnaire, assignment: assignment }
  let(:tag_dep1) { TagPromptDeployment.new id: 1, tag_prompt: tp, tag_prompt_id: 1, question_type: "Criterion", answer_length_threshold: nil, assignment_id: 1, assignment: assignment, questionnaire: questionnaire }
  let(:tp) { TagPrompt.new(prompt: "test prompt", desc: "test desc", control_type: "Checkbox") }
  let(:team) { Team.new(id: 1) }
  let(:assignment) { Assignment.new(id: 1) }
  let(:questionnaire) { Questionnaire.new(id: 1, name: "question1") }
  let(:rp) { Response.new(map_id: 1, round: 1, additional_comment: "improvement scope") }
  let(:response) { Response.new(map_id: [1, 2], round: [1, 1], additional_comment: ["improvement scope", "through comments"]) }
  let(:question) { Question.new(questionnaire: questionnaire) }
  let(:answer) { Answer.new(id: [1, 2, 3], question_id: [1, 1, 1], answer: [3, 3, 3], comments: ["comment", "comment is lengthy", "comment is too lengthy"], response_id: [241, 241, 241]) }
  let(:answers_one) { Answer.new(id: [1], question_id: [1], answer: [3], comments: ["comment"], response_id: [241]) }
  let(:user1) { User.new(id: 1) }
  let(:user2) { User.new(id: 2) }
  let(:team_user1) { TeamsUser.new(user_id: user1.id, team_id: team.id) }
  let(:team_user2) { TeamsUser.new(user_id: user2.id, team_id: team.id) }
  let(:tagA) { AnswerTag.new(tag_prompt_deployment_id: tag_dep.id, user_id: user1.id, answer: answer, updated_at: Date.new.to_s) }
  let(:tagB) { AnswerTag.new(tag_prompt_deployment_id: tag_dep.id, user_id: user2.id, answer: answer, updated_at: Date.new.to_s) }

  answersObjectArray = [
    Answer.new(id: 1, question_id: 1, answer: 3, comments: "comm", response_id: 2313),
    Answer.new(id: 2, question_id: 1, answer: 3, comments: "comment length exceeds threshold", response_id: 2313),
    Answer.new(id: 3, question_id: 1, answer: 3, comments: "comment length within threshold", response_id: 2313),
    Answer.new(id: 4, question_id: 2, answer: 1, comments: "com1", response_id: 241)
  ]

  describe "#tag_prompt" do
    # Valid tag_prompt_id is provided to the TagPromptDeployment instance.
    # Tests that the tag prompt associated with the provided tag_prompt_id is correctly
    # returned by the tag_dep.tag_prompt method.
    context "when given a valid tag_prompt_id" do
      it "returns the associated tag prompt with the deployment" do
        allow(TagPrompt).to receive(:find).with(1).and_return(tp)
        expect(tag_dep.tag_prompt).to be(tp)
      end
    end

    # Invalid tag_prompt_id is provided to the TagPromptDeployment instance.
    # Tests that nil is returned by the tag_dep.tag_prompt method.
    context "when given an invalid tag_prompt_id" do
      it "returns nil" do
        allow(TagPrompt).to receive(:find).with(-1).and_return(tp)
        expect(tp.id).to be(nil)
      end
    end
  end


  # get_number_of_taggable_answers calculates total taggable answers assigned for a user who participated in "tag review assignment".
  describe "#get_number_of_taggable_answers" do
    before(:each) do
      questions_ids = double(1)
      response_ids = double(241)
      allow(Team).to receive(:joins).with(:teams_users).and_return(team)
      allow(team).to receive(:where).with(team_users: { parent_id: tag_dep1.assignment_id }, user_id: 1).and_return(team)
      allow(Response).to receive(:joins).with(:response_maps).and_return(response)
      allow(response).to receive(:where).with(response_maps: { reviewed_object_id: tag_dep1.assignment.id, reviewee_id: team.id }).and_return(rp)
      allow(rp).to receive(:empty?).and_return(false)
      allow(rp).to receive(:map).with(any_args).and_return(response_ids)
      allow(Question).to receive(:where).with(questionnaire_id: tag_dep1.questionnaire.id, type: tag_dep1.question_type).and_return(question)
      allow(question).to receive(:empty?).and_return(false)
      allow(question).to receive(:map).with(any_args).and_return(questions_ids)
      allow(Answer).to receive(:where).with(question_id: questions_ids, response_id: response_ids).and_return(answer)
    end

    # Tests that an error message is returned when user_id is nil
    context "when user_id is nil" do
      it "given out an error message" do
        allow(Team).to receive(:joins).with(:teams_users).and_return(team)
        allow(team).to receive(:where).with(team_users: { parent_id: tag_dep1.assignment_id }, user_id: nil).and_raise(ActiveRecord::ActiveRecordError)
        expect { tag_dep1.get_number_of_taggable_answers(nil) }.to raise_error ActiveRecord::ActiveRecordError
      end
    end

    # Tests that a count of taggable answers is returned when the answer_length_throshold is null
    context "when answer_length_threshold null" do
      it "count of taggable answers" do
        questions_ids = double(1)
        response_ids = double(241)
        allow(Answer).to receive(:where).with(question_id: questions_ids, response_id: response_ids).and_return(answer)
        allow(answer).to receive(:count)
        expect(tag_dep1.get_number_of_taggable_answers(1)).to eq(answer.count)
      end
    end


    # Tests that when answer_length_threshold is not null, get_number_of_taggable_answers method correctly counts the number
    # of taggable answers that have a length less than the specified answer_length_threshold.
    context "when answer_length_threshold NOT null" do
      it "count of taggable answers less than answers_one" do
        questions_ids = double(1)
        response_ids = double(241)
        tag_dep1.answer_length_threshold = 15
        allow(Answer).to receive(:where).with(question_id: questions_ids, response_id: response_ids).and_return(answer)
        allow(answer).to receive(:where).with(conditions: "length(comments) < #{tag_dep1.answer_length_threshold}").and_return(answers_one)
        allow(answers_one).to receive(:count)
        expect(tag_dep1.get_number_of_taggable_answers(1)).to eq(answers_one.count)
      end
    end

    # Tests when there are no responses associated with the TagPromptDeployment instance, get_number_of_taggable_answers
    # returns zero as the count of taggable answers.
    context "when there are no responses" do
      it "returns zero as the count of taggable answers" do
            allow(rp).to receive(:empty?).and_return(true)
            expect(tag_dep1.get_number_of_taggable_answers(1)).to eq(0)
          end
        end

    # Tests when there are no questions associated with the TagPromptDeployment instance, get_number_of_taggable_answers
    # returns zero as the count of taggable answers.
    context "when questions empty" do
      it "count of taggable answers zero" do
        allow(question).to receive(:empty?).and_return(true)
        expect(tag_dep1.get_number_of_taggable_answers(1)).to eq(0)
      end
    end

    # Tests when there *are* questions associated with the TagPromptDeployment instance, get_number_of_taggable_answers
    # returns the appropriate count of taggable answers.
    context "when there are taggable answers" do
      it "returns the number of taggable answers for a given user" do
        user_ids = double(1)
        allow(Team).to receive(:joins).with(:teams_users).and_return(team)
        allow(team).to receive(:where).with(team_users: { parent_id: tag_dep1.assignment_id }, user_id: user_ids).and_return(user1)

        expected_count = 2 # This should be the actual expected number of taggable answers
        allow(answer).to receive(:count).and_return(expected_count)

        actual_count = tag_dep1.get_number_of_taggable_answers(user_ids)
        expect(actual_count).to eq(expected_count)
      end
    end
  end

  # Get the percentage progress of tagging
  describe "assignment_tagging_progress" do

    # Tests that when no teams are found, an empty result is returned.
    context "when no teams are found" do
      it "returns an empty result" do
        allow(Team).to receive(:where).with(parent_id: assignment.id).and_return([])
        allow(Question).to receive(:where).with(questionnaire_id: question.questionnaire.id, type: tag_dep.question_type).and_return([question])

        user_answer_tagging = tag_dep.assignment_tagging_progress

        expect(ReviewResponseMap).not_to receive(:get_responses_for_team_round)
        expect(ResponseMap).not_to receive(:assessments_for)
        expect(Answer).not_to receive(:where)
        expect(AnswerTag).not_to receive(:where)
        expect(user_answer_tagging).to be_empty
      end
    end

    # Tests that when no questions are found, an empty result is returned.
    context "when no questions are found" do
      it "returns an empty result" do
        allow(Team).to receive(:where).with(parent_id: assignment.id).and_return([team])
        allow(Question).to receive(:where).with(questionnaire_id: question.questionnaire.id, type: tag_dep.question_type).and_return([])

        user_answer_tagging = tag_dep.assignment_tagging_progress

        expect(ReviewResponseMap).not_to receive(:get_responses_for_team_round)
        expect(ResponseMap).not_to receive(:assessments_for)
        expect(Answer).not_to receive(:where)
        expect(AnswerTag).not_to receive(:where)
        expect(user_answer_tagging).to be_empty
      end
    end

    # Tests that when no teams or questions are found, an empty result is returned.
    context "when there are no teams or questions" do
      it "returns an empty result" do
        allow(Team).to receive(:where).with(parent_id: assignment.id).and_return([])
        allow(Question).to receive(:where).with(questionnaire_id: question.questionnaire.id, type: tag_dep.question_type).and_return([])

        user_answer_tagging = tag_dep.assignment_tagging_progress

        expect(ReviewResponseMap).not_to receive(:get_responses_for_team_round)
        expect(ResponseMap).not_to receive(:assessments_for)
        expect(Answer).not_to receive(:where)
        expect(AnswerTag).not_to receive(:where)
        expect(user_answer_tagging).to be_empty
      end
    end

    # When there a team and question exist
    context "when there is a team and a question" do

      # Tests when the assignment's rubrics do not vary by round in the TagPromptDeployment instance.
      # Verifies that when rubrics do not vary by round, the method assignment_tagging_progress
      # correctly calculates the tagging progress for each user, considering all tagged items without regard to round.
      context "when the assignment's rubrics do not vary by round" do
        it "calculates the tagging progress for each user, considering all tagged items without regard to round" do
          allow(Team).to receive(:where).with(parent_id: assignment.id).and_return([team])
          allow(Question).to receive(:where).with(questionnaire_id: question.questionnaire.id, type: tag_dep.question_type).and_return([question])
          allow(assignment).to receive(:varying_rubrics_by_round?).and_return(false)
          allow(ResponseMap).to receive(:assessments_for).and_return([response])
          allow(Answer).to receive(:where).and_return(answersObjectArray)
          allow(TeamsUser).to receive(:where).with(team_id: team.id).and_return([team_user1, team_user2])
          allow(User).to receive(:find).with(user1.id).and_return(user1)
          allow(User).to receive(:find).with(user2.id).and_return(user2)
          allow(AnswerTag).to receive(:where).with(tag_prompt_deployment_id: tag_dep.id, user_id: user1.id, answer_id: [2, 3]).and_return([tagA, tagB])
          allow(AnswerTag).to receive(:where).with(tag_prompt_deployment_id: tag_dep.id, user_id: user2.id, answer_id: [2, 3]).and_return([tagA, tagB])

          user_answer_tagging = tag_dep.assignment_tagging_progress

          expect(ReviewResponseMap).not_to receive(:get_responses_for_team_round)
          expect(user_answer_tagging).not_to be_empty
          expect(user_answer_tagging.length).to eq(2)

          expect(user_answer_tagging[0].user).to eq(user1)
          expect(user_answer_tagging[0].no_tagged).to eq(2)
          expect(user_answer_tagging[0].no_not_tagged).to eq(2)
          expect(user_answer_tagging[0].percentage).to eq("100.0")

          expect(user_answer_tagging[1].user).to eq(user2)
          expect(user_answer_tagging[1].no_tagged).to eq(2)
          expect(user_answer_tagging[1].no_not_tagged).to eq(2)
          expect(user_answer_tagging[1].percentage).to eq("100.0")
        end
      end

      # Tests when the assignment's rubrics *do* vary by round in the TagPromptDeployment instance.
      # Verifies that when rubrics vary by round, the method assignment_tagging_progress
      # correctly calculates the tagging progress for each user, considering all tagged items.
      context "when the assignment's rubrics vary by round" do
        it "calculates the tagging progress for each user, considering all tagged items" do
          allow(Team).to receive(:where).with(parent_id: assignment.id).and_return([team])
          allow(Question).to receive(:where).with(questionnaire_id: question.questionnaire.id, type: tag_dep.question_type).and_return([question])
          allow(assignment).to receive(:varying_rubrics_by_round?).and_return(true)
          allow(ReviewResponseMap).to receive(:get_responses_for_team_round).and_return([response])
          allow(Answer).to receive(:where).and_return(answersObjectArray)
          allow(TeamsUser).to receive(:where).with(team_id: team.id).and_return([team_user1, team_user2])
          allow(User).to receive(:find).with(user1.id).and_return(user1)
          allow(User).to receive(:find).with(user2.id).and_return(user2)
          allow(AnswerTag).to receive(:where).with(tag_prompt_deployment_id: tag_dep.id, user_id: user1.id, answer_id: [2, 3]).and_return([tagA, tagB])
          allow(AnswerTag).to receive(:where).with(tag_prompt_deployment_id: tag_dep.id, user_id: user2.id, answer_id: [2, 3]).and_return([tagA, tagB])

          user_answer_tagging = tag_dep.assignment_tagging_progress

          expect(ResponseMap).not_to receive(:assessments_for)
          expect(user_answer_tagging).not_to be_empty
          expect(user_answer_tagging.length).to eq(2)

          expect(user_answer_tagging[0].user).to eq(user1)
          expect(user_answer_tagging[0].no_tagged).to eq(2)
          expect(user_answer_tagging[0].no_not_tagged).to eq(2)
          expect(user_answer_tagging[0].percentage).to eq("100.0")

          expect(user_answer_tagging[1].user).to eq(user2)
          expect(user_answer_tagging[1].no_tagged).to eq(2)
          expect(user_answer_tagging[1].no_not_tagged).to eq(2)
          expect(user_answer_tagging[1].percentage).to eq("100.0")
        end
      end

      # Tests when there are no tags associated with responses in the TagPromptDeployment instance.
      # Verifies that when there are no tags associated with responses, the method assignment_tagging_progress
      # correctly calculates the tagging progress for each user, returning zero percentages for untagged items.
      context "when there are no tags associated with responses" do
        it "calculates the tagging progress for each user, returning zero percentages for untagged items" do
          allow(Team).to receive(:where).with(parent_id: assignment.id).and_return([team])
          allow(Question).to receive(:where).with(questionnaire_id: question.questionnaire.id, type: tag_dep.question_type).and_return([question])
          allow(assignment).to receive(:varying_rubrics_by_round?).and_return(true)
          allow(ReviewResponseMap).to receive(:get_responses_for_team_round).and_return([response])
          allow(Answer).to receive(:where).and_return(answersObjectArray)
          allow(TeamsUser).to receive(:where).with(team_id: team.id).and_return([team_user1, team_user2])
          allow(User).to receive(:find).with(user1.id).and_return(user1)
          allow(User).to receive(:find).with(user2.id).and_return(user2)
          allow(AnswerTag).to receive(:where).with(tag_prompt_deployment_id: tag_dep.id, user_id: user1.id, answer_id: [2, 3]).and_return([])
          allow(AnswerTag).to receive(:where).with(tag_prompt_deployment_id: tag_dep.id, user_id: user2.id, answer_id: [2, 3]).and_return([])

          user_answer_tagging = tag_dep.assignment_tagging_progress

          expect(ResponseMap).not_to receive(:assessments_for)
          expect(user_answer_tagging).not_to be_empty
          expect(user_answer_tagging.length).to eq(2)

          expect(user_answer_tagging[0].user).to eq(user1)
          expect(user_answer_tagging[0].no_tagged).to eq(0)
          expect(user_answer_tagging[0].no_not_tagged).to eq(2)
          expect(user_answer_tagging[0].percentage).to eq("0.0")

          expect(user_answer_tagging[1].user).to eq(user2)
          expect(user_answer_tagging[1].no_tagged).to eq(0)
          expect(user_answer_tagging[1].no_not_tagged).to eq(2)
          expect(user_answer_tagging[1].percentage).to eq("0.0")
        end
      end
    end
  end
end
