module ReportFormatterHelper
  @id = params[:id]
  @assignment = Assignment.find(@id)
  summary_ws_url = WEBSERVICE_CONFIG["summary_webservice_url"]

  def render_report(type, params, session)
    case type
    when "SummaryByRevieweeAndCriteria"
        summary_by_reviewee_and_criteria(params, session)
    when "SummaryByCriteria"
      summary_by_criteria(params, session)
    when "ReviewResponseMap"
      review_response_map(params, session)
    when "FeedbackResponseMap"
      feedback_response_map(params, session)
    when "TeammateReviewResponseMap"
      teammate_review_response_map(params, session)
    when "Calibration"
      calibration(params, session)
    when "PlagiarismCheckerReport"
      plagiarism_checker_report(params, session)
    when "AnswerTaggingReport"
      answer_tagging_report(params, session)
    when "SelfReview"
      self_review(params, session)
    end
  end

  def summary_by_reviewee_and_criteria(_params, _session)
    sum = SummaryHelper::Summary.new.summarize_reviews_by_reviewees(@assignment, summary_ws_url)
    # list of variables used in the view and the parameters (should have been done as objects instead of hash maps)
    # @summary[reviewee][round][question]
    # @reviewers[team][reviewer]
    # @avg_scores_by_reviewee[team]
    # @avg_score_round[reviewee][round]
    # @avg_scores_by_criterion[reviewee][round][criterion]

    @summary = sum.summary
    @reviewers = sum.reviewers
    @avg_scores_by_reviewee = sum.avg_scores_by_reviewee
    @avg_scores_by_round = sum.avg_scores_by_round
    @avg_scores_by_criterion = sum.avg_scores_by_criterion
  end

  def summary_by_criteria(_params, _session)
    sum = SummaryHelper::Summary.new.summarize_reviews_by_criterion(@assignment, summary_ws_url)

    @summary = sum.summary
    @avg_scores_by_round = sum.avg_scores_by_round
    @avg_scores_by_criterion = sum.avg_scores_by_criterion
  end

  def review_response_map(params, _session)
    @review_user = params[:user]
    # If review response is required call review_response_report method in review_response_map model
    @reviewers = ReviewResponseMap.review_response_report(@id, @assignment, @type, @review_user)
    @review_scores = @assignment.compute_reviews_hash
    @avg_and_ranges = @assignment.compute_avg_and_ranges_hash
  end

  def feedback_response_map(params, _session)
    # If review report for feedback is required call feedback_response_report method in feedback_review_response_map model
    if @assignment.varying_rubrics_by_round?
      @authors, @all_review_response_ids_round_one, @all_review_response_ids_round_two, @all_review_response_ids_round_three = FeedbackResponseMap.feedback_response_report(@id, @type)
    else
      @authors, @all_review_response_ids = FeedbackResponseMap.feedback_response_report(@id, @type)
    end
  end

  def teammate_review_response_map(_params, _session)
    # If review report for teammate is required call teammate_response_report method in teammate_review_response_map model
    @reviewers = TeammateReviewResponseMap.teammate_response_report(@id)
  end

  def calibration(params, session)
    participant = AssignmentParticipant.where(parent_id: params[:id], user_id: session[:user].id).first rescue nil
    if participant.nil?
      AssignmentParticipant.create(parent_id: params[:id], user_id: session[:user].id, can_submit: 1, can_review: 1, can_take_quiz: 1, handle: 'handle')
    end

    @review_questionnaire_ids = ReviewQuestionnaire.select("id")
    @assignment_questionnaire = AssignmentQuestionnaire.where(assignment_id: params[:id], questionnaire_id: @review_questionnaire_ids).first
    @questions = @assignment_questionnaire.questionnaire.questions.select {|q| q.type == 'Criterion' or q.type == 'Scale' }
    @calibration_response_maps = ReviewResponseMap.where(reviewed_object_id: params[:id], calibrate_to: 1)
    @review_response_map_ids = ReviewResponseMap.select('id').where(reviewed_object_id: params[:id], calibrate_to: 0)
    @responses = Response.where(map_id: @review_response_map_ids)
  end

  def plagiarism_checker_report(params, _session)
    @plagiarism_checker_comparisons = PlagiarismCheckerComparison.where(plagiarism_checker_assignment_submission_id: PlagiarismCheckerAssignmentSubmission.where(assignment_id: params[:id]).pluck(:id))
  end

  def answer_tagging_report(params, _session)
    tag_prompt_deployments = TagPromptDeployment.where(assignment_id: params[:id])
    @questionnaire_tagging_report = {}
    @user_tagging_report = {}
    tag_prompt_deployments.each do |tag_dep|
      @questionnaire_tagging_report[tag_dep] = tag_dep.assignment_tagging_progress
      # generate a summary report per user
      @questionnaire_tagging_report[tag_dep].each do |line|
        if @user_tagging_report[line.user.name].nil?
          @user_tagging_report[line.user.name] = VmUserAnswerTagging.new(line.user, line.percentage, line.no_tagged, line.no_not_tagged, line.no_tagable)
        else
          @user_tagging_report[line.user.name].no_tagged += line.no_tagged
          @user_tagging_report[line.user.name].no_not_tagged += line.no_not_tagged
          @user_tagging_report[line.user.name].no_tagable += line.no_tagable

          number_tagged = @user_tagging_report[line.user.name].no_tagged.to_f
          number_taggable = @user_tagging_report[line.user.name].no_tagable
          formatted_percentage = format("%.1f",  (number_tagged / number_taggable) * 100)
          @user_tagging_report[line.user.name].percentage =
              @user_tagging_report[line.user.name].no_tagable.zero ? "-" : formatted_percentage
        end
      end
    end
  end

  def self_review(_params, _session)
    @self_review_response_maps = SelfReviewResponseMap.where(reviewed_object_id: @id)
  end
  end
