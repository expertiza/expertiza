# require for webservice calls
require 'json'
require 'rest_client'
require 'logger'

# required by autosummary
module SummaryHelper
  class Summary
    attr_accessor :summary, :reviewers, :avg_scores_by_reviewee, :avg_scores_by_round, :avg_scores_by_criterion, :summary_ws_url

    def summarize_reviews_by_reviewee(questions, assignment, reviewee_id, summary_ws_url, _session = nil)
      self.summary = ({})
      self.avg_scores_by_round = ({})
      self.avg_scores_by_criterion = ({})
      self.summary_ws_url = summary_ws_url
      
      # get all answers for each question and send them to summarization WS
      questions.each_with_index do |question, index|
        round = index + 1
        summary[round.to_s] = {}
        avg_scores_by_criterion[round.to_s] = {}
        avg_scores_by_round[round.to_s] = 0.0
        
        question_iterator = nil
        if question[1] == nil
          question_iterator = [*question]
        else
          question_iterator = question[1]
        end

        question_iterator.each do |question| 
          next if question.type.eql?('SectionHeader')

          summarize_reviews_by_reviewee_question(assignment, reviewee_id, question, round)
          avg_scores_by_round[round.to_s] = calculate_avg_score_by_round(avg_scores_by_criterion[round.to_s], questions[round])
        end
      end
      self
    end

    # get average scores and summary for each question in a review by a reviewer
    def summarize_reviews_by_reviewee_question(assignment, reviewee_id, question, round)
      question_answers = Answer.answers_by_question_for_reviewee(assignment.id, reviewee_id, question.id)

      avg_scores_by_criterion[round.to_s][question.txt] = calculate_avg_score_by_criterion(question_answers, get_max_score_for_question(question))

      summary[round.to_s][question.txt] = summarize_sentences(break_up_comments_to_sentences(question_answers), summary_ws_url)
    end

    def get_max_score_for_question(question)
      question.type.eql?('Checkbox') ? 1 : Questionnaire.where(id: question.questionnaire_id).first.max_question_score
    end

    def summarize_sentences(comments, summary_ws_url)
      logger = Logger.new(STDOUT)
      logger.level = Logger::WARN
      param = { sentences: comments }
      # call web service
      begin
        sum_json = RestClient.post summary_ws_url, param.to_json, content_type: :json, accept: :json
        # store each summary in a hashmap and use the question as the key
        summary = JSON.parse(sum_json)['summary']
        ps = PragmaticSegmenter::Segmenter.new(text: summary)
        return ps.segment
      rescue StandardError => e
        logger.warn "Standard Error: #{e.inspect}"
        return ['Problem with WebServices', 'Please contact the Expertiza Development team']
      end
    end

    # convert answers to each question to sentences
    def get_sentences(answer)
      sentences = answer.comments.gsub!(/[.?!]/, '\1|').try(:split, '|') || nil unless answer.nil? || answer.comments.nil?
      sentences.map!(&:strip) unless sentences.nil?
      sentences
    end

    def break_up_comments_to_sentences(question_answers)
      # store answers of each question in an array to be converted into json
      comments = []
      question_answers.each do |answer|
        sentences = get_sentences(answer)
        # add the comment to an array to be converted as a json request
        comments.concat(sentences) unless sentences.nil?
      end
      comments
    end

    def calculate_avg_score_by_criterion(question_answers, q_max_score)
      # get score and summary of answers for each question
      # only include divide the valid_answer_sum with the number of valid answers

      valid_answer_counter = 0
      question_score = 0.0
      question_answers.each do |question_answer|
        # calculate score per question
        unless question_answer.answer.nil?
          question_score += question_answer.answer
          valid_answer_counter += 1
        end
      end

      if (valid_answer_counter > 0) && (q_max_score > 0)
        # convert the score in percentage
        question_score /= (valid_answer_counter * q_max_score)
        question_score = question_score.round(2) * 100
      end

      question_score
    end

    def calculate_round_score(avg_scores_by_criterion, criterions)
      round_score = sum_weight = 0.0
      # include this score in the average round score if the weight is valid & q is criterion
      criterions = [*criterions]
      criterions.each do |criteria|
        if !criteria.weight.nil? && (criteria.weight > 0) && criteria.type.eql?('Criterion')
          round_score += avg_scores_by_criterion.values.first * criteria.weight
          sum_weight += criteria.weight
        end
      end
      round_score /= sum_weight if (sum_weight > 0) && (round_score > 0)
      round_score
    end

    def calculate_avg_score_by_round(avg_scores_by_criterion, criterions)
      round_score = calculate_round_score(avg_scores_by_criterion, criterions)
      round_score.round(2)
    end
  end
end

# end required by autosummary
