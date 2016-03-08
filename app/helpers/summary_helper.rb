#require for webservice calls
require 'json'
require 'rest_client'

module SummaryHelper
  def get_max_score_for_question(question)
    question.type.eql?("Checkbox") ? 1 : Questionnaire.where(:id => question.questionnaire_id).first.max_question_score
  end

  def summarize_sentences(comments, summary_ws_url)
    summary = ""
    param = {:sentences => comments}
    # call web service
    begin
      sum_json = RestClient.post summary_ws_url, param.to_json, :content_type => :json, :accept => :json
      # store each summary in a hashmap and use the question as the key
      summary = JSON.parse(sum_json)["summary"]
    rescue => err
      summary = err.message
    end
    return summary
  end

  def breakup_comments_to_sentences(question_answers)
    #strore answers of each question in an array to be converted into json
    comments = Array.new
    question_answers.each do |ans|
      if !ans.comments.nil?
        ans.comments.gsub!(/[.?!]/, '\1|')
        sentences = ans.comments.split('|')
        sentences.map! { |s| s.strip }
      end
      #add the comment to an array to be converted as a json request
      comments.concat(sentences)
    end
    return comments
  end

  def get_questions_by_assignment(assignment)

    rubric = Array.new
    for round in 0..assignment.rounds_of_reviews-1
      rubric[round] = nil
      if assignment.varying_rubrics_by_round?
        #get rubric id in each round
        questionnaire_id = assignment.get_review_questionnaire_id(round+1)
        #get questions in the corresponding rubric (each round may use different rubric)
        rubric[round] = Question.where(:questionnaire_id => questionnaire_id).order(:seq)
      else
        # if use the same rubric then query only once at the beginning and store them in the rubric[0]
        questionnaire_id = questionnaire_id.nil? ? assignment.get_review_questionnaire_id() : questionnaire_id
        rubric[0] = rubric[0].nil? ? Question.where(:questionnaire_id => questionnaire_id).order(:seq) : rubric[0]
      end
    end
    return rubric
  end

  def get_reviewers_by_reviewee_and_assignment(reviewee, assignment_id)
    reviewers = User.select(" DISTINCT users.name")
                    .joins("JOIN participants ON participants.user_id = users.id")
                    .joins("JOIN response_maps ON response_maps.reviewer_id = participants.id")
                    .where("response_maps.reviewee_id = ? and response_maps.reviewed_object_id = ?", reviewee.id, assignment_id)
    return reviewers.map{|r| r.name}
  end

  def calculate_avg_score_by_criterion(question_answers, q_max_score)

    #get score and summary of answers for each question
    #only include divide the valid_answer_sum with the number of valid answers

    valid_answer_counter = 0
    question_score = 0.0
    question_answers.each do |ans|
      #calculate score per question
      if !ans.answer.nil?
        question_score += ans.answer
        valid_answer_counter += 1
      end
    end

    if valid_answer_counter > 0 and q_max_score > 0
      #convert the score in percentage
      question_score /= (valid_answer_counter * q_max_score)
      question_score = question_score.round(2) * 100
    end

    return question_score
  end

  def calculate_avg_score_by_round(avg_scores_by_question, questions)
    round_score = 0.0
    sum_weight = 0

    questions.each do |q|
      #include this score in the average round score if the weight is valid & q is criterion
      if !q.weight.nil? and q.weight > 0 and q.type.eql?("Criterion")
        round_score += avg_scores_by_question[q.txt] * q.weight
        sum_weight += q.weight
      end
    end


    if sum_weight > 0 and round_score > 0
      round_score /= sum_weight
    end

    return round_score.round(2)
  end

  def calculate_avg_score_by_reviewee(avg_scores_by_round, nround)

    sum_scores = 0.0

    avg_scores_by_round.each do |score|
      sum_scores += score
    end

    # calculate avg score per reviewee
    if nround>0 and sum_scores > 0
      sum_scores /= nround
    end

    return sum_scores.round(2)
  end

  extend self
end