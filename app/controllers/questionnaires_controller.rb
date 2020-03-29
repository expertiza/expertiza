class QuestionnairesController < ApplicationController
  # Controller for Questionnaire objects
  # A Questionnaire can be of several types (QuestionnaireType)
  # Each Questionnaire contains zero or more questions (Question)
  # Generally a questionnaire is associated with an assignment (Assignment)

  before_action :authorize

  ## Constants
  LABEL_AGREE = 'Strongly agree' # label for scored question if agree
  LABEL_DISAGREE = 'Strongly disagree' # label for scored question if disagree
  WEIGHT = 1  # question weight
  SIZE_CRITERION = '50, 3' # size of the question box if it's a criterion
  SIZE_ALT_DROPDOWN = '0|1|2|3|4|5' # alternative to size if question is a dropdown
  SIZE_TXT_AREA = '60, 5' # size of question box if text area
  SIZE_TXT_FIELD = '30' # size of question box if text field

  # Check role access for edit questionnaire
  def action_allowed?
    if params[:action] == "edit"
      @questionnaire = Questionnaire.find(params[:id])
      (['Super-Administrator',
        'Administrator'].include? current_role_name) ||
          ((['Instructor'].include? current_role_name) && current_user_id?(@questionnaire.try(:instructor_id))) ||
          ((['Teaching Assistant'].include? current_role_name) && session[:user].instructor_id == @questionnaire.try(:instructor_id))

    else
      ['Super-Administrator',
       'Administrator',
       'Instructor',
       'Teaching Assistant', 'Student'].include? current_role_name
    end
  end

  # Create a clone of the given questionnaire, copying all associated
  # questions. The name and creator are updated.
  def copy
    begin
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
  end

  # View a given questionnaire provided an ID
  def view
    @questionnaire = Questionnaire.find(params[:id])
  end

  # Renders form suitable for creating a new questionnaire
  def new
    begin
      @questionnaire = Object.const_get(params[:model].split.join).new if Questionnaire::QUESTIONNAIRE_TYPES.include? params[:model]
    rescue StandardError
      flash[:error] = $ERROR_INFO
    end
  end

  # Save a new questionnaire to the database
  def create
    # Check if title is provided
    if params[:questionnaire][:name].blank?
      flash[:error] = 'A rubric or survey must have a title.'
      redirect_to controller: 'questionnaires', action: 'new', model: params[:questionnaire][:type], private: params[:questionnaire][:private]
    else
      questionnaire_private = params[:questionnaire][:private] == 'true'
      display_type = params[:questionnaire][:type].split('Questionnaire')[0]
      begin
        # Attempt to save the questionnaire
        @questionnaire = Object.const_get(params[:questionnaire][:type]).new if Questionnaire::QUESTIONNAIRE_TYPES.include? params[:questionnaire][:type]
      rescue StandardError
        flash[:error] = $ERROR_INFO
      end
      begin
        create_questionnaire_node questionnaire_private, display_type
        flash[:success] = 'You have successfully created a questionnaire!'
      rescue StandardError
        flash[:error] = $ERROR_INFO
      end
      redirect_to controller: 'questionnaires', action: 'edit', id: @questionnaire.id
    end
  end

  # Renders form suitable for editing an existing questionnaire
  def edit
    @questionnaire = Questionnaire.find(params[:id])
    redirect_to Questionnaire if @questionnaire.nil?
    session[:return_to] = request.original_url
  end

  # Save an edited questionnaire to the database
  def update
    # If 'Add' or 'Edit/View advice' is clicked, redirect appropriately
    if params[:add_new_questions]
      redirect_to action: 'add_new_questions', id: params[:id], question: params[:new_question]
    elsif params[:view_advice]
      redirect_to controller: 'advice', action: 'edit_advice', id: params[:id]
    else
      @questionnaire = Questionnaire.find(params[:id])
      begin
        # Save questionnaire information
        @questionnaire.update_attributes(questionnaire_params)

        # Save all questions
        unless params[:question].nil?
          save_question_hash(params)
        end
        flash[:success] = 'The questionnaire has been successfully updated!'
      rescue StandardError
        flash[:error] = $ERROR_INFO
      end
      redirect_to action: 'edit', id: @questionnaire.id.to_s.to_sym
    end
  end

  # Remove a given questionnaire from the database provided its ID
  def delete
    @questionnaire = Questionnaire.find(params[:id])
    return unless @questionnaire
    begin
      name = @questionnaire.name
      # If this rubric is used by some assignment, flash error
      unless @questionnaire.assignments.empty?
        raise "The assignment <b>#{@questionnaire.assignments.first.try(:name)}</b> uses this questionnaire. Are sure you want to delete the assignment?"
      end
      questions = @questionnaire.questions
      # If this rubric had some answers, flash error
      questions.each do |question|
        raise "There are responses based on this rubric, we suggest you do not delete it." unless question.answers.empty?
      end
      # Delete questions before removing node
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
    redirect_to action: 'list', controller: 'tree_display'
  end

  # Toggle the access permission for this assignment from public to private, or vice versa
  def toggle_access
    @questionnaire = Questionnaire.find(params[:id])
    @questionnaire.private = !@questionnaire.private
    @questionnaire.save
    @access = @questionnaire.private == true ? "private" : "public"
    undo_link("The questionnaire \"#{@questionnaire.name}\" has been successfully made #{@access}. ")
    redirect_to controller: 'tree_display', action: 'list'
  end

  # This method is used to add new questions when editing questionnaire.
  def add_new_questions
    questionnaire_id = params[:id] unless params[:id].nil?
    num_of_existed_questions = Questionnaire.find(questionnaire_id).questions.size
    # For each new question in questionnaire, set attributes and save object
    ((num_of_existed_questions + 1)..(num_of_existed_questions + params[:question][:total_num].to_i)).each do |i|
      question_type = params[:question][:type] unless params[:question][:type].nil?
      question = Object.const_get(question_type).create(txt: '', questionnaire_id: questionnaire_id,
                                                        seq: i, type: question_type, break_before: true)
      if question.is_a? ScoredQuestion
        question.weight = WEIGHT
        question.max_label = LABEL_AGREE
        question.min_label = LABEL_DISAGREE
      end
      question.size = SIZE_CRITERION if question.is_a? Criterion
      question.alternatives = SIZE_ALT_DROPDOWN if question.is_a? Dropdown
      question.size = SIZE_TXT_AREA if question.is_a? TextArea
      question.size = SIZE_TXT_FIELD if question.is_a? TextField
      begin
        question.save
      rescue StandardError
        flash[:error] = $ERROR_INFO
      end
    end
    redirect_to edit_questionnaire_path(questionnaire_id.to_sym)
  end

  # This method is used to save all questions in current questionnaire.
  def save_all_questions
    questionnaire_id = params[:id]
    begin
      if params[:save]
        save_question_hash(params)
      end
    rescue StandardError
      flash[:error] = $ERROR_INFO
    end

    # If Edit or View advice is clicked, redirect appropriately
    if params[:view_advice]
      redirect_to controller: 'advice', action: 'edit_advice', id: params[:id]
    elsif !questionnaire_id.nil?
      redirect_to edit_questionnaire_path(questionnaire_id.to_sym)
    end
  end

  private

  # Save questionnaire object after create or edit
  def save
    @questionnaire.save!
    # Check that questionnaire ID is valid before saving
    save_questions @questionnaire.id if !@questionnaire.id.nil? and @questionnaire.id > 0
    undo_link("Questionnaire \"#{@questionnaire.name}\" has been updated successfully. ")
  end

  # Save questions that have been added to a questionnaire
  def save_new_questions(questionnaire_id)
    return unless params[:new_question]
    # The new_question array contains all the new questions
    # that should be saved to the database
    params[:new_question].each_key do |question_key|
      q = Question.new
      q.txt = params[:new_question][question_key]
      q.questionnaire_id = questionnaire_id
      q.type = params[:question_type][question_key][:type]
      q.seq = question_key.to_i
      q.weight = WEIGHT # Setting the weight to 1 for quiz questionnaire since the model validates this field
      q.save unless q.txt.strip.empty?
    end
  end

  # Delete questions from a questionnaire
  # @param [Object] questionnaire_id
  def delete_questions(questionnaire_id)
    # Deletes any questions that, as a result of the edit, are no longer in the questionnaire
    questions = Question.where("questionnaire_id = ?", questionnaire_id)
    @deleted_questions = []
    questions.each do |question|
      should_delete = true
      unless question_params.nil?
        params[:question].each_key do |question_key|
          should_delete = false if question_key.to_s == question.id.to_s
        end
      end

      next unless should_delete
      question.question_advices.each(&:destroy)
      # Keep track of the deleted questions
      @deleted_questions.push(question)
      question.destroy
    end
  end

  # Handles questions whose wording changed as a result of the edit
  # @param [Object] questionnaire_id
  def save_questions(questionnaire_id)
    delete_questions questionnaire_id
    save_new_questions questionnaire_id
    return unless params[:question]
    params[:question].each_key do |question_key|
      if params[:question][question_key][:txt].strip.empty?
        # Question text is empty, delete the question
        Question.delete(question_key)
      else
        # Update existing question.
        question = Question.find(question_key)
        Rails.logger.info(question.errors.messages.inspect) unless question.update_attributes(params[:question][question_key])
      end
    end
  end

  def save_question_hash(params)
    params[:question].each_pair do |k, v|
      @question = Question.find(k)
      v.each_pair do |key, value|
        @question.send(key + '=', value) if @question.send(key) != value
      end
      @question.save
      flash[:success] = 'All questions have been successfully saved!'
    end
  end

  # Handles assigning questionnaire attributes and creating node
  def create_questionnaire_node questionnaire_private, display_type
    @questionnaire.private = questionnaire_private
    @questionnaire.name = params[:questionnaire][:name]
    @questionnaire.instructor_id = session[:user].id
    @questionnaire.min_question_score = params[:questionnaire][:min_question_score]
    @questionnaire.max_question_score = params[:questionnaire][:max_question_score]
    @questionnaire.type = params[:questionnaire][:type]
    # Right now, the display_type in 'questionnaires' table and name in 'tree_folders' table are not consistent.
    # In the future, consider migrating files to maintain consistency.
    # If statement is used to check display type cases. If there are only 5 cases, remove the if statement
    if %w[AuthorFeedback CourseSurvey TeammateReview GlobalSurvey AssignmentSurvey].include?(display_type)
      display_type = (display_type.split /(?=[A-Z])/).join("%")
    end
    @questionnaire.display_type = display_type
    @questionnaire.instruction_loc = Questionnaire::DEFAULT_QUESTIONNAIRE_URL
    @questionnaire.save
    tree_folder = TreeFolder.where(['name like ?', @questionnaire.display_type]).first
    parent = FolderNode.find_by(node_object_id: tree_folder.id)
    # Create node
    QuestionnaireNode.create(parent_id: parent.id, node_object_id: @questionnaire.id, type: 'QuestionnaireNode')
  end

  # Ensures that required parameters are present for questionnaire
  def questionnaire_params
    params.require(:questionnaire).permit(:name, :instructor_id, :private, :min_question_score,
                                          :max_question_score, :type, :display_type, :instruction_loc)
  end

  # Ensures that required parameters are present for questions
  def question_params
    params.require(:question).permit(:txt, :weight, :questionnaire_id, :seq, :type, :size,
                                     :alternatives, :break_before, :max_label, :min_label)
  end

end
