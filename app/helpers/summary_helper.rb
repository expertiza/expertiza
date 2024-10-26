# require for webservice calls
require 'json'
require 'rest_client'
require 'logger'

# required by autosummary
module SummaryHelper
  class Summary
    attr_accessor :summary, :reviewers, :avg_scores_by_reviewee, :avg_scores_by_round, :avg_scores_by_criterion, :summary_ws_url

    def summarize_reviews_by_reviewee(items, assignment, reviewee_id, summary_ws_url, _session = nil)
      self.summary = ({})
      self.avg_scores_by_round = ({})
      self.avg_scores_by_criterion = ({})
      self.summary_ws_url = summary_ws_url
      
      # get all answers for each item and send them to summarization WS
      items.each_with_index do |item, index|
        round = index + 1
        summary[round.to_s] = {}
        avg_scores_by_criterion[round.to_s] = {}
        avg_scores_by_round[round.to_s] = 0.0
        
        item_iterator = nil
        if item[1] == nil
          item_iterator = [*item]
        else
          item_iterator = item[1]
        end

        item_iterator.each do |item| 
          next if item.type.eql?('SectionHeader')

          summarize_reviews_by_reviewee_item(assignment, reviewee_id, item, round)
          avg_scores_by_round[round.to_s] = calculate_avg_score_by_round(avg_scores_by_criterion[round.to_s], items[round])
        end
      end
      self
    end

    # get average scores and summary for each item in a review by a reviewer
    def summarize_reviews_by_reviewee_item(assignment, reviewee_id, item, round)
      item_answers = Answer.answers_by_item_for_reviewee(assignment.id, reviewee_id, item.id)

      avg_scores_by_criterion[round.to_s][item.txt] = calculate_avg_score_by_criterion(item_answers, get_max_score_for_item(item))

      summary[round.to_s][item.txt] = summarize_sentences(break_up_comments_to_sentences(item_answers), summary_ws_url)
    end

    def get_max_score_for_item(item)
      item.type.eql?('Checkbox') ? 1 : Questionnaire.where(id: item.itemnaire_id).first.max_item_score
    end

    def summarize_sentences(comments, summary_ws_url)
      logger = Logger.new(STDOUT)
      logger.level = Logger::WARN
      param = { sentences: comments }
      # call web service
      begin
        sum_json = RestClient.post summary_ws_url, param.to_json, content_type: :json, accept: :json
        # store each summary in a hashmap and use the item as the key
        summary = JSON.parse(sum_json)['summary']
        ps = PragmaticSegmenter::Segmenter.new(text: summary)
        return ps.segment
      rescue StandardError => e
        logger.warn "Standard Error: #{e.inspect}"
        return ['Problem with WebServices', 'Please contact the Expertiza Development team']
      end
    end

    # convert answers to each item to sentences
    def get_sentences(answer)
      sentences = answer.comments.gsub!(/[.?!]/, '\1|').try(:split, '|') || nil unless answer.nil? || answer.comments.nil?
      sentences.map!(&:strip) unless sentences.nil?
      sentences
    end

    def break_up_comments_to_sentences(item_answers)
      # store answers of each item in an array to be converted into json
      comments = []
      item_answers.each do |answer|
        sentences = get_sentences(answer)
        # add the comment to an array to be converted as a json request
        comments.concat(sentences) unless sentences.nil?
      end
      comments
    end

    def calculate_avg_score_by_criterion(item_answers, q_max_score)
      # get score and summary of answers for each item
      # only include divide the valid_answer_sum with the number of valid answers

      valid_answer_counter = 0
      item_score = 0.0
      item_answers.each do |item_answer|
        # calculate score per item
        unless item_answer.answer.nil?
          item_score += item_answer.answer
          valid_answer_counter += 1
        end
      end

      if (valid_answer_counter > 0) && (q_max_score > 0)
        # convert the score in percentage
        item_score /= (valid_answer_counter * q_max_score)
        item_score = item_score.round(2) * 100
      end

      item_score
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
