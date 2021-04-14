class MetricsController < ApplicationController
  helper :file
  helper :submitted_content
  helper :penalty
  include PenaltyHelper
  include StudentTaskHelper
  include AssignmentHelper
  include GradesHelper
  include AuthorizationHelper

  def view
    if session["github_access_token"].nil?
      session["assignment_id"] = params[:id]
      session["github_view_type"] = "view_scores"
      return redirect_to authorize_github_grades_path
    end
    @assignment = Assignment.find(params[:id])
    questionnaires = @assignment.questionnaires

    if @assignment.vary_by_round
      @questions = retrieve_questions questionnaires, @assignment.id
    else
      @questions = {}
      questionnaires.each do |questionnaire|
        @questions[questionnaire.symbol] = questionnaire.questions
      end
    end

    @scores = @assignment.scores(@questions)
    averages = calculate_average_vector(@assignment.scores(@questions))
    @average_chart = bar_chart(averages, 300, 100, 5)
    @avg_of_avg = mean(averages)
    calculate_all_penalties(@assignment.id)
    @show_reputation = false
  end

  def show
  end
end
