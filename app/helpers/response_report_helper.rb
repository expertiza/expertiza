module ResponseReportHelper
  # SummaryByRevieweeAndCriteria
  class SummaryRevieweeReport
    def initialize(assignment, summary_ws_url)
      sum = SummaryHelper::Summary.new.summarize_reviews_by_reviewees(assignment, summary_ws_url)
      @summary = sum.summary
      @reviewers = sum.reviewers
      @avg_scores_by_reviewee = sum.avg_scores_by_reviewee
      @avg_scores_by_round = sum.avg_scores_by_round
      @avg_scores_by_criterion = sum.avg_scores_by_criterion
    end

    attr_reader :summary
    attr_reader :reviewers
    attr_reader :avg_scores_by_reviewee
    attr_reader :avg_scores_by_round
    attr_reader :avg_scores_by_criterion
  end

  # SummaryByCriteria
  class SummaryReport
    def initialize(assignment, summary_ws_url)
      sum = SummaryHelper::Summary.new.summarize_reviews_by_criterion(assignment, summary_ws_url)
      @summary = sum.summary
      @avg_scores_by_round = sum.avg_scores_by_round
      @avg_scores_by_criterion = sum.avg_scores_by_criterion
    end

    attr_reader :summary
    attr_reader :avg_scores_by_round
    attr_reader :avg_scores_by_criterion
  end

  # ReviewResponseMap
  class ReviewReport
    def initialize(id, assignment, type, review_user)
      @reviewers = ReviewResponseMap.review_response_report(id, assignment, type, review_user)
      @review_scores = assignment.compute_reviews_hash
      @avg_and_ranges = assignment.compute_avg_and_ranges_hash
    end

    attr_reader :reviewers
    attr_reader :review_scores
    attr_reader :avg_and_ranges
  end

  # FeedbackResponseMap
  class FeedbackReport
    def initialize(id, assignment, type)
      if assignment.varying_rubrics_by_round?
        @authors, @all_review_response_ids_round_one, @all_review_response_ids_round_two, @all_review_response_ids_round_three = FeedbackResponseMap.feedback_response_report(id, type)
      else
        @authors, @all_review_response_ids = FeedbackResponseMap.feedback_response_report(id, type)
      end
    end

    attr_reader :authors
    attr_reader :all_review_response_ids_round_one
    attr_reader :all_review_response_ids_round_two
    attr_reader :all_review_response_ids_round_three
    attr_reader :all_review_response_ids
  end

  # TeammateReviewResponseMap
  class TeammateReviewReport
    def initialize(id)
      @reviewers = TeammateReviewResponseMap.teammate_response_report(id)
    end

    attr_reader :reviewers
  end

  # Calibration
  class CalibrationReport
    def initialize(id)
      review_questionnaire_ids = ReviewQuestionnaire.select('id')
      @assignment_questionnaire = AssignmentQuestionnaire.where(assignment_id: id, questionnaire_id: review_questionnaire_ids).first
      @questions = @assignment_questionnaire.questionnaire.questions.select {|q| q.type == 'Criterion' or q.type == 'Scale' }
      @calibration_response_maps = ReviewResponseMap.where(reviewed_object_id: id, calibrate_to: 1)
      review_response_map_ids = ReviewResponseMap.select('id').where(reviewed_object_id: id, calibrate_to: 0)
      @responses = Response.where(map_id: review_response_map_ids)
    end

    attr_reader :assignment_questionnaire
    attr_reader :questions
    attr_reader :calibration_response_maps
    attr_reader :responses
  end

  # PlagiarismCheckerReport
  class PlagiarismCheckerReport
    def initialize(id)
      @plagiarism_checker_comparisons = PlagiarismCheckerComparison.where(plagiarism_checker_assignment_submission_id: PlagiarismCheckerAssignmentSubmission.where(assignment_id: id).pluck(:id))
    end

    attr_reader :plagiarism_checker_comparisons
  end

  # AnswerTaggingReport
  class AnswerTaggingReport
    def initialize(id)
      tag_prompt_deployments = TagPromptDeployment.where(assignment_id: id)
      @questionnaire_tagging_report = {}
      tag_prompt_deployments.each do |tag_dep|
        @questionnaire_tagging_report[tag_dep] = tag_dep.assignment_tagging_progress
      end
    end

    attr_reader :questionnaire_tagging_report
  end

  # SelfReview
  class SelfReviewReport
    def initialize(id)
      @self_review_response_maps = SelfReviewResponseMap.where(reviewed_object_id: id)
    end

    attr_reader :self_review_response_maps
  end

  # ResponseReportFactory
  class ResponseReportFactory
    def create_response_report (id, assignment, type, review_user)
      summary_ws_url = WEBSERVICE_CONFIG["summary_webservice_url"]
      case type
      when "SummaryByRevieweeAndCriteria"
        SummaryRevieweeReport.new(assignment, summary_ws_url)
      when "SummaryByCriteria"
        SummaryReport.new(assignment, summary_ws_url)
      when "ReviewResponseMap"
        ReviewReport.new(id, assignment, type, review_user)
      when "FeedbackResponseMap"
        FeedbackReport.new(id, assignment, type)
      when "TeammateReviewResponseMap"
        TeammateReviewReport.new(id)
      when "Calibration"
        CalibrationReport.new(id)
      when "PlagiarismCheckerReport"
        PlagiarismCheckerReport.new(id)
      when "AnswerTaggingReport"
        AnswerTaggingReport.new(id)
      when "SelfReview"
        SelfReviewReport.new(id)
      end
    end
  end
end
