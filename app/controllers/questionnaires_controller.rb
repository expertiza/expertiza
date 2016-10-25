class QuestionnairesController < ApplicationController
  # Controller for Questionnaire objects
  # A Questionnaire can be of several types (QuestionnaireType)
  # Each Questionnaire contains zero or more questions (Question)
  # Generally a questionnaire is associated with an assignment (Assignment)

  before_action :authorize

  def action_allowed?
    ['Super-Administrator',
     'Administrator',
     'Instructor',
     'Teaching Assistant', 'Student'].include? current_role_name
  end

  # Create a clone of the given questionnaire, copying all associated
  # questions. The name and creator are updated.
  def copy
    orig_questionnaire = Questionnaire.find(params[:id])
    questions = Question.where(questionnaire_id: params[:id])
    @questionnaire = orig_questionnaire.dup
    @questionnaire.instructor_id = session[:user].instructor_id ## Why was TA-specific code removed here?  See Project E713.
    copy_questionnaire_details(questions, orig_questionnaire)
  end

  def view
    @questionnaire = Questionnaire.find(params[:id])
  end

  def show
    @questionnaire = Questionnaire.find(params[:id])
  end

  # Define a new questionnaire
  def new
    if Questionnaire::QUESTIONNAIRE_TYPES.include? params[:model]
      @questionnaire = Object.const_get(params[:model].split.join).new
    end
  end

  def create
    questionnaire_private = params[:questionnaire][:private] == "true" ? true : false
    display_type = params[:questionnaire][:type].split('Questionnaire')[0]
    if Questionnaire::QUESTIONNAIRE_TYPES.include? params[:questionnaire][:type]
      @questionnaire = Object.const_get(params[:questionnaire][:type]).new
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
      case display_type
      when 'AuthorFeedback'
        display_type = 'Author%Feedback'
      when 'CourseEvaluation'
        display_type = 'Course%Evaluation'
      when 'TeammateReview'
        display_type = 'Teammate%Review'
      when 'GlobalSurvey'
        display_type = 'Global%Survey'
      end
      @questionnaire.display_type = display_type
      @questionnaire.instruction_loc = Questionnaire::DEFAULT_QUESTIONNAIRE_URL
      @questionnaire.save
      # Create node
      tree_folder = TreeFolder.where(['name like ?', @questionnaire.display_type]).first
      parent = FolderNode.find_by_node_object_id(tree_folder.id)
      QuestionnaireNode.create(parent_id: parent.id, node_object_id: @questionnaire.id, type: 'QuestionnaireNode')
      flash[:success] = 'You have successfully created a questionnaire!'
    rescue
      flash[:error] = $ERROR_INFO
    end
    redirect_to controller: 'questionnaires', action: 'edit', id: @questionnaire.id
  end

  def create_questionnaire
    @questionnaire = Object.const_get(params[:questionnaire][:type]).new(questionnaire_params)

    # TODO: check for Quiz Questionnaire?
    if @questionnaire.type == "QuizQuestionnaire" # checking if it is a quiz questionnaire
      participant_id = params[:pid] # creating a local variable to send as parameter to submitted content if it is a quiz questionnaire
      @questionnaire.min_question_score = 0
      @questionnaire.max_question_score = 1
      @assignment = Assignment.find(params[:aid])
      author_team = AssignmentTeam.team(Participant.find(participant_id))

      @questionnaire.instructor_id = author_team.id # for a team assignment, set the instructor id to the team_id

      @successful_create = true
      save

      save_choices @questionnaire.id

      if @successful_create == true
        flash[:note] = "The quiz was successfully created."
      end
      redirect_to controller: 'submitted_content', action: 'edit', id: participant_id
    else # if it is not a quiz questionnaire
      if session[:user].role.name == "Teaching Assistant"
        @questionnaire.instructor_id = Ta.get_my_instructor(session[:user].id)
      end
      save

      redirect_to controller: 'tree_display', action: 'list'
    end
  end

  # Edit a questionnaire
  def edit
    @questionnaire = Questionnaire.find(params[:id])
    redirect_to Questionnaire if @questionnaire.nil?
  end

  def update
    @questionnaire = Questionnaire.find(params[:id])
    begin
      @questionnaire.update_attributes(questionnaire_params)
      flash[:success] = 'The questionnaire has been successfully updated!'
    rescue
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
        @questionnaire.assignments.each do |assignment|
          raise "The assignment #{assignment.name} uses this questionnaire. Are sure you want to <A href='../assignment/delete/#{assignment.id}'>delete</A> the assignment?"
        end

        questions = @questionnaire.questions

        # if this rubric had some answers, flash error
        questions.each do |question|
          unless question.answers.empty?
            raise "There are responses based on this rubric, we suggest you do not delete it."
          end
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
      rescue
        flash[:error] = $ERROR_INFO
      end
    end

    redirect_to action: 'list', controller: 'tree_display'
  end

  def edit_advice # #Code used to be in this class, was removed.  I have not checked the other class.
    redirect_to controller: 'advice', action: 'edit_advice'
  end

  def save_advice
    begin
      for advice_key in params[:advice].keys
        QuestionAdvice.update(advice_key, params[:advice][advice_key])
      end
      flash[:notice] = "The questionnaire's question advice was successfully saved."
      # redirect_to :action => 'list'
      redirect_to controller: 'advice', action: 'save_advice'
    rescue
      flash[:error] = $ERROR_INFO
    end
  end

  # Toggle the access permission for this assignment from public to private, or vice versa
  def toggle_access
    @questionnaire = Questionnaire.find(params[:id])
    @questionnaire.private = !@questionnaire.private
    @questionnaire.save
    @access = @questionnaire.private == true ? "private" : "public"
    undo_link("teh questionnaire \"#{@questionnaire.name}\" has been successfully made #{@access}. ")
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
      rescue
        flash[:error] = $ERROR_INFO
      end
    end
    redirect_to edit_questionnaire_path(questionnaire_id.to_sym)
  end

  # Zhewei: This method is used to save all questions in current questionnaire.
  def save_all_questions
    questionnaire_id = params[:id] unless params[:id].nil?
    if params['save']
      params[:question].each_pair do |k, v|
        @question = Question.find(k)
        # example of 'v' value
        # {"seq"=>"1.0", "txt"=>"WOW", "weight"=>"1", "size"=>"50,3", "max_label"=>"Strong agree", "min_label"=>"Not agree"}
        v.each_pair do |key, value|
          @question.send(key + '=', value) if @question.send(key) != value
        end
        begin
          @question.save
          flash[:success] = 'All questions has been successfully saved!'
        rescue
          flash[:error] = $ERROR_INFO
        end
      end
    end

    export if params['export']
    import if params['import']

    if params['view_advice']
      redirect_to controller: 'advice', action: 'edit_advice', id: params[:id]
    else
      redirect_to edit_questionnaire_path(questionnaire_id.to_sym)
    end
  end

  #=========================================================================================================
  # Separate methods for quiz questionnaire
  #=========================================================================================================
  # View a quiz questionnaire
  def view_quiz
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
        if assignment.has_topics? && team.topic.nil? # flash error if this assignment has topic but current team does not have a topic
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
    valid = valid_quiz
    if valid.eql?("valid")
      create_questionnaire
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
      flash[:error] = "Your quiz has been taken by some other students, editing cannot be done any more."
      redirect_to controller: 'submitted_content', action: 'view', id: params[:pid]
    end
  end

  # save an updated quiz questionnaire to the database
  def update_quiz
    @questionnaire = Questionnaire.find(params[:id])
    redirect_to controller: 'submitted_content', action: 'view', id: params[:pid] if @questionnaire.nil?
    if params['save']
      @questionnaire.update_attributes(questionnaire_params)

      for qid in params[:question].keys
        @question = Question.find(qid)
        @question.txt = params[:question][qid.to_sym][:txt]
        @question.save

        @quiz_question_choices = QuizQuestionChoice.where(question_id: qid)
        i = 1
        for quiz_question_choice in @quiz_question_choices
          if @question.type == "MultipleChoiceCheckbox"
            if params[:quiz_question_choices][@question.id.to_s][@question.type][i.to_s]
              quiz_question_choice.update_attributes(iscorrect: params[:quiz_question_choices][@question.id.to_s][@question.type][i.to_s][:iscorrect], txt: params[:quiz_question_choices][@question.id.to_s][@question.type][i.to_s][:txt])
            else
              quiz_question_choice.update_attributes(iscorrect: '0', txt: params[:quiz_question_choices][quiz_question_choice.id.to_s][:txt])
            end
          end
          if @question.type == "MultipleChoiceRadio"
            if params[:quiz_question_choices][@question.id.to_s][@question.type][:correctindex] == i.to_s
              quiz_question_choice.update_attributes(iscorrect: '1', txt: params[:quiz_question_choices][@question.id.to_s][@question.type][i.to_s][:txt])
            else
              quiz_question_choice.update_attributes(iscorrect: '0', txt: params[:quiz_question_choices][@question.id.to_s][@question.type][i.to_s][:txt])
            end
          end
          if @question.type == "TrueFalse"
            if params[:quiz_question_choices][@question.id.to_s][@question.type][1.to_s][:iscorrect] == "True" # the statement is correct
              if quiz_question_choice.txt == "True"
                quiz_question_choice.update_attributes(iscorrect: '1') # the statement is correct so "True" is the right answer
              else
                quiz_question_choice.update_attributes(iscorrect: '0')
              end
            else # the statement is not correct
              if quiz_question_choice.txt == "True"
                quiz_question_choice.update_attributes(iscorrect: '0')
              else
                quiz_question_choice.update_attributes(iscorrect: '1') # the statement is not correct so "False" is the right answer
              end
            end
          end

          i += 1
        end
      end
    end
    redirect_to controller: 'submitted_content', action: 'view', id: params[:pid]
  end

  def valid_quiz
    num_quiz_questions = Assignment.find(params[:aid]).num_quiz_questions
    valid = "valid"

    (1..num_quiz_questions).each do |i|
      if params[:new_question][i.to_s] == ''
        # One of the questions text is not filled out
        valid = "Please make sure all questions have text"
        break
      elsif !params.key?(:question_type) || !params[:question_type].key?(i.to_s) || params[:question_type][i.to_s][:type].nil?
        # A type isnt selected for a question
        valid = "Please select a type for each question"
        break
      elsif params[:questionnaire][:name] == ""
        # questionnaire name is not specified
        valid = "Please specify quiz name (please do not use your name or id)."
        break
      else
        type = params[:question_type][i.to_s][:type]
        if type == 'MultipleChoiceCheckbox' or type == 'MultipleChoiceRadio'
          correct_selected = false
          (1..4).each do |x|
            if params[:new_choices][i.to_s][type][x.to_s][:txt] == ''
              # Text isnt provided for an option
              valid = "Please make sure every question has text for all options"
              break
            elsif type == 'MultipleChoiceRadio' and !params[:new_choices][i.to_s][type][x.to_s][:iscorrect].nil?
              correct_selected = true
            elsif type == 'MultipleChoiceCheckbox' and params[:new_choices][i.to_s][type][x.to_s][:iscorrect] != 0.to_s
              correct_selected = true
            end
          end
          if valid == "valid" && !correct_selected
            # A correct option isnt selected for a check box or radio question
            valid = "Please select a correct answer for all questions"
            break
          end
        elsif type == 'TF' # TF is not disabled. We need to test TF later.
          if params[:new_choices][i.to_s]["TF"].nil?
            # A correct option isnt selected for a true/false question
            valid = "Please select a correct answer for all questions"
            break
          end
        end
      end
    end

    valid
  end

  private

  # save questionnaire object after create or edit
  def save
    @questionnaire.save!

    save_questions @questionnaire.id if !@questionnaire.id.nil? and @questionnaire.id > 0
    # We do not create node for quiz questionnaires
    if @questionnaire.type != "QuizQuestionnaire"
      pFolder = TreeFolder.find_by_name(@questionnaire.display_type)
      parent = FolderNode.find_by_node_object_id(pFolder.id)
      create_new_node_if_necessary(parent)
    end
    undo_link("Questionnaire \"#{@questionnaire.name}\" has been updated successfully. ")
  end

  # save parameters for new questions
  def save_new_question_parameters(qid, q_num)
    q = QuestionType.new
    q.q_type = params[:question_type][q_num][:type]
    q.parameters = params[:question_type][q_num][:parameters]
    q.question_id = qid
    q.save
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
    questions = Question.where("questionnaire_id = " + questionnaire_id.to_s)
    @deleted_questions = []
    for question in questions
      should_delete = true
      unless question_params.nil?
        for question_key in params[:question].keys
          should_delete = false if question_key.to_s === question.id.to_s
        end
      end

      next unless should_delete
      for advice in question.question_advices
        advice.destroy
      end
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
          unless question.update_attributes(params[:question][question_key])
            Rails.logger.info(question.errors.messages.inspect)
          end
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
            if params[:new_choices][questionnum.to_s][q_type][choice_key][:iscorrect] == 1.to_s
              q = QuizQuestionChoice.new(txt: params[:new_choices][questionnum.to_s][q_type][choice_key][:txt], iscorrect: "true", question_id: question.id)
            else
              q = QuizQuestionChoice.new(txt: params[:new_choices][questionnum.to_s][q_type][choice_key][:txt], iscorrect: "false", question_id: question.id)
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
            if params[:new_choices][questionnum.to_s][q_type][1.to_s][:iscorrect] == choice_key
              q = QuizQuestionChoice.new(txt: params[:new_choices][questionnum.to_s][q_type][choice_key][:txt], iscorrect: "true", question_id: question.id)
            else
              q = QuizQuestionChoice.new(txt: params[:new_choices][questionnum.to_s][q_type][choice_key][:txt], iscorrect: "false", question_id: question.id)
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
    params.require(:questionnaire).permit(:name, :instructor_id, :private, :min_question_score, :max_question_score, :type, :display_type, :instruction_loc)
  end

  def question_params
    params.require(:question).permit(:txt, :weight, :questionnaire_id, :seq, :type, :size, :alternatives, :break_before, :max_label, :min_label)
  end

  # FIXME: These private methods belong in the Questionnaire model

  def export
    @questionnaire = Questionnaire.find(params[:id])

    csv_data = QuestionnaireHelper.create_questionnaire_csv @questionnaire, session[:user].name

    send_data csv_data,
              type: 'text/csv; charset=iso-8859-1; header=present',
              disposition: "attachment; filename=questionnaires.csv"
  end

  def import
    @questionnaire = Questionnaire.find(params[:id])

    file = params['csv']

    @questionnaire.questions << QuestionnaireHelper.get_questions_from_csv(@questionnaire, file)
  end

  # clones the contents of a questionnaire, including the questions and associated advice
  def copy_questionnaire_details(questions, orig_questionnaire)
    assign_instructor_id
    @questionnaire.name = 'Copy of ' + orig_questionnaire.name
    begin
      @questionnaire.created_at = Time.now
      @questionnaire.save!
      questions.each do |question|
        new_question = question.dup
        new_question.questionnaire_id = @questionnaire.id
        if (new_question.is_a? Criterion or new_question.is_a? TextResponse) and new_question.size.nil?
          new_question.size = '50,3'
        end
        new_question.save!
        advices = QuestionAdvice.where(question_id: question.id)
        next unless !advices.empty?
        advices.each do |advice|
          new_advice = advice.dup
          new_advice.question_id = new_question.id
          new_advice.save!
          end
      end

      pFolder = TreeFolder.find_by_name(@questionnaire.display_type)
      parent = FolderNode.find_by_node_object_id(pFolder.id)
      create_new_node_if_necessary(parent)
      undo_link("Copy of questionnaire #{orig_questionnaire.name} has been created successfully. ")
      redirect_to controller: 'questionnaires', action: 'view', id: @questionnaire.id
    rescue
      flash[:error] = 'The questionnaire was not able to be copied. Please check the original course for missing information.' + $ERROR_INFO
      redirect_to action: 'list', controller: 'tree_display'
    end
  end

  def create_new_node_if_necessary(parent)
    unless QuestionnaireNode.exists?(parent_id: parent.id, node_object_id: @questionnaire.id)
      QuestionnaireNode.create(parent_id: parent.id, node_object_id: @questionnaire.id)
    end
  end

  def assign_instructor_id # if the user to copy the questionnaire is a TA, the instructor should be the owner instead of the TA
    @questionnaire.instructor_id = if session[:user].role.name != "Teaching Assistant"
                                     session[:user].id
                                   else # for TA we need to get his instructor id and by default add it to his course for which he is the TA
                                     Ta.get_my_instructor(session[:user].id)
                                   end
  end
end
