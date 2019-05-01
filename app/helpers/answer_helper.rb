#E1924 Spring 2019 Addition

module AnswerHelper
	def self.get_answers(questionnaire_id,question_ids)
    response_ids=[]
    question_ids.each do |question|
      response_ids=response_ids+Answer.where(question_id: question).pluck("response_id")
    end
    response_ids=response_ids.uniq
    user_id_to_answers={}
    response_ids.each do |response|
      response_map_id = Response.where(id: response).pluck(:map_id)
      reviewer_id = ResponseMap.where(id: response_map_id).pluck(:reviewer_id, :reviewed_object_id)
      assignment_name = Assignment.where(id: reviewer_id[0][1]).pluck(:name)
      user_details = User.where(id: reviewer_id[0][0]).pluck(:email, :name)
      answers_per_user = Answer.where(response_id: response).pluck(:comments)
      user_id_to_answers[response] = [user_details[0][0], answers_per_user, user_details[0][1], assignment_name] unless user_details.empty?
		end

    # Mail the answers to each user and if successfull, delete the answers
    begin
	    user_id_to_answers.each do |response, answers|
	      if self.review_mailer(answers[0], answers[1], answers[2], answers[3])
	        self.delete_answers(response)
	      end
	    end
	  rescue StandardError
      raise $ERROR_INFO
    end
  end

  def self.review_mailer(email, answers, name, assignment_name)
    begin
      Mailer.notify_review_rubric_change(
        to: email,
        subject: 'Expertiza Notification: The review rubric has been changed, please re-attempt the review',
        body: {
          name: name,
          assignment_name: assignment_name,
          answers: answers
        }
        ).deliver_now
      true
    rescue StandardError
      raise $ERROR_INFO
      false
    end
  end

  def self.delete_answers(response_id)
    response = Answer.where(response_id: response_id)
    response.each do |answer|
      begin
        answer.destroy
        true
      rescue StandardError
        raise $ERROR_INFO
      end
    end
  end
 end