module AssignmentHelper

  def setup_questionnaire
    @selected_questionnaires = Hash.new

    @selected_questionnaire[:review] = @assignment.questionnaires.find_by_type('ReviewQuestionnaire')
    @selected_questionnaire[:metareview] = @assignment.questionnaires.find_by_type('MetareviewQuestionnaire')
    @selected_questionnaire[:feedback] = @assignment.questionnaires.find_by_type('AuthorFeedbackQuestionnaire')
    @selected_questionnaire[:teammate] = @assignment.questionnaires.find_by_type('TeammateReviewQuestionnaire')

    @available_questionnaires[:review] = ReviewQuestionnaires.find_all_by_instructor_id(@owner.id)
    @available_questionnaires[:metareview] = MetareviewQuestionnaire.find_all_by_instructor_id(@owner.id)
    @available_questionnaires[:feedback] = AuthorFeedbackQuestionnaire.find_all_by_instructor_id(@owner.id)
    @available_questionnaires[:teammate] = TeammateReviewQuestionnaire.find_all_by_instructor_id(@owner.id)

    if @selected_questionnaire[:review].nil?
      @weights[:review] = @default_weights[:review]
      @limits[:review] = @default_notification_limit
    else
      assignment_questionnaire = AssignmentQuestionnaire.find_by_assignment_id_and_questionnaire_id(@assignment.id, @selected_questionnaire[:review].id)
      @weights[:review] = assignment_questionnaire.questionnaire_weight
      @limits[:review] = assignment_questionnaire.notification_limit
    end

    if @selected_questionnaire[:metareview].nil?
      @weights[:metareview] = @default_weights[:metareview]
      @limits[:metareview] = @default_notification_limit
    else
      assignment_questionnaire = AssignmentQuestionnaire.find_by_assignment_id_and_questionnaire_id(@assignment.id, @selected_questionnaire[:metareview].id)
      @weights[:metareview] = assignment_questionnaire.questionnaire_weight
      @limits[:metareview] = assignment_questionnaire.notification_limit
    end

    if @selected_questionnaire[:feedback].nil?
      @weights[:feedback] = @default_weights[:feedback]
      @limits[:feedback] = @default_notification_limit
    else
      assignment_questionnaire = AssignmentQuestionnaire.find_by_assignment_id_and_questionnaire_id(@assignment.id, @selected_questionnaire[:feedback].id)
      @weights[:feedback] = assignment_questionnaire.questionnaire_weight
      @limits[:feedback] = assignment_questionnaire.notification_limit
    end

    if @selected_questionnaire[:teammate].nil?
      @weights[:teammate] = @default_weights[:teammate]
      @limits[:teammate] = @default_notification_limit
    else
      assignment_questionnaire = AssignmentQuestionnaire.find_by_assignment_id_and_questionnaire_id(@assignment.id, @selected_questionnaire[:teammate].id)
      @weights[:teammate] = assignment_questionnaire.questionnaire_weight
      @limits[:teammate] = assignment_questionnaire.notification_limit
    end
  end
  def get_rubric_weights
    @weights = Hash.new

    @weights[:review] = 100
    @weights[:metareview] = 0
    @weights[:feedback] = 0
    @weights[:teammate] = 0

    @assignment.questionnaires.each do |questionnaire|
      @weights[questionnaire.symbol] = questionnaire.questionnaire_weight
    end
  end
  def get_notification_limits
    @limits = Hash.new

    @limits[:review] = @default_notification_limit
    @limits[:metareview] = @default_notification_limit
    @limits[:feedback] = @default_notification_limit
    @limits[:teammate] = @default_notification_limit

    @assignment.questionnaires.each do |questionnaire|
      @limits[questionnaire.symbol] = questionnaire.notification_limit
    end
  end
  def set_limits_and_weights
    if session[:user].role.name == "Teaching Assistant"
      user_id = TA.get_my_instructor(session[:user]).id
    else
      user_id = session[:user].id
    end

    default = AssignmentQuestionnaire.find_by_user_id_and_assignment_id_and_questionnaire_id(user_id, nil, nil)

    @assignment.questionnaires.each {
        |questionnaire|

      aq = AssignmentQuestionnaire.find_by_assignment_id_and_questionnaire_id(@assignment.id, questionnaire.id)
      if params[:limits][questionnaire.symbol].length > 0
        aq.update_attribute('notification_limit', params[:limits][questionnaire.symbol])
      else
        aq.update_attribute('notification_limit', default.notification_limit)
      end
      aq.update_attribute('questionnaire_weight', params[:weights][questionnaire.symbol])
      aq.update_attribute('user_id', user_id)
    }
  end

end
