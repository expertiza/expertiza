class ReviewMetricMapping < ActiveRecord::Base
  attr_accessible :id, :value, :review_metrics_id, :responses_id
  belongs_to :review_metric
  belongs_to :response
  validates :review_metrics_id, presence: true
  validates :responses_id, presence: true
  validates :value, presence: true
end

def self.calculate_metrics_for_instructor(assignment_id, reviewer_id)
  type = "ReviewResponseMap"
  answers = Answer.joins("join responses on responses.id = answers.response_id")
                  .joins("join response_maps on responses.map_id = response_maps.id")
                  .where("response_maps.reviewed_object_id = ? and response_maps.reviewer_id = ? and response_maps.type = ? and responses.is_submitted = 1", assignment_id, reviewer_id, type)
                  .select("answers.comments, answers.response_id, responses.round, response_maps.reviewee_id, responses.is_submitted").order("answers.response_id")
  suggestive_words = TEXT_METRICS_KEYWORDS['suggestive']
  offensive_words = TEXT_METRICS_KEYWORDS['offensive']
  problem_words = TEXT_METRICS_KEYWORDS['problem']
  current_response_id = nil
  response_level_comments = Hash.new
  metrics = Hash.new
  metrics_per_reviewee = Hash.new
  response_reviewee_map = Hash.new
  diff_word_count = Hash.new
  complete_sentences = Hash.new(0)
  answers.each do |ans|
    # puts ans.comments
    comment = ans.comments
    response_reviewee_map[ans.response_id] = ans.reviewee_id
    if current_response_id.nil? or current_response_id != ans.response_id
      current_response_id = ans.response_id
      response_level_comments[current_response_id] = comment
    else
      response_level_comments[current_response_id] = response_level_comments[current_response_id] + comment
    end
  end
  denom = response_level_comments.length
  response_level_comments.each_pair do |key, value|
    word_counter = 0
    offensive_metric = 0
    suggestive_metric = 0
    problem_metric = 0
    is_offensive_term = false
    is_suggestion = false
    is_problem = false
    value.scan(/[\w']+/).each do |word|
      word_counter += 1
      if offensive_words.include? word
        is_offensive_term = true
      end
      if suggestive_words.include? word
        is_suggestion = true
      end
      if problem_words.include? word
        is_problem = true
      end
    end

    # diff_word_count = response_level_comments[current_response_id].scan(/[\w']+/).uniq.count
    if ReviewMetric.exists?(response_id: key)
      obj = ReviewMetric.find_by(response_id: key)
    else
      obj = ReviewMetric.new
      obj.response_id = key
    end
    # puts "Suggestion: #{is_suggestion}, Offensive: #{is_offensive_term}, Problem: #{is_problem}"
    obj.update_attribute(:volume, word_counter)
    obj.update_attribute(:suggestion, is_suggestion)
    obj.update_attribute(:offensive_term, is_offensive_term)
    obj.update_attribute(:problem, is_problem)
    obj.save!
    # puts "Object-Suggestion: #{obj.suggestion}, Object-Offensive: #{obj.offensive_term}, Object-Problem: #{obj.problem}"
    answers.each do |ans|
      diff_word_count[ans.response_id] = response_level_comments[ans.response_id].scan(/[\w']+/).uniq.count
    end
    metrics[key] = [key, response_reviewee_map[key], word_counter, is_suggestion, is_problem, is_offensive_term, diff_word_count[key]]
  end
  metrics_per_round = Hash.new
  temp_dict = Hash.new
  answers.each do |ans|

    puts "Reviewee Id: #{ans.reviewee_id} ---> Response Id: #{ans.response_id} --> Round: #{ans.round} --> Is Submitted: #{ans.is_submitted}"
    unless temp_dict.has_key?(ans.response_id)
      temp_dict[ans.response_id] = metrics[ans.response_id]
      metrics_per_round[ans.round] = metrics_per_round.fetch(ans.round, []) + [temp_dict[ans.response_id]]
    end
  end
  # puts metrics_per_reviewee
  # puts metrics_per_round
  metrics_per_round
end

def self.calculate_metrics_for_student(response_id)
  type = "ReviewResponseMap"
  concatenated_comment = ''
  answers = Answer.where("answers.response_id = ? ", response_id).select("answers.comments")
  suggestive_words = TEXT_METRICS_KEYWORDS['suggestive']
  offensive_words = TEXT_METRICS_KEYWORDS['offensive']
  problem_words = TEXT_METRICS_KEYWORDS['problem']
  current_response_id = nil
  is_offensive_term = false
  is_suggestion = false
  is_problem = false
  volume = 0
  complete_sentences = 0
  diff_word_count = 0
  answers.each do |ans|
    ans_word_count = 0
    comments = ans.comments
    comments.scan(/[\w']+/).each do |word|
      ans_word_count += 1
    end # end for comments.scan
    concatenated_comment += comments
    if (ans_word_count > 7)
      complete_sentences += 1
    end # end for if(ans_word_count > 7)
  end # end for answers.each

  concatenated_comment.scan(/[\w']+/).each do |word|
    volume += 1

    is_offensive_term = offensive_words.include?

    is_suggestion = suggestive_words.include?

    is_problem = problem_words.include?

  end # end of concatenate_comment

  diff_word_count = concatenated_comment.scan(/[\w']+/).uniq.count

  [volume, is_offensive_term, is_suggestion, is_problem, complete_sentences, diff_word_count]

end