class QuestionnairesController < ApplicationController
  # Controller for Questionnaire objects
  # A Questionnaire can be of several types (QuestionnaireType)
  # Each Questionnaire contains zero or more questions (Question)
  # Generally a questionnaire is associated with an assignment (Assignment)

  before_action :authorize
  
  def action_allowed?
    if action_name == "edit"
      @questionnaire = Questionnaire.find(params[:id])
      (['Super-Administrator',
       'Administrator'
       ].include? current_role_name)  ||
          ((['Instructor'].include? current_role_name) && current_user_id?(@questionnaire.try(:instructor_id)))

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
    orig_questionnaire = Questionnaire.find(params[:id])
    questions = Question.where(questionnaire_id: params[:id])
    @questionnaire = orig_questionnaire.dup
    @questionnaire.instructor_id = session[:user].instructor_id ## Why was TA-specific code removed here?  See Project E713.
    @questionnaire.copy_questionnaire_details(questions, orig_questionnaire, @questionnaire.id)
  end

  def view
    @questionnaire = Questionnaire.find(params[:id])
  end

  def new
    @questionnaire = Object.const_get(params[:model].split.join).new if Questionnaire::QUESTIONNAIRE_TYPES.include? params[:model]
  end

  def create
    questionnaire_private = params[:questionnaire][:private] == "true"
    display_type = params[:questionnaire][:type].split('Questionnaire')[0]
    @questionnaire = Object.const_get(params[:questionnaire][:type]).new if Questionnaire::QUESTIONNAIRE_TYPES.include? params[:questionnaire][:type]
    begin
      @questionnaire.private = questionnaire_private
      @questionnaire.name = params[:questionnaire][:name]
      @questionnaire.instructor_id = session[:user].id
      @questionnaire.min_question_score = params[:questionnaire][:min_question_score]
      @questionnaire.max_question_score = params[:questionnaire][:max_question_score]
      @questionnaire.type = params[:questionnaire][:type]
      # Zhewei: Right now, the display_type in 'questionnaires' table and name in 'tree_folders' table are not consistent.
      # In the future, we need to write migration files to make them consistency.

      # Moved to questionnaire.rb
      # created a new method called set_dispay_type
      @questionnaire.display_type = @questionnaire.set_dispay_type(display_type)
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
  
    # save an updated quiz questionnaire to the database
  def update_quiz
    @questionnaire = Questionnaire.find(params[:id])
    if @questionnaire.nil?
      redirect_to controller: 'submitted_content', action: 'view', id: params[:pid]
      return
    end
    if params['save'] && params[:question].try(:keys)
      @questionnaire.update_attributes(questionnaire_params)

      for qid in params[:question].keys
        @question = Question.find(qid)
        @question.txt = params[:question][qid.to_sym][:txt]
        @question.save

        @quiz_question_choices = QuizQuestionChoice.where(question_id: qid)
        i = 1
        for quiz_question_choice in @quiz_question_choices
	  type = @question.type
	  id = @question.id
       	  QuizQuestionnaire.change_question_types(quiz_question_choice, type, id, i)
          i += 1
        end
      end
    end
    redirect_to controller: 'submitted_content', action: 'view', id: params[:pid]
  end

  # Edit a questionnaire
  def edit
    @questionnaire = Questionnaire.find(params[:id])
    redirect_to Questionnaire if @questionnaire.nil?
    session[:return_to] = request.original_url
  end

  def update
    @questionnaire = Questionnaire.find(params[:id])
    begin
      @questionnaire.update_attributes(questionnaire_params)
      flash[:success] = 'The questionnaire has been successfully updated!'
    rescue StandardError
      flash[:error] = $ERROR_INFO
    end
    redirect_to edit_questionnaire_path(@questionnaire.id.to_s.to_sym)
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
    undo_link("the questionnaire \"#{@questionnaire.name}\" has been successfully made #{@access}. ")
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
          flash[:success] = 'All questions has been successfully saved!'
        end
      end
    rescue StandardError
      flash[:error] = $ERROR_INFO
    end

    Questionnaire.export if params[:export]
    Questionnaire.import if params[:import]

    if params[:view_advice]
      redirect_to controller: 'advice', action: 'edit_advice', id: params[:id]
    elsif !questionnaire_id.nil?
      redirect_to edit_questionnaire_path(questionnaire_id.to_sym)
    end
  end

  #=========================================================================================================
  # Separate methods for quiz questionnaire
  #=========================================================================================================
    # View a quiz questionnaire
  def view
    @questionnaire = Questionnaire.find(params[:id])
    @participant = Participant.find(params[:pid]) # creating an instance variable since it needs to be sent to submitted_content/edit
    render :view
  end
  # define a new quiz questionnaire
  # method invoked by the view
  def new_quiz
    valid_request = true
    @assignment_id = params[:aid] # creating an instance variable to hold the assignment id
    @participant_id = params[:pid] # creating an instance variable to hold the participant id
    assignment = Assignment.find(@assignment_id)
    if !assignment.require_quiz? # flash error if this assignment does not require quiz
      flash[:error] = "This assignment does not support the quizzing feature."
      valid_request = false
    else
      team = AssignmentParticipant.find(@participant_id).team

      if team.nil? # flash error if this current participant does not have a team
        flash[:error] = "You should create or join a team first."
        valid_request = false
      else
        if assignment.topics? && team.topic.nil? # flash error if this assignment has topic but current team does not have a topic
          flash[:error] = "Your team should have a topic."
          valid_request = false
        end
      end
    end

    if valid_request && Questionnaire::QUESTIONNAIRE_TYPES.include?(params[:model])
      @questionnaire = Object.const_get(params[:model]).new
      @questionnaire.private = params[:private]
      @questionnaire.min_question_score = 0
      @questionnaire.max_question_score = 1

      render :new_quiz
    else
      redirect_to controller: 'submitted_content', action: 'view', id: params[:pid]
    end
  end

  # seperate method for creating a quiz questionnaire because of differences in permission
  def create_quiz_questionnaire
    valid = QuizQuestionnaire.valid
    if valid.eql?("valid")
      @questionnaire = Object.const_get(params[:questionnaire][:type]).new(questionnaire_params)

    	# TODO: check for Quiz Questionnaire?
    	if @questionnaire.type == "QuizQuestionnaire" # checking if it is a quiz questionnaire
      		participant_id = params[:pid] # creating a local variable to send as parameter to submitted content if it is a quiz questionnaire
      		@questionnaire.min_question_score = 0
      		@questionnaire.max_question_score = 1
      		author_team = AssignmentTeam.team(Participant.find(participant_id))

      		@questionnaire.instructor_id = author_team.id # for a team assignment, set the instructor id to the team_id

      		@successful_create = true
      		save

      		save_choices @questionnaire.id

      		flash[:note] = "The quiz was successfully created." if @successful_create == true
      		redirect_to controller: 'submitted_content', action: 'edit', id: participant_id
    	else # if it is not a quiz questionnaire
      		@questionnaire.instructor_id = Ta.get_my_instructor(session[:user].id) if session[:user].role.name == "Teaching Assistant"
      		save

      		redirect_to controller: 'tree_display', action: 'list'
    end
    else
      flash[:error] = valid.to_s
      redirect_to :back
    end
  end

  # edit a quiz questionnaire
  def edit_quiz
    @questionnaire = Questionnaire.find(params[:id])
    if !@questionnaire.taken_by_anyone?
      render :edit
    else
      flash[:error] = "Your quiz has been taken by some other students, you cannot edit it anymore."
      redirect_to controller: 'submitted_content', action: 'view', id: params[:pid]
    end
  end

  private

  # save questionnaire object after create or edit
  def save
    @questionnaire.save!

    save_questions @questionnaire.id if !@questionnaire.id.nil? and @questionnaire.id > 0
    # We do not create node for quiz questionnaires
    if @questionnaire.type != "QuizQuestionnaire"
      pFolder = TreeFolder.find_by(name: @questionnaire.display_type)
      parent = FolderNode.find_by(node_object_id: pFolder.id)
      # create_new_node_if_necessary(parent)
    end
    undo_link("Questionnaire \"#{@questionnaire.name}\" has been updated successfully. ")
  end

  # save questions that have been added to a questionnaire
  def save_new_questions(questionnaire_id)
    if params[:new_question]
      # The new_question array contains all the new questions
      # that should be saved to the database
      for question_key in params[:new_question].keys
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
        params[:question].keys.each do |question_key|
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
      for question_key in params[:question].keys

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

  # method to save the choices associated with a question in a quiz to the database
  # only for quiz questionnaire
  def save_choices(questionnaire_id)
    if params[:new_question] and params[:new_choices]
      questions = Question.where(questionnaire_id: questionnaire_id)
      questionnum = 1

      for question in questions
        q_type = params[:question_type][questionnum.to_s][:type]
        for choice_key in params[:new_choices][questionnum.to_s][q_type].keys
          score = if params[:new_choices][questionnum.to_s][q_type][choice_key]["weight"] == 1.to_s
                    1
                  else
                    0
                  end
          if q_type == "MultipleChoiceCheckbox"
            q = if params[:new_choices][questionnum.to_s][q_type][choice_key][:iscorrect] == 1.to_s
                  QuizQuestionChoice.new(txt: params[:new_choices][questionnum.to_s][q_type][choice_key][:txt], iscorrect: "true", question_id: question.id)
                else
                  QuizQuestionChoice.new(txt: params[:new_choices][questionnum.to_s][q_type][choice_key][:txt], iscorrect: "false", question_id: question.id)
                end
            q.save
          elsif q_type == "TrueFalse"
            if params[:new_choices][questionnum.to_s][q_type][1.to_s][:iscorrect] == choice_key
              q = QuizQuestionChoice.new(txt: "True", iscorrect: "true", question_id: question.id)
              q.save
              q = QuizQuestionChoice.new(txt: "False", iscorrect: "false", question_id: question.id)
              q.save
            else
              q = QuizQuestionChoice.new(txt: "True", iscorrect: "false", question_id: question.id)
              q.save
              q = QuizQuestionChoice.new(txt: "False", iscorrect: "true", question_id: question.id)
              q.save
            end
          else
            q = if params[:new_choices][questionnum.to_s][q_type][1.to_s][:iscorrect] == choice_key
                  QuizQuestionChoice.new(txt: params[:new_choices][questionnum.to_s][q_type][choice_key][:txt], iscorrect: "true", question_id: question.id)
                else
                  QuizQuestionChoice.new(txt: params[:new_choices][questionnum.to_s][q_type][choice_key][:txt], iscorrect: "false", question_id: question.id)
                end
            q.save
          end
        end
        questionnum += 1
        question.weight = 1
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
