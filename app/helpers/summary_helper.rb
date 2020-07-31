# require for webservice calls
require 'json'
require 'rest_client'
require 'logger'

# required by autosummary
module SummaryHelper
  class Summary
    attr_accessor :summary, :reviewers, :avg_scores_by_reviewee, :avg_scores_by_round, :avg_scores_by_criterion, :summary_ws_url

    # produce average score and summary of comments for reviews by a reviewer for each question
    def summarize_reviews_by_reviewee(questions, assignment, reviewee_id, summary_ws_url)
      self.summary = ({})
      self.avg_scores_by_round = ({})
      self.avg_scores_by_criterion = ({})
      self.summary_ws_url = summary_ws_url

      # get all answers for each question and send them to summarization WS
      questions.each_key do |round|
        self.summary[round.to_s] = {}
        self.avg_scores_by_criterion[round.to_s] = {}
        self.avg_scores_by_round[round.to_s] = 0.0
        questions[round].each do |question|
          next if question.type.eql?("SectionHeader")
          summarize_reviews_by_reviewee_question(assignment, reviewee_id, question, round)
        end
        self.avg_scores_by_round[round.to_s] = calculate_avg_score_by_round(self.avg_scores_by_criterion[round.to_s], questions[round])
      end
      self
    end

    # get average scores and summary for each question in a review by a reviewer
    def summarize_reviews_by_reviewee_question(assignment, reviewee_id, question, round)
      question_answers = Answer.answers_by_question_for_reviewee(assignment.id, reviewee_id, question.id)

      self.avg_scores_by_criterion[round.to_s][question.txt] = calculate_avg_score_by_criterion(question_answers, get_max_score_for_question(question))

      self.summary[round.to_s][question.txt] = summarize_sentences(break_up_comments_to_sentences(question_answers), self.summary_ws_url)
    end

    # Wait for threads to end
    def end_threads(threads)
      threads.each do |t|
        # Wait for the thread to finish if it isn't this thread (i.e. the main thread).
        t.join if t != Thread.current
      end
    end

    # E1936 team recommends this method be REMOVED
    #   it does not seem to be used anywhere in Expertiza as of 4/21/19
    #   aside from in methods which are themselves not used anywhere in Expertiza as of 4/21/19
    # produce summaries for instructor. it merges all feedback given to all reviewees, and summarize them by criterion
    def summarize_reviews_by_criterion(assignment, summary_ws_url)
      self.summary = self.avg_scores_by_criterion = self.avg_scores_by_round = Array.new(assignment.rounds_of_reviews)
      rubric = get_questions_by_assignment(assignment)

      (0..nround - 1).each do |round|
        self.avg_scores_by_round[round] = 0.0
        self.summary[round] = {}
        self.avg_scores_by_criterion[round] = {}

        questions_used_in_round = rubric[assignment.vary_by_round ? round : 0]
        # get answers of each question in the rubric
        questions_used_in_round.each do |question|
          next if question.type.eql?("SectionHeader")
          summarize_reviews_by_criterion_question(assignment, summary_ws_url, round, question)
        end
        self.avg_scores_by_round[round] = calculate_avg_score_by_round(avg_scores_by_criterion[round], questions_used_in_round)
      end
      self
    end

    # get summary of answers of each question in the rubric
    def summarize_reviews_by_criterion_question(assignment, summary_ws_url, round, question)
      threads = []
      answers_questions = Answer.answers_by_question(assignment.id, question.id)

      threads << Thread.new do
        self.avg_scores_by_criterion[round][question.txt] = calculate_avg_score_by_criterion(answers_questions, get_max_score_for_question(question))
        self.summary[round][question.txt] = summarize_sentences(break_up_comments_to_sentences(answers_questions), summary_ws_url)
      end
      # Wait for all threads to end
      end_threads(threads)
    end

    # E1936 team recommends this method be REMOVED
    #   it does not seem to be used anywhere in Expertiza as of 4/21/19
    #   aside from in methods which are themselves not used anywhere in Expertiza as of 4/21/19
    # produce summaries for instructor and students. It sum up the feedback by criterion for each reviewee
    def summarize_reviews_by_reviewees(assignment, summary_ws_url)
      self.summary = ({})
      self.avg_scores_by_reviewee = ({})
      self.avg_scores_by_round = ({})
      self.avg_scores_by_criterion = ({})
      self.reviewers = ({})
      self.summary_ws_url = summary_ws_url

      # get all criteria used in each round
      rubric = get_questions_by_assignment(assignment)

      # get all teams in this assignment
      teams = Team.select(:id, :name).where(parent_id: assignment.id).order(:name)

      teams.each do |reviewee|
        summarize_reviews_by_team_reviewee(assignment, reviewee, rubric)
        self.avg_scores_by_reviewee[reviewee.name] = calculate_avg_score_by_reviewee(self.avg_scores_by_round[reviewee.name], assignment.rounds_of_reviews)
      end

      self
    end

    # get answers and average scores for each team
    def summarize_reviews_by_team_reviewee(assignment, reviewee, rubric)
      self.summary[reviewee.name] = []
      self.avg_scores_by_reviewee[reviewee.name] = 0.0
      self.avg_scores_by_round[reviewee.name] = self.avg_scores_by_criterion[reviewee.name] = []

      # get the name of reviewers for display only
      self.reviewers[reviewee.name] = get_reviewers_by_reviewee_and_assignment(reviewee, assignment.id)

      # get answers and average scores of each round by rubric
      (0..assignment.rounds_of_reviews - 1).each do |round|
        self.summary[reviewee.name][round] = {}
        self.avg_scores_by_round[reviewee.name][round] = 0.0
        self.avg_scores_by_criterion[reviewee.name][round] = {}
        summarize_by_reviewee_round(assignment, reviewee, round, rubric)
      end
    end

    # get answers and averge score for each question in a round
    def summarize_by_reviewee_round(assignment, reviewee, round, rubric)
      threads = []
      # if use the same rubric, only use rubric[0]
      rubric_questions_used = rubric[assignment.varying_rubrics_by_round? ? round : 0]
      rubric_questions_used.each do |q|
        next if q.type.eql?("SectionHeader")

        # get all answers to this question
        question_answers = Answer.answers_by_question_for_reviewee_in_round(assignment.id, reviewee.id, q.id, round + 1)

        # get score and summary of answers for each question
        self.avg_scores_by_criterion[reviewee.name][round][q.txt] = calculate_avg_score_by_criterion(question_answers, get_max_score_for_question(q))

        threads << Thread.new do
          self.summary[reviewee.name][round][q.txt] = summarize_sentences(break_up_comments_to_sentences(question_answers), self.summary_ws_url)
        end
      end
      avg_scores_by_round = calculate_avg_score_by_round(self.avg_scores_by_criterion[reviewee.name][round], rubric_questions_used)
      self.avg_scores_by_round[reviewee.name][round] = avg_scores_by_round
      # Wait for all threads to end
      end_threads(threads)
    end

    def get_max_score_for_question(question)
      question.type.eql?("Checkbox") ? 1 : Questionnaire.where(id: question.questionnaire_id).first.max_question_score
    end

    def summarize_sentences(comments, summary_ws_url)
      logger = Logger.new(STDOUT)
      logger.level = Logger::WARN
      param = {sentences: comments}
      # call web service
      begin
        sum_json = RestClient.post summary_ws_url, param.to_json, content_type: :json, accept: :json
        # store each summary in a hashmap and use the question as the key
        summary = JSON.parse(sum_json)["summary"]
        ps = PragmaticSegmenter::Segmenter.new(text: summary)
        return ps.segment
      rescue StandardError => err
        logger.warn "Standard Error: #{err.inspect}"
      end
    end

    # convert answers to each question to sentences
    def get_sentences(ans)
      sentences = ans.comments.gsub!(/[.?!]/, '\1|').split('|').map!(&:strip) unless ans.comments.nil?
      sentences
    end

    def break_up_comments_to_sentences(question_answers)
      # store answers of each question in an array to be converted into json
      comments = []
      question_answers.each do |ans|
        sentences = get_sentences(ans)
        # add the comment to an array to be converted as a json request
        comments.concat(sentences) unless sentences.nil?
      end
      comments
    end

    # E1936 team recommends this method be REMOVED
    #   it does not seem to be used anywhere in Expertiza as of 4/21/19
    #   aside from in methods which are themselves not used anywhere in Expertiza as of 4/21/19
    def get_questions_by_assignment(assignment)
      rubric = []
      (0..assignment.rounds_of_reviews - 1).each do |round|
        rubric[round] = nil
        if assignment.vary_by_round
          # get rubric id in each round
          # E1936 team did not update this usage of review_questionnaire_id() to include topic,
          #   because this method does not seem to be used anywhere in Expertiza
          #   as noted in method block comment above
          questionnaire_id = assignment.review_questionnaire_id(round + 1)
          # get criteria in the corresponding rubric (each round may use different rubric)
          rubric[round] = Question.where(questionnaire_id: assignment.review_questionnaire_id(round + 1)).order(:seq)
        else
          # if use the same rubric then query only once at the beginning and store them in the rubric[0]
          # E1936 team did not update this usage of review_questionnaire_id() to include topic,
          #   because this method does not seem to be used anywhere in Expertiza
          #   as noted in method block comment above
          questionnaire_id = questionnaire_id.nil? ? assignment.review_questionnaire_id : questionnaire_id
          rubric[0] = rubric[0].nil? ? Question.where(questionnaire_id: questionnaire_id).order(:seq) : rubric[0]
        end
      end
      rubric
    end

    def get_reviewers_by_reviewee_and_assignment(reviewee, assignment_id)
      reviewers = User.select(" DISTINCT users.name")
                      .joins("JOIN participants ON participants.user_id = users.id")
                      .joins("JOIN response_maps ON response_maps.reviewer_id = participants.id")
                      .where("response_maps.reviewee_id = ? and response_maps.reviewed_object_id = ?", reviewee.id, assignment_id)
      reviewers.map(&:name)
    end

    def calculate_avg_score_by_criterion(question_answers, q_max_score)
      # get score and summary of answers for each question
      # only include divide the valid_answer_sum with the number of valid answers

      valid_answer_counter = 0
      question_score = 0.0
      question_answers.each do |ans|
        # calculate score per question
        unless ans.answer.nil?
          question_score += ans.answer
          valid_answer_counter += 1
        end
      end

      if valid_answer_counter > 0 and q_max_score > 0
        # convert the score in percentage
        question_score /= (valid_answer_counter * q_max_score)
        question_score = question_score.round(2) * 100
      end

      question_score
    end

    def calculate_round_score(avg_scores_by_criterion, criteria)
      round_score = sum_weight = 0.0
      criteria.each do |q|
        # include this score in the average round score if the weight is valid & q is criterion
        if !q.weight.nil? and q.weight > 0 and q.type.eql?("Criterion")
          round_score += avg_scores_by_criterion[q.txt] * q.weight
          sum_weight += q.weight
        end
      end

      round_score /= sum_weight if sum_weight > 0 and round_score > 0
      round_score
    end

    def calculate_avg_score_by_round(avg_scores_by_criterion, criteria)
      round_score = calculate_round_score(avg_scores_by_criterion, criteria)
      round_score.round(2)
    end

    def calculate_avg_score_by_reviewee(avg_scores_by_round, nround)
      sum_scores = 0.0

      avg_scores_by_round.each do |score|
        sum_scores += score
      end

      # calculate avg score per reviewee
      sum_scores /= nround if nround > 0 and sum_scores > 0
      sum_scores.round(2)
    end
  end
end

# end required by autosummary
