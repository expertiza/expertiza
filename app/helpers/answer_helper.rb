# E1924 Spring 2019 Addition

module AnswerHelper
  # Delete responses for given questionnaire
  def self.delete_existing_responses(question_ids, questionnaire_id)
    # For each of the question's answers, log the response_id if in active period
    response_ids = log_answer_responses(question_ids, questionnaire_id)

    # For each of the response_ids, log info to be used in answer deletion
    user_id_to_answers = log_response_info(response_ids)

    # For each pair of response_id and answers, delete the answers if the mailer successfully sends mail
    begin
      user_id_to_answers.each do |response_id, answers| # The dictionary has key [response_id] and info as "answers"
        # Feeds review_mailer (email, answers, name, assignment_name) info. Emails and then deletes answers
        delete_answers(response_id) if review_mailer(answers[:email], answers[:answers], answers[:name], answers[:assignment_name])
      end
    rescue StandardError
      raise $ERROR_INFO
    end
  end

  # Log the response_id if in active period for each of the question's answers
  def self.log_answer_responses(question_ids, questionnaire_id)
    response_ids = []
    question_ids.each do |question|
      Answer.where(question_id: question).each do |answer| # For each of the question's answers, log the response_id if in active period
        response_ids << answer.response_id if in_active_period(questionnaire_id, answer)
      end
    end
    response_ids
  end

  # Log info from each response_id to be used in answer deletion
  def self.log_response_info(response_ids)
    user_id_to_answers = {}
    response_ids.uniq.each do |response_id| # For each response id in the array, gather map and info about reviewer
      response_map = Response.find(response_id).response_map
      reviewer_id = response_map.reviewer_id
      reviewed_object_id = response_map.reviewed_object_id
      assignment_name = Assignment.find(reviewed_object_id).name
      user = Participant.find(reviewer_id).user
      answers_per_user = Answer.find_by(response_id: response_id).comments
      # For each response_id, add its info to the dictionary
      user_id_to_answers[response_id] = { email: user.email, answers: answers_per_user, username: user.username, assignment_name: assignment_name } unless user.nil?
    end
    user_id_to_answers
  end

  # Mail the existing response in the database to the reviewer
  def self.review_mailer(email, answers, name, assignment_name)
    # Call the notify_review_rubric_change method in mailer.rb to send an email with given user info
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
  end

  # Delete the users response to the modified questionnaire
  def self.delete_answers(response_id)
    response = Response.find(response_id)
    response.is_submitted = false
    response.save! # Unsubmit the response before destroying it
    Response.find(response_id).destroy
  end

  # The in_active_period method returns true if the start & end range includes the current time
  def self.in_active_period(questionnaire_id, answer = nil)
    assignment, round_number = AssignmentQuestionnaire.get_latest_assignment(questionnaire_id)
    unless assignment.nil? # If the assignment doesn't exist, return false
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

  # Given a questionnaire id, delete all responses to that questionnaire if the current period accepts reviews and return true/false of success
  def self.check_and_delete_responses(questionnaire_id)
    question_ids = Questionnaire.find(questionnaire_id).questions.ids
    if AnswerHelper.in_active_period(questionnaire_id) # confirm current period accepts reviews
      AnswerHelper.delete_existing_responses(question_ids, questionnaire_id) # delete all responses for current questionnaire
      true
    else
      false
    end
  end
end
