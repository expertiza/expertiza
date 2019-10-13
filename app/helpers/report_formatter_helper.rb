module ReportFormatterHelper
  def summary_by_reviewee_and_criteria(params, _session = nil)
    assign_basics(params)
    sum = SummaryHelper::Summary.new.summarize_reviews_by_reviewees(@assignment, @summary_ws_url)
    @summary = sum.summary
    @reviewers = sum.reviewers
    @avg_scores_by_reviewee = sum.avg_scores_by_reviewee
    @avg_scores_by_round = sum.avg_scores_by_round
    @avg_scores_by_criterion = sum.avg_scores_by_criterion
  end

  def summary_by_criteria(params, _session = nil)
    assign_basics(params)
    sum = SummaryHelper::Summary.new.summarize_reviews_by_criterion(@assignment, @summary_ws_url)
    @summary = sum.summary
    @avg_scores_by_round = sum.avg_scores_by_round
    @avg_scores_by_criterion = sum.avg_scores_by_criterion
  end

  def review_response_map(params, _session = nil)
    assign_basics(params)
    @review_user = params[:user]
    # If review response is required call review_response_report method in review_response_map model
    @reviewers = ReviewResponseMap.review_response_report(@id, @assignment, @type, @review_user)
    @review_scores = @assignment.compute_reviews_hash
    @avg_and_ranges = @assignment.compute_avg_and_ranges_hash
  end

  def feedback_response_map(params, _session = nil)
    assign_basics(params)
    # If review report for feedback is required call feedback_response_report method in feedback_review_response_map model
    if @assignment.varying_rubrics_by_round?
      @authors, @all_review_response_ids_round_one, @all_review_response_ids_round_two, @all_review_response_ids_round_three =
        FeedbackResponseMap.feedback_response_report(@id, @type)
    else
      @authors, @all_review_response_ids = FeedbackResponseMap.feedback_response_report(@id, @type)
    end
  end

  def teammate_review_response_map(params, _session = nil)
    assign_basics(params)
    @reviewers = TeammateReviewResponseMap.teammate_response_report(@id)
  end

  def calibration(params, session)
    assign_basics(params)
    user = session[:user]
    participant = AssignmentParticipant.where(parent_id: @id, user_id: user.id).first rescue nil
    create_participant(@id, user.id) if participant.nil?
    @review_questionnaire_ids = ReviewQuestionnaire.select("id")
    @assignment_questionnaire = AssignmentQuestionnaire.retrieve_questionnaire_for_assignment(@id).first
    @questions = @assignment_questionnaire.questionnaire.questions.select {|q| q.type == 'Criterion' or q.type == 'Scale' }
    @calibration_response_maps = ReviewResponseMap.where(reviewed_object_id: @id, calibrate_to: 1)
    @review_response_map_ids = ReviewResponseMap.select('id').where(reviewed_object_id: @id, calibrate_to: 0)
    @responses = Response.where(map_id: @review_response_map_ids)
  end

  def plagiarism_checker_report(params, _session = nil)
    assign_basics(params)
    submission_id = PlagiarismCheckerAssignmentSubmission.where(assignment_id: @id).pluck(:id)
    @plagiarism_checker_comparisons = PlagiarismCheckerComparison.where(plagiarism_checker_assignment_submission_id: submission_id)
  end

  def answer_tagging_report(params, _session = nil)
    assign_basics(params)
    tag_prompt_deployments = TagPromptDeployment.where(assignment_id: @id)
    @questionnaire_tagging_report = {}
    @user_tagging_report = {}
    tag_prompt_deployments.each do |tag_dep|
      @questionnaire_tagging_report[tag_dep] = tag_dep.assignment_tagging_progress
      @questionnaire_tagging_report[tag_dep].each do |line|
        user_summary_report(line)
      end
    end
  end

  def self_review(params, _session = nil)
    assign_basics(params)
    @self_review_response_maps = SelfReviewResponseMap.where(reviewed_object_id: @id)
  end

  def basic(params, _session = nil)
    assign_basics(params)
  end

  private

  def assign_basics(params)
    @id = params[:id]
    @assignment = Assignment.find(@id)
    @summary_ws_url = WEBSERVICE_CONFIG['summary_webservice_url']
  end

  def create_participant(parent_id, user_id)
    AssignmentParticipant.create(parent_id: parent_id, user_id: user_id, can_submit: 1, can_review: 1, can_take_quiz: 1, handle: 'handle')
  end

  def user_summary_report(line)
    if @user_tagging_report[line.user.name].nil?
      @user_tagging_report[line.user.name] = VmUserAnswerTagging.new(line.user, line.percentage, line.no_tagged, line.no_not_tagged, line.no_tagable)
    else
      @user_tagging_report[line.user.name].no_tagged += line.no_tagged
      @user_tagging_report[line.user.name].no_not_tagged += line.no_not_tagged
      @user_tagging_report[line.user.name].no_tagable += line.no_tagable
      @user_tagging_report[line.user.name].percentage = calculate_formatted_percentage(line)
    end
  end

  def calculate_formatted_percentage(line)
    number_tagged = @user_tagging_report[line.user.name].no_tagged.to_f
    number_taggable = @user_tagging_report[line.user.name].no_tagable
    formatted_percentage = format("%.1f", (number_tagged / number_taggable) * 100)
    @user_tagging_report[line.user.name].no_tagable.zero? ? '-' : formatted_percentage
  end
end
