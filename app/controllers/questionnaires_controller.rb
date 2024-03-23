class QuestionnairesController < ApplicationController
  include AuthorizationHelper
  before_action [:create_questionnaire, :save], only: [:list]
  include QuestionnaireHelper
  include QuestionHelper


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
      (current_user_is_a?('Teaching Assistant') && Ta.find(session[:user].id).is_instructor_or_co_ta?(@questionnaire)) ||
      (current_user_is_a?('Instructor') && current_user_id?(@questionnaire.try(:instructor_id))) ||
      (current_user_is_a?('Instructor') && Ta.get_my_instructors(@questionnaire.try(:instructor_id)).include?(session[:user].id))
    else
      current_user_has_student_privileges?
    end
  end

  # Create a clone of the given questionnaire, copying all associated
  # questions. The name and creator are updated.
  def copy
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
    @questionnaire = Questionnaire.find(params[:id])
  end

  def new
    type = params[:model].split.join
    # Create questionnaire object based on type using questionnaire_factory
    @questionnaire = questionnaire_factory(type) if Questionnaire::QUESTIONNAIRE_TYPES.include? params[:model].split.join
  rescue StandardError
    flash[:error] = $ERROR_INFO
  end

  # Assigns corresponding variables to questionnaire object.
  def set_questionnaire_parameters(private_flag, display)
    @questionnaire.private = private_flag
    @questionnaire.name = params[:questionnaire][:name]
    @questionnaire.instructor_id = session[:user].id
    @questionnaire.min_question_score = params[:questionnaire][:min_question_score]
    @questionnaire.max_question_score = params[:questionnaire][:max_question_score]
    @questionnaire.type = params[:questionnaire][:type]
    @questionnaire.display_type = display
    @questionnaire.instruction_loc = Questionnaire::DEFAULT_QUESTIONNAIRE_URL
    @questionnaire.save
  end

  # Creates tree node
  def create_tree_node
    tree_folder = TreeFolder.where(['name like ?', @questionnaire.display_type]).first
    parent = FolderNode.find_by(node_object_id: tree_folder.id)
    QuestionnaireNode.create(parent_id: parent.id, node_object_id: @questionnaire.id, type: 'QuestionnaireNode')
    flash[:success] = 'You have successfully created a questionnaire!'
  end

  def create
    if params[:questionnaire][:name].blank?
      flash[:error] = 'A rubric or survey must have a title.'
      redirect_to controller: 'questionnaires', action: 'new', model: params[:questionnaire][:type], private: params[:questionnaire][:private]
    else
      questionnaire_private = params[:questionnaire][:private] == 'true'
      display_type = params[:questionnaire][:type].split('Questionnaire')[0]
      begin
        type = params[:questionnaire][:type]
        # Create questionnaire object based on type using questionnaire_factory
        @questionnaire = questionnaire_factory(type) if Questionnaire::QUESTIONNAIRE_TYPES.include? params[:questionnaire][:type]
      rescue StandardError
        flash[:error] = $ERROR_INFO
      end
      begin
        # Zhewei: Right now, the display_type in 'questionnaires' table and name in 'tree_folders' table are not consistent.
        # In the future, we need to write migration files to make them have consistency.
        # E1903 : We are not sure of other type of cases, so have added a if statement. If there are only 5 cases, remove the if statement
        if %w[AuthorFeedback CourseSurvey TeammateReview GlobalSurvey AssignmentSurvey BookmarkRating].include?(display_type)
          display_type = display_type.split(/(?=[A-Z])/).join('%')
        end
        # set the parameters for questionnaires object
        set_questionnaire_parameters(questionnaire_private, display_type)
        # Create node - adds this questionnaire to the tree_display list
        create_tree_node
      rescue StandardError => e
        flash[:error] = e.message
      end
      redirect_to controller: 'questionnaires', action: 'edit', id: @questionnaire.id
    end
  end

  # Edit a questionnaire
  def edit
    @questionnaire = Questionnaire.find(params[:id])
    redirect_to Questionnaire if @questionnaire.nil?
    session[:return_to] = request.original_url
  end

  # Updates a questionnaire's attributes and questions based on form data and redirects to the edit page,
  # displaying a flash message if the update is successful or not.
  def update
    # If 'Add' or 'Edit/View advice' is clicked, redirect appropriately
    if params[:add_new_questions]
      permitted_params = params.permit(:id, new_question: params[:new_question].keys)
      redirect_to action: 'add_new_questions', id: permitted_params[:id], question: permitted_params[:new_question]
    elsif params[:view_advice]
      redirect_to controller: 'advice', action: 'edit_advice', id: params[:id]
    else
      @questionnaire = Questionnaire.find(params[:id])
      if @questionnaire.update_attributes(questionnaire_params)
        update_questionnaire_questions
        flash[:success] = 'The questionnaire has been successfully updated!'
      else
        flash[:error] = @questionnaire.errors.full_messages.join(', ')
      end
      redirect_to action: 'edit', id: @questionnaire.id.to_s.to_sym
    end
  rescue StandardError => e
    flash[:error] = e.message
    redirect_to action: 'edit', id: @questionnaire.id.to_s.to_sym
  end

  # Remove a given questionnaire
  # checks if any assignment uses the current questionnaire or not
  # checks if there are any answers to the questions in the questionnaire
  # for each of the question, it deletes the advice first 
  # and then deletes the question. Only then the questionnaire node
  # is deleted
  def delete
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

  # Toggle the access permission for this assignment from public to private, or vice versa
  def toggle_access
    @questionnaire = Questionnaire.find(params[:id])
    @questionnaire.private = !@questionnaire.private
    @questionnaire.save
    @access = @questionnaire.private == true ? 'private' : 'public'
    undo_link("The questionnaire \"#{@questionnaire.name}\" has been successfully made #{@access}. ")
    redirect_to controller: 'tree_display', action: 'list'
  end

  # Zhewei: This method is used to add new questions when editing questionnaire.
  def add_new_questions
    questionnaire_id = params[:id]
    # If the questionnaire is being used in the active period of an assignment, delete existing responses before adding new questions
    if AnswerHelper.check_and_delete_responses(questionnaire_id)
      flash[:success] = 'You have successfully added a new question. Any existing reviews for the questionnaire have been deleted!'
    else
      flash[:success] = 'You have successfully added a new question.'
    end

    questionnaire = Questionnaire.find(questionnaire_id)
    current_num_of_questions = questionnaire.questions.size
    max_seq = 0
    Questionnaire.find(questionnaire_id).questions.each do |question|
      if !question.seq.nil? && question.seq > max_seq
        max_seq = question.seq
      end
    end
    ((current_num_of_questions + 1)..(current_num_of_questions + params[:question][:total_num].to_i)).each do
      max_seq += 1
      # Create question object based on type using question_factory
      question = question_factory(params[:question][:type], questionnaire_id, max_seq)
      if question.is_a? ScoredQuestion
        question.weight = params[:question][:weight]
        question.max_label = Question::MAX_LABEL
        question.min_label = Question::MIN_LABEL
      end

      if Question::SIZES.key?(question.class.name)
        question.size = Question::SIZES[question.class.name]
      end
      if Question::ALTERNATIVES.key?(question.class.name)
        question.alternatives = Question::ALTERNATIVES[question.class.name]
      end

      begin
        question.save
      rescue StandardError => e
        flash[:error] = e.message
      end
    end
    redirect_to edit_questionnaire_path(questionnaire_id.to_sym)
  end

  # Zhewei: This method is used to save all questions in current questionnaire.
  # this calls update_questions on all the questions in present questionnaire
  def save_all_questions
    questionnaire_id = params[:id]
    begin
      if params[:save]
        update_questionnaire_questions
        flash[:success] = 'All questions have been successfully saved!'
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

  # save questionnaire object after create or edit
  # this is a basid CRUD function and is called after every create or edit
  def save
    @questionnaire.save!
    redirect_to controller: 'questions', action: 'save_questions', questionnaire_id: @questionnaire.id, questionnaire_type: @questionnaire.type and return unless @questionnaire.id.nil? || @questionnaire.id <= 0
    undo_link("Questionnaire \"#{@questionnaire.name}\" has been updated successfully. ")
  end

  def questionnaire_params
    params.require(:questionnaire).permit(:name, :instructor_id, :private, :min_question_score,
                                          :max_question_score, :type, :display_type, :instruction_loc)
  end

  def question_params
    params.require(:question).permit(:txt, :weight, :questionnaire_id, :seq, :type, :size,
                                     :alternatives, :break_before, :max_label, :min_label)
  end
end
