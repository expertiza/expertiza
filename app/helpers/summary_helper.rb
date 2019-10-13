# require for webservice calls
require 'json'
require 'rest_client'

# required by autosummary
module SummaryHelper
  class Summary
    attr_accessor :summary, :reviewers, :avg_scores_by_reviewee, :avg_scores_by_round, :avg_scores_by_criterion

    def summarize_reviews_by_reviewee(questions, assignment, r_id, summary_ws_url)
      self.summary = ({})
      self.avg_scores_by_round = ({})
      self.avg_scores_by_criterion = ({})

      # get all answers for each question and send them to summarization WS
      questions.keys.each do |round|
        self.summary[round.to_s] = {}
        self.avg_scores_by_criterion[round.to_s] = {}
        self.avg_scores_by_round[round.to_s] = 0.0
        included_question_counter = 0

        questions[round].each do |q|
          next if q.type.eql?("SectionHeader")

          self.summary[round.to_s][q.txt] = ""
          self.avg_scores_by_criterion[round.to_s][q.txt] = 0.0

          question_answers = Answer.answers_by_question_for_reviewee(assignment.id, r_id, q.id)

          max_score = get_max_score_for_question(q)

          comments = break_up_comments_to_sentences(question_answers)

          # get the avg scores for this question
          self.avg_scores_by_criterion[round.to_s][q.txt] = calculate_avg_score_by_criterion(question_answers, max_score)
          # get the summary of answers to this question
          self.summary[round.to_s][q.txt] = summarize_sentences(comments, summary_ws_url)
        end
        self.avg_scores_by_round[round.to_s] = calculate_avg_score_by_round(self.avg_scores_by_criterion[round.to_s], questions[round])
      end
      self
    end

    # produce summaries for instructor. it merges all feedback given to all reviewees, and summarize them by criterion
    def summarize_reviews_by_criterion(assignment, summary_ws_url)
      # @summary[reviewee][round][question]
      # @avg_score_round[reviewee][round]
      # @avg_scores_by_criterion[reviewee][round][criterion]
      nround = assignment.rounds_of_reviews
      self.summary = Array.new(nround)
      self.avg_scores_by_criterion = Array.new(nround)
      self.avg_scores_by_round = Array.new(nround)
      threads = []
      rubric = get_questions_by_assignment(assignment)

      (0..nround - 1).each do |round|
        self.avg_scores_by_round[round] = 0.0
        self.summary[round] = {}
        self.avg_scores_by_criterion[round] = {}

        questions_used_in_round = rubric[assignment.varying_rubrics_by_round? ? round : 0]
        # get answers of each question in the rubric
        questions_used_in_round.each do |question|
          next if question.type.eql?("SectionHeader")
          answers_questions = Answer.answers_by_question(assignment.id, question.id)

          max_score = get_max_score_for_question(question)
          # process each question in a seperate thread
          threads << Thread.new do
            comments = break_up_comments_to_sentences(answers_questions)
            # store each avg in a hashmap and use the question as the key
            self.avg_scores_by_criterion[round][question.txt] = calculate_avg_score_by_criterion(answers_questions, max_score)
            self.summary[round][question.txt] = summarize_sentences(comments, summary_ws_url) unless comments.empty?
          end
          # Wait for all threads to end
          threads.each do |t|
            # Wait for the thread to finish if it isn't this thread (i.e. the main thread).
            t.join if t != Thread.current
          end
        end
        self.avg_scores_by_round[round] = calculate_avg_score_by_round(avg_scores_by_criterion[round], questions_used_in_round)
      end
      self
    end

    # produce summaries for instructor and students. It sum up the feedback by criterion for each reviewee
    def summarize_reviews_by_reviewees(assignment, summary_ws_url)
      # @summary[reviewee][round][question]
      # @reviewers[team][reviewer]
      # @avg_scores_by_reviewee[team]
      # @avg_score_round[reviewee][round]
      # @avg_scores_by_criterion[reviewee][round][criterion]
      self.summary = ({})
      self.avg_scores_by_reviewee = ({})
      self.avg_scores_by_round = ({})
      self.avg_scores_by_criterion = ({})
      self.reviewers = ({})
      threads = []

      # get all criteria used in each round
      rubric = get_questions_by_assignment(assignment)

      # get all teams in this assignment
      teams = Team.select(:id, :name).where(parent_id: assignment.id).order(:name)

      teams.each do |reviewee|
        self.summary[reviewee.name] = []
        self.avg_scores_by_reviewee[reviewee.name] = 0.0
        self.avg_scores_by_round[reviewee.name] = []
        self.avg_scores_by_criterion[reviewee.name] = []

        # get the name of reviewers for display only
        self.reviewers[reviewee.name] = get_reviewers_by_reviewee_and_assignment(reviewee, assignment.id)

        # get answers of each reviewer by rubric
        (0..assignment.rounds_of_reviews - 1).each do |round|
          self.summary[reviewee.name][round] = {}
          self.avg_scores_by_round[reviewee.name][round] = 0.0
          self.avg_scores_by_criterion[reviewee.name][round] = {}

          # iterate each round and get answers
          # if use the same rubric, only use rubric[0]
          rubric_questions_used = rubric[assignment.varying_rubrics_by_round? ? round : 0]
          rubric_questions_used.each do |q|
            next if q.type.eql?("SectionHeader")
            summary[reviewee.name][round][q.txt] = ""
            self.avg_scores_by_criterion[reviewee.name][round][q.txt] = 0.0

            # get all answers to this question
            question_answers = Answer.answers_by_question_for_reviewee_in_round(assignment.id, reviewee.id, q.id, round + 1)
            # get max score of this rubric
            q_max_score = get_max_score_for_question(q)

            comments = break_up_comments_to_sentences(question_answers)
            # get score and summary of answers for each question
            self.avg_scores_by_criterion[reviewee.name][round][q.txt] = calculate_avg_score_by_criterion(question_answers, q_max_score)

            # summarize the comments by calling the summarization Web Service

            # since it'll do a lot of request, do this in seperate threads
            threads << Thread.new do
              summary[reviewee.name][round][q.txt] = summarize_sentences(comments, summary_ws_url) unless comments.empty?
            end
          end
          self.avg_scores_by_round[reviewee.name][round] = calculate_avg_score_by_round(self.avg_scores_by_criterion[reviewee.name][round], rubric_questions_used)
        end
        self.avg_scores_by_reviewee[reviewee.name] = calculate_avg_score_by_reviewee(self.avg_scores_by_round[reviewee.name], assignment.rounds_of_reviews)
      end

      # Wait for all threads to end
      threads.each do |t|
        t.join if t != Thread.current
      end

      self
    end

    def get_max_score_for_question(question)
      question.type.eql?("Checkbox") ? 1 : Questionnaire.where(id: question.questionnaire_id).first.max_question_score
    end

    def summarize_sentences(comments, summary_ws_url)
      summary = ""
      param = {sentences: comments}
      # call web service
      begin
        sum_json = RestClient.post summary_ws_url, param.to_json, content_type: :json, accept: :json
        # store each summary in a hashmap and use the question as the key
        summary = JSON.parse(sum_json)["summary"]
        ps = PragmaticSegmenter::Segmenter.new(text: summary)
        return ps.segment
      rescue StandardError => err
        summary = [err.message]
      end
    end

    def break_up_comments_to_sentences(question_answers)
      # strore answers of each question in an array to be converted into json
      comments = []
      question_answers.each do |ans|
        unless ans.comments.nil?
          ans.comments.gsub!(/[.?!]/, '\1|')
          sentences = ans.comments.split('|')
          sentences.map!(&:strip)
        end
        # add the comment to an array to be converted as a json request
        comments.concat(sentences) unless sentences.nil?
      end
      comments
    end

    def get_questions_by_assignment(assignment)
      rubric = []
      (0..assignment.rounds_of_reviews - 1).each do |round|
        rubric[round] = nil
        if assignment.varying_rubrics_by_round?
          # get rubric id in each round
          questionnaire_id = assignment.review_questionnaire_id(round + 1)
          # get criteria in the corresponding rubric (each round may use different rubric)
          rubric[round] = Question.where(questionnaire_id: questionnaire_id).order(:seq)
        else
          # if use the same rubric then query only once at the beginning and store them in the rubric[0]
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

    def calculate_avg_score_by_round(avg_scores_by_criterion, criteria)
      round_score = 0.0
      sum_weight = 0

      criteria.each do |q|
        # include this score in the average round score if the weight is valid & q is criterion
        if !q.weight.nil? and q.weight > 0 and q.type.eql?("Criterion")
          round_score += avg_scores_by_criterion[q.txt] * q.weight
          sum_weight += q.weight
        end
      end

      round_score /= sum_weight if sum_weight > 0 and round_score > 0

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

  module_function
end

# end required by autosummary
