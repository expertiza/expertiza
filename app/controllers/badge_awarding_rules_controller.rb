class BadgeAwardingRulesController < ApplicationController
  before_action :set_badge_awarding_rule, only: [:show, :edit, :update, :destroy]

  # GET /badge_awarding_rules
  def index

    @course  = Course.find(params[:course_id])
    @badge = Badge.find(params[:badge_id])
    @assignments = Assignment.where(course_id: @course.id)

    @assignment_questions = Hash.new

    @assignments.each do |assignment|
      questionaire_question_array = []
      assignment.questionnaires.each do |questionaire|
        questionaire.questions.each do |question|
          if question.is_a? Criterion or question.is_a? Scale
            questionaire_question =  questionaire.name + '| ' + question.txt
            questionaire_question_array << { question_id: question.id, question: questionaire_question }
          end
        end
        questionaire_question_array << { question_id: 'AVG' + questionaire.id.to_s, question: 'Average score in questionnaire ' + questionaire.name }
      end
      @assignment_questions[assignment.id] = questionaire_question_array;
    end

    @popup = false
    if params.key?(:popup) and params[:popup].to_s.casecmp('true').zero?
      @popup = true
      render layout: false
    end
  end

  # GET /badge_awarding_rules/1
  def show

  end

  # GET /badge_awarding_rules/new
  def new
    @badge_awarding_rule = BadgeAwardingRule.new
  end

  # GET /badge_awarding_rules/1/edit
  def edit
  end

  # POST /badge_awarding_rules
  def create
    @badge_awarding_rule = BadgeAwardingRule.new(badge_awarding_rule_params)

    if @badge_awarding_rule.save
      redirect_to @badge_awarding_rule, notice: 'Badge awarding rule was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /badge_awarding_rules/1
  def update
    if @badge_awarding_rule.update(badge_awarding_rule_params)
      redirect_to @badge_awarding_rule, notice: 'Badge awarding rule was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /badge_awarding_rules/1
  def destroy
    @badge_awarding_rule.destroy
    redirect_to badge_awarding_rules_url, notice: 'Badge awarding rule was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_badge_awarding_rule
      @badge_awarding_rule = BadgeAwardingRule.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def badge_awarding_rule_params
      params.require(:badge_awarding_rule).permit(:course_badge_id, :question_id, :operator, :threshold, :logical_operator)
    end
end
