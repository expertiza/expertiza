module ReportFormatterHelper
  def self.SummaryByRevieweeAndCriteria(params, session)
    summary_ws_url = WEBSERVICE_CONFIG["summary_webservice_url"]
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

  def self.SummaryByCriteria(params, session)
    summary_ws_url = WEBSERVICE_CONFIG["summary_webservice_url"]
    sum = SummaryHelper::Summary.new.summarize_reviews_by_criterion(@assignment, summary_ws_url)

    @summary = sum.summary
    @avg_scores_by_round = sum.avg_scores_by_round
    @avg_scores_by_criterion = sum.avg_scores_by_criterion
  end

  def self.ReviewResponseMap(params, session)
    @assignment = Assignment.find(params[:id])
    @review_user = params[:user]
    # If review response is required call review_response_report method in review_response_map model
    @reviewers = ReviewResponseMap.review_response_report(@id, @assignment, @type, @review_user)
    @review_scores = @assignment.compute_reviews_hash
    @avg_and_ranges = @assignment.compute_avg_and_ranges_hash
  end

  def self.FeedbackResponseMap(params, session)
    @assignment = Assignment.find(params[:id])
    # If review report for feedback is required call feedback_response_report method in feedback_review_response_map model
    if @assignment.varying_rubrics_by_round?
      @authors, @all_review_response_ids_round_one, @all_review_response_ids_round_two, @all_review_response_ids_round_three = FeedbackResponseMap.feedback_response_report(@id, @type)
    else
      @authors, @all_review_response_ids = FeedbackResponseMap.feedback_response_report(@id, @type)
    end
  end

  def self.TeammateReviewResponseMap(params, session)
    # If review report for teammate is required call teammate_response_report method in teammate_review_response_map model
    @reviewers = TeammateReviewResponseMap.teammate_response_report(@id)
  end

  #def self.Calibration(params)
  def self.Collusion(params, session)
    participant = AssignmentParticipant.where(parent_id: params[:id], user_id: session[:user].id).first rescue nil
    if participant.nil?
      participant = AssignmentParticipant.create(parent_id: params[:id], user_id: session[:user].id, can_submit: 1, can_review: 1, can_take_quiz: 1, handle: 'handle')
    end

    @assignment = Assignment.find(params[:id])
    @review_questionnaire_ids = ReviewQuestionnaire.select("id")
    @assignment_questionnaire = AssignmentQuestionnaire.where(assignment_id: params[:id], questionnaire_id: @review_questionnaire_ids).first
    @questions = @assignment_questionnaire.questionnaire.questions.select {|q| q.type == 'Criterion' or q.type == 'Scale' }
    @calibration_response_maps = ReviewResponseMap.where(reviewed_object_id: params[:id], calibrate_to: 1)
    @review_response_map_ids = ReviewResponseMap.select('id').where(reviewed_object_id: params[:id], calibrate_to: 0)
    @responses = Response.where(map_id: @review_response_map_ids)
  end

  def self.PlagiarismCheckerReport(params, session)
    @plagiarism_checker_comparisons = PlagiarismCheckerComparison.where(plagiarism_checker_assignment_submission_id:
                                                                            PlagiarismCheckerAssignmentSubmission.where(assignment_id:
                                                                                                                            params[:id]).pluck(:id))
  end

  def self.AnswerTaggingReport(params, session)
    tag_prompt_deployments = TagPromptDeployment.where(assignment_id: params[:id])
    @questionnaire_tagging_report = {}
    @user_tagging_report = {}
    tag_prompt_deployments.each do |tag_dep|
      @questionnaire_tagging_report[tag_dep] = tag_dep.assignment_tagging_progress
      #generate a summary report per user
      @questionnaire_tagging_report[tag_dep].each do |line|
        if @user_tagging_report[line.user.name].nil?
          @user_tagging_report[line.user.name] = VmUserAnswerTagging.new(line.user, line.percentage, line.no_tagged, line.no_not_tagged, line.no_tagable)
        else
          @user_tagging_report[line.user.name].no_tagged += line.no_tagged
          @user_tagging_report[line.user.name].no_not_tagged += line.no_not_tagged
          @user_tagging_report[line.user.name].no_tagable += line.no_tagable
          @user_tagging_report[line.user.name].percentage = @user_tagging_report[line.user.name].no_tagable == 0 ? "-" : format("%.1f", @user_tagging_report[line.user.name].no_tagged.to_f / @user_tagging_report[line.user.name].no_tagable * 100)
        end
      end
    end
  end

  def self.SelfReview(params, session)
    @self_review_response_maps = SelfReviewResponseMap.where(reviewed_object_id: @id)
  end
end