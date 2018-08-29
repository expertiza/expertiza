class BadgeAwardingRulesController < ApplicationController

  def action_allowed?
      current_role_name.eql?("Instructor")
  end

   # GET /badge_awarding_rules?course_id=X&badge_id=Y
  def index
    @error = ''
    @error += " Please define course_id or assignment_id in query string." if !params[:course_id] && !params[:assignment_id]
    @error += " Please define badge_id in query string." if !params[:badge_id]
    puts params
    if !@error.empty?
      flash[:error] = @error
      return
    end

    begin
      if params[:assignment_id]
        @assignment = Assignment.where(id: params[:assignment_id])
        if @assignment.count < 1
          @error = " Can't find assignment with an id of " + params[:assignment_id]
          flash[:error] = @error
          return
        end
      elsif params[:course_id]
        @course  = Course.find(params[:course_id])
      end
      @badge = Badge.find(params[:badge_id])
    rescue StandardError => e
      @error += e.message
      flash[:error] = @error
      return
    end

    if  @badge && (@course || @assignment)
      @assignments = @course ? Assignment.where(course_id: @course.id) : @assignment
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
          # mark as negative if it's a questionaire average
          questionaire_question_array << { question_id: 0-questionaire.id, question: 'Average score in questionnaire ' + questionaire.name }
        end
        @assignment_questions[assignment.id] = questionaire_question_array;
      end
    end

    # take the first assignment so the UI can render it's name
    @assignment = @assignment.first if @assignment

    @popup = false
    if params.key?(:popup) and params[:popup].to_s.casecmp('true').zero?
      @popup = true
      render layout: false
    end
  end

  # GET /badge_awarding_rules/show?badge_id=X&assignment_id=Y
  def show
    #need to change the reference in BadgeAwardingRule from badge_course to assignment
    rules = BadgeAwardingRule.where(badge_id: params['badge_id'],  assignment_id: params['assignment_id'])
    render :json => rules
  end

  # GET /badge_awarding_rules/new
  def new
    @badge_awarding_rule = BadgeAwardingRule.new
  end

  # POST /badge_awarding_rules/1
  def edit
    # test
  end

  # POST /badge_awarding_rules
  def create
    @badge_awarding_rule = BadgeAwardingRule.new(badge_awarding_rule_params)

    if @badge_awarding_rule.save
      render  :json => @badge_awarding_rule, :status => 200
    else
      render :json => {message: "Database service unavailable"}, :status => 503
    end
  end

  # PATCH/PUT /badge_awarding_rules/1
  def update
    set_badge_awarding_rule
    if @badge_awarding_rule.update(badge_awarding_rule_params)
      render  :json => @badge_awarding_rule, :status => 200
    else
      render :json => {message: "Database service unavailable"}, :status => 503
    end
  end

  # DELETE /badge_awarding_rules/1
  def destroy
    set_badge_awarding_rule
    @badge_awarding_rule.destroy
    render  :json => @badge_awarding_rule, :status => 200
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_badge_awarding_rule
      @badge_awarding_rule = BadgeAwardingRule.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def badge_awarding_rule_params
      params.permit(:id, :assignment_id, :badge_id, :question_id, :operator, :threshold, :logic_operator)
    end
end
