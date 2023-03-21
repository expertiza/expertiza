# this class has 2 sub-classes: CourseSurveyResponseMap and AssignmentSurveyResponseMap
# The reviewed_object id is either assignment or course id;
# The reviewer_id is either assignment participant id or course participant id;
# The reviewee_id is survey_deployment id.
# (if global survey is required, the reviewee_id will also be survey_deployment id)
class SurveyResponseMap < ResponseMap
  def survey?
    true
  end

  def email(defn, participant, survey_parent)
    user = User.find(participant.user_id)
    defn[:body][:type] = 'Survey Submission'
    defn[:body][:obj_name] = survey_parent.name
    defn[:body][:first_name] = user.fullname
    defn[:to] = user.email
    Mailer.sync_message(defn).deliver_now
  end
end
