class QuizQuestionnairesController < QuestionnairesController

  #Quiz questionnaire edit option to be allowed for student
  def action_allowed?
    if params[:action] == "edit"
      @questionnaire = Questionnaire.find(params[:id])
      (['Super-Administrator', 'Administrator'].include? current_role_name) ||
          (['Student'].include? current_role_name)
    else
      ['Super-Administrator',
       'Administrator',
       'Instructor',
       'Teaching Assistant', 'Student'].include? current_role_name
    end
  end
  # View a quiz questionnaire
  def view
    @questionnaire = Questionnaire.find(params[:id])
    @participant = Participant.find(params[:pid]) # creating an instance variable since it needs to be sent to submitted_content/edit
    render :view
  end

  # define a new quiz questionnaire
  # method invoked by the view
  def new
    valid_request = true
    @assignment_id = params[:aid] # creating an instance variable to hold the assignment id
    @participant_id = params[:pid] # creating an instance variable to hold the participant id
    assignment = Assignment.find(@assignment_id)
    if !assignment.require_quiz? # flash error if this assignment does not require quiz
      flash[:error] = "This assignment does not support the quizzing feature."
      valid_request = false
    else
      valid_request = team_check(@participant_id, assignment) # check for validity of the request
    end
    if valid_request && Questionnaire::QUESTIONNAIRE_TYPES.include?(params[:model])
      @questionnaire = QuizQuestionnaire.new
      @questionnaire.private = params[:private]
      @questionnaire.min_question_score = 0
      @questionnaire.max_question_score = 1
      render 'questionnaires/new_quiz'
    else
      redirect_to controller: 'submitted_content', action: 'view', id: params[:pid]
    end
  end

  # create quiz questionnaire
  def create
    valid = validate_quiz
    if valid.eql?("valid")
      @questionnaire = QuizQuestionnaire.new(questionnaire_params)
      participant_id = params[:pid] # creating a local variable to send as parameter to submitted content if it is a quiz questionnaire
      @questionnaire.min_question_score = 0
      @questionnaire.max_question_score = 1
      author_team = AssignmentTeam.team(Participant.find(participant_id))

      @questionnaire.instructor_id = author_team.id # for a team assignment, set the instructor id to the team_id

      @successful_create = true
      save

      save_choices @questionnaire.id

      flash[:note] = "The quiz was successfully created." if @successful_create
      redirect_to controller: 'submitted_content', action: 'edit', id: participant_id
    else
      flash[:error] = valid.to_s
      redirect_to :back
    end
  end

  # edit a quiz questionnaire
  def edit
    @questionnaire = Questionnaire.find(params[:id])
    if !@questionnaire.taken_by_anyone? # quiz can be edited only if its not taken by anyone
      render :'questionnaires/edit'
    else
      flash[:error] = "Your quiz has been taken by some other students, you cannot edit it anymore."
      redirect_to controller: 'submitted_content', action: 'view', id: params[:pid]
    end
  end

  # save an updated quiz questionnaire to the database
  def update
    @questionnaire = Questionnaire.find(params[:id])
    if @questionnaire.nil?
      redirect_to controller: 'submitted_content', action: 'view', id: params[:pid]
      return
    end
    if params['save'] && params[:question].try(:keys)
      @questionnaire.update_attributes(questionnaire_params)
      params[:question].each_key do |qid|
        @question = Question.find(qid)
        @question.txt = params[:question][qid.to_sym][:txt]
        @question.weight = params[:question_weights][qid.to_sym][:txt]
        @question.save
        @quiz_question_choices = QuizQuestionChoice.where(question_id: qid)
        question_index = 1
        @quiz_question_choices.each do |question_choice|
          # Call private methods to handle question types
          update_checkbox(question_choice, question_index) if @question.type == "MultipleChoiceCheckbox"
          update_radio(question_choice, question_index) if @question.type == "MultipleChoiceRadio"
          update_truefalse(question_choice) if @question.type == "TrueFalse"
          question_index += 1
        end
      end
    end
    redirect_to controller: 'submitted_content', action: 'view', id: params[:pid]
  end

  # validate quiz name, questions, answers
  def validate_quiz
    num_questions = Assignment.find(params[:aid]).num_quiz_questions
    valid = "valid"
    if params[:questionnaire][:name] == "" # questionnaire name is not specified
      valid = "Please specify quiz name (please do not use your name or id)."
    end
    (1..num_questions).each do |i|
      break if valid != "valid"
      valid = validate_question(i)
    end
    valid
  end

  private

  def team_check(participant_id, assignment)
    valid_request = true
    team = AssignmentParticipant.find(participant_id).team
    if team.nil? # flash error if this current participant does not have a team
      flash[:error] = "You should create or join a team first."
      valid_request = false
    elsif assignment.topics? && team.topic.nil? # flash error if this assignment has topic but current team does not have a topic
      flash[:error] = "Your team should have a topic."
      valid_request = false
    end
    valid_request # return whether the request is valid or not
  end

  def validate_question(i)
    if !params.key?(:question_type) || !params[:question_type].key?(i.to_s) || params[:question_type][i.to_s][:type].nil?
      # A type isn't selected for a question
      valid = "Please select a type for each question"
    else
      # The question type is dynamic, so const_get is necessary
      type = params[:question_type][i.to_s][:type]
      @new_question = Object.const_get(type).create(txt: '', type: type, break_before: true)
      @new_question.update_attributes(txt: params[:new_question][i.to_s])
      choice_info = params[:new_choices][i.to_s][type] # choice info for one question of its type
      valid = if choice_info.nil?
                "Please select a correct answer for all questions"
              else
                @new_question.isvalid(choice_info)
              end
    end
    valid
  end

  # create checkbox question
  def update_checkbox(question_choice, question_index)
    if params[:quiz_question_choices][@question.id.to_s][@question.type][question_index.to_s]
      question_choice.update_attributes(iscorrect: params[:quiz_question_choices][@question.id.to_s][@question.type][question_index.to_s][:iscorrect], txt: params[:quiz_question_choices][@question.id.to_s][@question.type][question_index.to_s][:txt])
    else
      question_choice.update_attributes(iscorrect: '0', txt: params[:quiz_question_choices][question_choice.id.to_s][:txt])
    end
  end

  # update radio question
  def update_radio(question_choice, question_index)
    if params[:quiz_question_choices][@question.id.to_s][@question.type][:correctindex] == question_index.to_s
      question_choice.update_attributes(iscorrect: '1', txt: params[:quiz_question_choices][@question.id.to_s][@question.type][question_index.to_s][:txt])
    else
      question_choice.update_attributes(iscorrect: '0', txt: params[:quiz_question_choices][@question.id.to_s][@question.type][question_index.to_s][:txt])
    end
  end

  # update true/false question
  def update_truefalse(question_choice)
    if params[:quiz_question_choices][@question.id.to_s][@question.type][1.to_s][:iscorrect] == "True" # the statement is correct
      question_choice.txt == "True" ? question_choice.update_attributes(iscorrect: '1') : question_choice.update_attributes(iscorrect: '0')
      # the statement is correct so "True" is the right answer
    else # the statement is not correct
      question_choice.txt == "True" ? question_choice.update_attributes(iscorrect: '0') : question_choice.update_attributes(iscorrect: '1')
      # the statement is not correct so "False" is the right answer
    end
  end

  # create checkbox question
  def create_checkbox(question, choice_key, q_choices)
    q = if q_choices[choice_key][:iscorrect] == 1.to_s
          QuizQuestionChoice.new(txt: q_choices[choice_key][:txt], iscorrect: "true", question_id: question.id)
        else
          QuizQuestionChoice.new(txt: q_choices[choice_key][:txt], iscorrect: "false", question_id: question.id)
        end
    q.save
  end
  
  # create radio question
  def create_radio(question, choice_key, q_choices)
    q = if q_choices[1.to_s][:iscorrect] == choice_key
          QuizQuestionChoice.new(txt: q_choices[choice_key][:txt], iscorrect: "true", question_id: question.id)
        else
          QuizQuestionChoice.new(txt: q_choices[choice_key][:txt], iscorrect: "false", question_id: question.id)
        end
    q.save
  end

  # create true/false question
  def create_truefalse(question, choice_key, q_choices)
    if q_choices[1.to_s][:iscorrect] == choice_key
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
  end

  # save questionnaire
  def save
    @questionnaire.save!

    save_questions @questionnaire.id if !@questionnaire.id.nil? and @questionnaire.id > 0
    undo_link("Questionnaire \"#{@questionnaire.name}\" has been updated successfully. ")
  end

  # save questions
  def save_questions(questionnaire_id)
    delete_questions questionnaire_id # delete existing questionnaire if any
    save_new_questions questionnaire_id # save new questions
    if params[:question]
      params[:question].each_key do |question_key|
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

  # save choice type and create template for the same
  def save_choices(questionnaire_id)
    return unless params[:new_question] or params[:new_choices]
    questions = Question.where(questionnaire_id: questionnaire_id)
    question_num = 1

    questions.each do |question|
      q_type = params[:question_type][question_num.to_s][:type]
      q_choices = params[:new_choices][question_num.to_s][q_type]
      q_choices.each_key do |choice_key|
        if q_type == "MultipleChoiceCheckbox"
          create_checkbox(question, choice_key, q_choices)
        elsif q_type == "TrueFalse"
          create_truefalse(question, choice_key, q_choices)
        else # MultipleChoiceRadio
          create_radio(question, choice_key, q_choices)
        end
      end
      question_num += 1
      question.weight = 1
    end
  end

  def questionnaire_params
    params.require(:questionnaire).permit(:name, :instructor_id, :private, :min_question_score,
                                          :max_question_score, :type, :display_type, :instruction_loc)
  end
end
