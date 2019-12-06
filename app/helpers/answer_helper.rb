#E1924 Spring 2019 Addition

module AnswerHelper

  #Function will serve 2 purposes
  #One - Identify the existing responses for the modified questionnaire in the database 	
  #Two - Mail the response to the user and delete the object in the database
  def self.delete_existing_responses(question_ids, questionnaire_id)
    response_ids=[]
    question_ids.each do |question|
      Answer.where(question_id: question).each do |answer|
        response_ids << answer.response_id if self.in_active_period(questionnaire_id, answer)
      end
    end
    response_ids=response_ids.uniq
    user_id_to_answers={}
    response_ids.each do |response_id|
      response_map = Response.find(response_id).response_map
      reviewer_id = response_map.reviewer_id
      reviewed_object_id = response_map.reviewed_object_id
      assignment_name = Assignment.find(reviewed_object_id).name
      user = Participant.find(reviewer_id).user
      answers_per_user = Answer.find_by(response_id: response_id).comments
      user_id_to_answers[response_id] = [user.email, answers_per_user, user.name, assignment_name] unless user.nil?
		end

    # Second part of the function that mails the answers to each user and if successfull, delete the answers
    begin
	    user_id_to_answers.each do |response_id, answers|
	      self.delete_answers(response_id) if self.review_mailer(answers[0], answers[1], answers[2], answers[3])
	    end
	  rescue StandardError
      raise $ERROR_INFO
    end
  end

  #Mail the existing response in the databse to the reviewer 
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

  #Delete the answers to the modified questionnaire
  def self.delete_answers(response_id)
    response = Response.find(response_id)
    response.is_submitted = false
    response.save!
    answers = Answer.where(response_id: response_id)
    answers.each do |answer|
      begin
        answer.destroy
        true
      rescue StandardError
        raise $ERROR_INFO
        false
      end
    end
  end

  def self.in_active_period(questionnaire_id, answer=nil)
    assignment, round_number = AssignmentQuestionnaire.get_latest_assignment(questionnaire_id)
    unless assignment.nil?
      start_dates, end_dates = assignment.find_review_period(round_number)
      time_now = Time.zone.now
      time_now = answer.response.created_at unless answer.nil?
      # There can be multiple possible review periods: If round_number is nil, all rounds of reviews use the same questionnaire.
      # If it is in any of the possible review period now, return true.
      start_dates.zip(end_dates).each do |start_date, end_date|
        return true if start_date.due_at < time_now && end_date.due_at > time_now
      end
    end
    false
  end
end
