class SurveyResponseMap < ResponseMap
  def survey?
    true
  end

  def email(defn, participant, survey_parent)
    user = User.find(participant.user_id)
    defn[:body][:type] = "Survey Submission"
    defn[:body][:obj_name] = survey_parent.name
    defn[:body][:first_name] = user.fullname
    defn[:to] = user.email
    Mailer.sync_message(defn).deliver_now
  end
end
