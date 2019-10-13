class QuestionnairesController < ApplicationController
  # Controller for Questionnaire objects
  # A Questionnaire can be of several types (QuestionnaireType)
  # Each Questionnaire contains zero or more questions (Question)
  # Generally a questionnaire is associated with an assignment (Assignment)

  before_action :authorize

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

  def view
    @questionnaire = Questionnaire.find(params[:id])
  end

  def new
    begin
      @questionnaire = Object.const_get(params[:model].split.join).new if Questionnaire::QUESTIONNAIRE_TYPES.include? params[:model]
    rescue StandardError
      flash[:error] = $ERROR_INFO
    end
  end

  def create
    if params[:questionnaire][:name].blank?
      flash[:error] = 'A rubric or survey must have a title.'
      redirect_to controller: 'questionnaires', action: 'new', model: params[:questionnaire][:type], private: params[:questionnaire][:private]
    else
      questionnaire_private = params[:questionnaire][:private] == 'true'
      display_type = params[:questionnaire][:type].split('Questionnaire')[0]
      begin
        @questionnaire = Object.const_get(params[:questionnaire][:type]).new if Questionnaire::QUESTIONNAIRE_TYPES.include? params[:questionnaire][:type]
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
        if %w[AuthorFeedback CourseSurvey TeammateReview GlobalSurvey AssignmentSurvey].include?(display_type)
          display_type = (display_type.split /(?=[A-Z])/).join("%")
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

  def create_questionnaire
    @questionnaire = Object.const_get(params[:questionnaire][:type]).new(questionnaire_params)
    # Create Quiz content has been moved to Quiz Questionnaire Controller
    if @questionnaire.type != "QuizQuestionnaire" # checking if it is a quiz questionnaire
      @questionnaire.instructor_id = Ta.get_my_instructor(session[:user].id) if session[:user].role.name == "Teaching Assistant"
      save

      redirect_to controller: 'tree_display', action: 'list'
    end
  end

  # Edit a questionnaire
  def edit
    @questionnaire = Questionnaire.find(params[:id])
    redirect_to Questionnaire if @questionnaire.nil?
    session[:return_to] = request.original_url
  end

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
          params[:question].each_pair do |k, v|
            @question = Question.find(k)
            # example of 'v' value
            # {"seq"=>"1.0", "txt"=>"WOW", "weight"=>"1", "size"=>"50,3", "max_label"=>"Strong agree", "min_label"=>"Not agree"}
            v.each_pair do |key, value|
              @question.send(key + '=', value) if @question.send(key) != value
            end
            @question.save
          end
        end
        flash[:success] = 'The questionnaire has been successfully updated!'
      rescue StandardError
        flash[:error] = $ERROR_INFO
      end
      redirect_to action: 'edit', id: @questionnaire.id.to_s.to_sym
    end
  end

  # Remove a given questionnaire
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
          raise "There are responses based on this rubric, we suggest you do not delete it." unless question.answers.empty?
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
    @access = @questionnaire.private == true ? "private" : "public"
    undo_link("The questionnaire \"#{@questionnaire.name}\" has been successfully made #{@access}. ")
    redirect_to controller: 'tree_display', action: 'list'
  end

  # Zhewei: This method is used to add new questions when editing questionnaire.
  def add_new_questions
    questionnaire_id = params[:id] unless params[:id].nil?
    num_of_existed_questions = Questionnaire.find(questionnaire_id).questions.size
    ((num_of_existed_questions + 1)..(num_of_existed_questions + params[:question][:total_num].to_i)).each do |i|
      question = Object.const_get(params[:question][:type]).create(txt: '', questionnaire_id: questionnaire_id, seq: i, type: params[:question][:type], break_before: true)
      if question.is_a? ScoredQuestion
        question.weight = 1
        question.max_label = 'Strongly agree'
        question.min_label = 'Strongly disagree'
      end
      question.size = '50, 3' if question.is_a? Criterion
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
    questionnaire_id = params[:id]
    begin
      if params[:save]
        params[:question].each_pair do |k, v|
          @question = Question.find(k)
          # example of 'v' value
          # {"seq"=>"1.0", "txt"=>"WOW", "weight"=>"1", "size"=>"50,3", "max_label"=>"Strong agree", "min_label"=>"Not agree"}
          v.each_pair do |key, value|
            @question.send(key + '=', value) if @question.send(key) != value
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
    elsif !questionnaire_id.nil?
      redirect_to edit_questionnaire_path(questionnaire_id.to_sym)
    end
  end

  private

  # save questionnaire object after create or edit
  def save
    @questionnaire.save!

    save_questions @questionnaire.id if !@questionnaire.id.nil? and @questionnaire.id > 0
    # We do not create node for quiz questionnaires
    if @questionnaire.type != "QuizQuestionnaire"
      p_folder = TreeFolder.find_by(name: @questionnaire.display_type)
      parent = FolderNode.find_by(node_object_id: p_folder.id)
      # create_new_node_if_necessary(parent)
    end
    undo_link("Questionnaire \"#{@questionnaire.name}\" has been updated successfully. ")
  end

  # save questions that have been added to a questionnaire
  def save_new_questions(questionnaire_id)
    if params[:new_question]
      # The new_question array contains all the new questions
      # that should be saved to the database
      params[:new_question].keys.each do |question_key|
        q = Question.new
        q.txt = params[:new_question][question_key]
        q.questionnaire_id = questionnaire_id
        q.type = params[:question_type][question_key][:type]
        q.seq = question_key.to_i
        if @questionnaire.type == "QuizQuestionnaire"
          q.weight = 1 # setting the weight to 1 for quiz questionnaire since the model validates this field
        end
        q.save unless q.txt.strip.empty?
      end
    end
  end

  # delete questions from a questionnaire
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
      # keep track of the deleted questions
      @deleted_questions.push(question)
      question.destroy
    end
  end

  # Handles questions whose wording changed as a result of the edit
  # @param [Object] questionnaire_id
  def save_questions(questionnaire_id)
    delete_questions questionnaire_id
    save_new_questions questionnaire_id

    if params[:question]
      params[:question].keys.each do |question_key|
        if params[:question][question_key][:txt].strip.empty?
          # question text is empty, delete the question
          Question.delete(question_key)
        else
          # Update existing question.
          question = Question.find(question_key)
          Rails.logger.info(question.errors.messages.inspect) unless question.update_attributes(params[:question][question_key])
        end
      end
    end
  end

  def questionnaire_params
    params.require(:questionnaire).permit(:name, :instructor_id, :private, :min_question_score,
                                          :max_question_score, :type, :display_type, :instruction_loc)
  end

  def question_params
    params.require(:question).permit(:txt, :weight, :questionnaire_id, :seq, :type, :size,
                                     :alternatives, :break_before, :max_label, :min_label)
  end

  # FIXME: These private methods belong in the Questionnaire model
end
