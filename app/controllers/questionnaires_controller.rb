class QuestionnairesController < ApplicationController
  include AuthorizationHelper

  # Controller for Questionnaire objects
  # A Questionnaire can be of several types (QuestionnaireType)
  # Each Questionnaire contains zero or more questions (Question)
  # Generally a questionnaire is associated with an assignment (Assignment)

  before_action :authorize

  # Check role access for edit questionnaire
  def action_allowed?
    case params[:action]
    when 'edit'
      @questionnaire = Questionnaire.find(params[:id])
      current_user_has_admin_privileges? ||
        (current_user_is_a?('Instructor') && current_user_id?(@questionnaire.try(:instructor_id))) ||
        (current_user_is_a?('Teaching Assistant') && session[:user].instructor_id == @questionnaire.try(:instructor_id))
    else
      current_user_has_student_privileges?
    end
  end

  # Create a clone of the given questionnaire, copying all associated
  # questions. The name and creator are updated.
  def copy
    puts "copy called."
    instructor_id = session[:user].instructor_id
    @questionnaire = Questionnaire.copy_questionnaire_details(params, instructor_id)
    p_folder = TreeFolder.find_by(name: @questionnaire.display_type)
    parent = FolderNode.find_by(node_object_id: p_folder.id)
    QuestionnaireNode.find_or_create_by(parent_id: parent.id, node_object_id: @questionnaire.id)
    undo_link("Copy of questionnaire #{@questionnaire.name} has been created successfully.")
    redirect_to controller: 'questionnaires', action: 'view', id: @questionnaire.id
  rescue StandardError
    flash[:error] = 'The questionnaire was not able to be copied. Please check the original course for missing information.' + $ERROR_INFO.to_s
    redirect_to action: 'list', controller: 'tree_display'
  end

  def view
    puts "view called."
    @questionnaire = Questionnaire.find(params[:id])
  end

  # factory method to create the appropriate questionnaire based on the type
  def questionnaire_factory(type, params = nil)
    if type == 'ReviewQuestionnaire'
      if params != nil
        return ReviewQuestionnaire.new(params)
      else
        return ReviewQuestionnaire.new
      end
    elsif type == 'MetareviewQuestionnaire'
      if params != nil
        return MetareviewQuestionnaire.new(params)
      else
        return MetareviewQuestionnaire.new
      end
    elsif type == 'AuthorFeedbackQuestionnaire'
      if params != nil
        return AuthorFeedbackQuestionnaire.new(params)
      else
        return AuthorFeedbackQuestionnaire.new
      end
    elsif type == 'TeammateReviewQuestionnaire'
      if params != nil
        return TeammateReviewQuestionnaire.new(params)
      else
        return TeammateReviewQuestionnaire.new
      end
    elsif type == 'AssignmentSurveyQuestionnaire'
      if params != nil
        return AssignmentSurveyQuestionnaire.new(params)
      else
        return AssignmentSurveyQuestionnaire.new
      end
    elsif type == 'SurveyQuestionnaire'
      if params != nil
        return SurveyQuestionnaire.new(params)
      else
        return SurveyQuestionnaire.new
      end
    elsif type == 'GlobalSurveyQuestionnaire'
      if params != nil
        return GlobalSurveyQuestionnaire.new(params)
      else
        return GlobalSurveyQuestionnaire.new
      end
    elsif type == 'CourseSurveyQuestionnaire'
      if params != nil
        return CourseSurveyQuestionnaire.new(params)
      else
        return CourseSurveyQuestionnaire.new
      end
    elsif type == 'BookmarkRatingQuestionnaire'
      if params != nil
        return BookmarkRatingQuestionnaire.new(params)
      else
        return BookmarkRatingQuestionnaire.new
      end
    elsif type == 'QuizQuestionnaire'
      if params != nil
        return QuizQuestionnaire.new(params)
      else
        return QuizQuestionnaire.new
      end
    end
  end

  def new
    puts "new called."
    type = params[:model].split.join
    @questionnaire = questionnaire_factory(type) if Questionnaire::QUESTIONNAIRE_TYPES.include? params[:model].split.join
  rescue StandardError
    flash[:error] = $ERROR_INFO
  end

  def create
    puts "create called."
    if params[:questionnaire][:name].blank?
      flash[:error] = 'A rubric or survey must have a title.'
      redirect_to controller: 'questionnaires', action: 'new', model: params[:questionnaire][:type], private: params[:questionnaire][:private]
    else
      questionnaire_private = params[:questionnaire][:private] == 'true'
      display_type = params[:questionnaire][:type].split('Questionnaire')[0]
      begin
        type = params[:questionnaire][:type]
        @questionnaire = questionnaire_factory(type) if Questionnaire::QUESTIONNAIRE_TYPES.include? params[:questionnaire][:type]
      rescue StandardError
        flash[:error] = $ERROR_INFO
      end
      begin
        @questionnaire.private = questionnaire_private
        @questionnaire.name = params[:questionnaire][:name]
        @questionnaire.instructor_id = session[:user].id
        @questionnaire.min_question_score = params[:questionnaire][:min_question_score]
        @questionnaire.max_question_score = params[:questionnaire][:max_question_score]
        @questionnaire.type = params[:questionnaire][:type]
        # Zhewei: Right now, the display_type in 'questionnaires' table and name in 'tree_folders' table are not consistent.
        # In the future, we need to write migration files to make them consistency.
        # E1903 : We are not sure of other type of cases, so have added a if statement. If there are only 5 cases, remove the if statement
        if %w[AuthorFeedback CourseSurvey TeammateReview GlobalSurvey AssignmentSurvey BookmarkRating].include?(display_type)
          display_type = (display_type.split(/(?=[A-Z])/)).join('%')
        end
        @questionnaire.display_type = display_type
        @questionnaire.instruction_loc = Questionnaire::DEFAULT_QUESTIONNAIRE_URL
        @questionnaire.save
        # Create node
        tree_folder = TreeFolder.where(['name like ?', @questionnaire.display_type]).first
        parent = FolderNode.find_by(node_object_id: tree_folder.id)
        QuestionnaireNode.create(parent_id: parent.id, node_object_id: @questionnaire.id, type: 'QuestionnaireNode')
        flash[:success] = 'You have successfully created a questionnaire!'
      rescue StandardError
        flash[:error] = $ERROR_INFO
      end
      redirect_to controller: 'questionnaires', action: 'edit', id: @questionnaire.id
    end
  end

  # Edit a questionnaire
  def edit
    puts "edit called."
    @questionnaire = Questionnaire.find(params[:id])
    redirect_to Questionnaire if @questionnaire.nil?
    session[:return_to] = request.original_url
  end

  def update
    puts "update called."
    @questionnaire = Questionnaire.find(params[:id])
    puts @questionnaire
    begin
      # Save questionnaire information
      @questionnaire.update_attributes(questionnaire_params)

      flash[:success] = 'The questionnaire has been successfully updated!'
    rescue StandardError
      flash[:error] = $ERROR_INFO
    end
    redirect_to action: 'edit', id: @questionnaire.id.to_s.to_sym
  end

  # Remove a given questionnaire
  def delete
    puts "delete called."
    @questionnaire = Questionnaire.find(params[:id])
    if @questionnaire
      begin
        name = @questionnaire.name
        # if this rubric is used by some assignment, flash error
        unless @questionnaire.assignments.empty?
          raise "The assignment <b>#{@questionnaire.assignments.first.try(:name)}</b> uses this questionnaire. Are sure you want to delete the assignment?"
        end

        questions = @questionnaire.questions
        # if this rubric had some answers, flash error
        questions.each do |question|
          raise 'There are responses based on this rubric, we suggest you do not delete it.' unless question.answers.empty?
        end
        questions.each do |question|
          advices = question.question_advices
          advices.each(&:delete)
          question.delete
        end
        questionnaire_node = @questionnaire.questionnaire_node
        questionnaire_node.delete
        @questionnaire.delete
        undo_link("The questionnaire \"#{name}\" has been successfully deleted.")
      rescue StandardError => e
        flash[:error] = e.message
      end
    end
    redirect_to action: 'list', controller: 'tree_display'
  end

  # Zhewei: This method is used to add new questions when editing questionnaire.
  def add_new_questions
    puts "add_new_questions called."
    questionnaire_id = params[:id] unless params[:id].nil?
    # If the questionnaire is being used in the active period of an assignment, delete existing responses before adding new questions
    if AnswerHelper.check_and_delete_responses(questionnaire_id)
      flash[:success] = 'You have successfully added a new question. Any existing reviews for the questionnaire have been deleted!'
    else
      flash[:success] = 'You have successfully added a new question.'
    end

    num_of_existed_questions = Questionnaire.find(questionnaire_id).questions.size
    max_seq = 0
    Questionnaire.find(questionnaire_id).questions.each do |question|
      if question.seq > max_seq
        max_seq = question.seq
      end
    end
    ((num_of_existed_questions + 1)..(num_of_existed_questions + params[:question][:total_num].to_i)).each do
      max_seq += 1
      question = Object.const_get(params[:question][:type]).create(txt: '', questionnaire_id: questionnaire_id, seq: max_seq, type: params[:question][:type], break_before: true)
      if question.is_a? ScoredQuestion
        question.weight = params[:question][:weight]
        question.max_label = 'Strongly agree'
        question.min_label = 'Strongly disagree'
      end

      question.size = '50, 3' if question.is_a? Criterion
      question.size = '50, 3' if question.is_a? Cake
      question.alternatives = '0|1|2|3|4|5' if question.is_a? Dropdown
      question.size = '60, 5' if question.is_a? TextArea
      question.size = '30' if question.is_a? TextField

      begin
        question.save
      rescue StandardError
        flash[:error] = $ERROR_INFO
      end
    end
    redirect_to edit_questionnaire_path(questionnaire_id.to_sym)
  end

  # Zhewei: This method is used to save all questions in current questionnaire.
  def save_all_questions
    puts "save_all_questions called."
    questionnaire_id = params[:id]
    begin
      if params[:save]
        params[:question].each_pair do |k, v|
          @question = Question.find(k)
          # example of 'v' value
          # {"seq"=>"1.0", "txt"=>"WOW", "weight"=>"1", "size"=>"50,3", "max_label"=>"Strong agree", "min_label"=>"Not agree"}
          v.each_pair do |key, value|
            @question.send(key + '=', value) unless @question.send(key) == value
          end

          @question.save
          flash[:success] = 'All questions have been successfully saved!'
        end
      end
    rescue StandardError
      flash[:error] = $ERROR_INFO
    end

    if params[:view_advice]
      redirect_to controller: 'advice', action: 'edit_advice', id: params[:id]
    elsif questionnaire_id
      redirect_to edit_questionnaire_path(questionnaire_id.to_sym)
    end
  end

  private

  def questionnaire_params
    params.require(:questionnaire).permit(:name, :instructor_id, :private, :min_question_score,
                                          :max_question_score, :type, :display_type, :instruction_loc)
  end

  def question_params
    params.require(:question).permit(:txt, :weight, :questionnaire_id, :seq, :type, :size,
                                     :alternatives, :break_before, :max_label, :min_label)
  end
end
