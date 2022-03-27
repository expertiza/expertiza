class QuizQuestionnairesController < QuestionnairesController
  include AuthorizationHelper

  # Quiz questionnaire edit option to be allowed for student
  def action_allowed?
    if params[:action] == 'edit'
      @questionnaire = Questionnaire.find(params[:id])
      current_user_has_admin_privileges? || current_user_is_a?('Student')
    else
      current_user_has_student_privileges?
    end
  end

  # View a quiz questionnaire
  def view
    @questionnaire = Questionnaire.find(params[:id])
    @participant = Participant.find(params[:pid]) # creating an instance variable since it needs to be sent to submitted_content/edit
    render :view
  end

  def new
    valid_request = true # A request is valid if the assignment requires a quiz, the participant has a team, and that team has a topic if the assignment has a topic
    @assignment_id = params[:aid] # creating an instance variable to hold the assignment id
    @participant_id = params[:pid] # creating an instance variable to hold the participant id
    assignment = Assignment.find(@assignment_id)
    if assignment.require_quiz?
      valid_request = team_valid?(@participant_id, assignment) # check for validity of the request
    else # flash error if this assignment does not require quiz
      flash[:error] = 'This assignment is not configured to use quizzes.'
      valid_request = false
    end
    if valid_request && Questionnaire::QUESTIONNAIRE_TYPES.include?(params[:model])
      @questionnaire = QuizQuestionnaire.new
      @questionnaire.private = params[:private]
      render 'questionnaires/new_quiz'
    else
      redirect_to controller: 'submitted_content', action: 'view', id: params[:pid]
    end
  end

  # create quiz questionnaire
  def create
    valid = validate_quiz
    if valid.eql?('valid') # The value of valid could either be "valid" or a string indicating why the quiz cannot be created
      @questionnaire = QuizQuestionnaire.new(questionnaire_params)
      participant_id = params[:pid] # Gets the participant id to be used when finding team and editing submitted content
      @questionnaire.min_question_score = params[:questionnaire][:min_question_score] # 0
      @questionnaire.max_question_score = params[:questionnaire][:max_question_score] # 1

      author_team = AssignmentTeam.team(Participant.find(participant_id)) # Gets the participant's team for the assignment

      @questionnaire.instructor_id = author_team.id # for a team assignment, set the instructor id to the team_id

      if @questionnaire.min_question_score < 0 || @questionnaire.max_question_score < 0
        flash[:error] = 'Minimum and/or maximum question score cannot be less than 0.'
        redirect_back fallback_location: root_path
      elsif @questionnaire.max_question_score < @questionnaire.min_question_score
        flash[:error] = 'Maximum question score cannot be less than minimum question score.'
        redirect_back fallback_location: root_path
      else
        @successful_create = true
        save
        save_choices @questionnaire.id
        flash[:note] = 'The quiz was successfully created.' if @successful_create
        redirect_to controller: 'submitted_content', action: 'edit', id: participant_id
      end
    else
      flash[:error] = valid.to_s
      redirect_back fallback_location: root_path
    end
  end

  # edit a quiz questionnaire
  def edit
    @questionnaire = Questionnaire.find(params[:id])
    if @questionnaire.taken_by_anyone?
      flash[:error] = 'Your quiz has been taken by one or more students; you cannot edit it anymore.'
      redirect_to controller: 'submitted_content', action: 'view', id: params[:pid]
    else # quiz can be edited only if its not taken by anyone
      render :'questionnaires/edit'
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
      params[:question].each_pair do |qid, _|
        @question = Question.find(qid)
        @question.txt = params[:question][qid.to_sym][:txt]
        @question.weight = params[:question_weights][qid.to_sym][:txt]
        @question.save
        @quiz_question_choices = QuizQuestionChoice.where(question_id: qid)
        question_index = 1
        @quiz_question_choices.each do |question_choice| # Updates state of each question choice for selected question
          # Call private methods to handle question types
          update_checkbox(question_choice, question_index) if @question.type == 'MultipleChoiceCheckbox'
          update_radio(question_choice, question_index) if @question.type == 'MultipleChoiceRadio'
          update_truefalse(question_choice) if @question.type == 'TrueFalse'
          question_index += 1
        end
      end
    end
    redirect_to controller: 'submitted_content', action: 'view', id: params[:pid]
  end

  # validate quiz name, questions, answers
  # Returns "valid" if there are no issues, or a string indicating why the quiz is invalid
  def validate_quiz
    num_questions = Assignment.find(params[:aid]).num_quiz_questions
    valid = 'valid'
    if params[:questionnaire][:name] == '' # questionnaire name is not specified
      valid = 'Please specify quiz name (please do not use your name or id).'
    end
    (1..num_questions).each do |i|
      break unless valid == 'valid'

      valid = validate_question(i)
    end
    valid
  end

  private

  def team_valid?(participant_id, assignment)
    team = AssignmentParticipant.find(participant_id).team
    if team.nil? # flash error if this current participant does not have a team
      flash[:error] = 'You should create or join a team first.'
      false
    elsif assignment.topics? && team.topic.nil? # flash error if this assignment has topic but current team does not have a topic
      flash[:error] = 'Your team should have a topic.'
      false
    else # the current participant is part of a team that has a topic
      true
    end
  end

  # A question is valid if it has a valid type ('TrueFalse', 'MultipleChoiceCheckbox', 'MultipleChoiceRadio') and a correct answer selected
  def validate_question(i)
    if params.key?(:question_type) && params[:question_type].key?(i.to_s) && params[:question_type][i.to_s][:type]
      # The question type is dynamic, so const_get is necessary
      type = params[:question_type][i.to_s][:type]
      @new_question = Object.const_get(type).create(txt: '', type: type, break_before: true)
      @new_question.update_attributes(txt: params[:new_question][i.to_s])
      choice_info = params[:new_choices][i.to_s][type] # choice info for one question of its type
      valid = if choice_info.nil?
                'Please select a correct answer for all questions'
              else
                @new_question.isvalid(choice_info)
              end
    else
      # A type isn't selected for a question
      valid = 'Please select a type for each question'
    end
    valid
  end

  # create multiple choice (radio or checkbox) item(s)
  def create_multchoice(question, choice_key, q_answer_choices)
    # this method combines the functionality of create_radio and create_checkbox, so that all mult choice items are create by 1 func
    question_choice = if q_answer_choices[choice_key][:iscorrect] == 1.to_s
                        QuizQuestionChoice.new(txt: q_answer_choices[choice_key][:txt], iscorrect: 'true', question_id: question.id)
                      else
                        QuizQuestionChoice.new(txt: q_answer_choices[choice_key][:txt], iscorrect: 'false', question_id: question.id)
                      end
    question_choice.save
  end

  # create true/false item
  def create_truefalse(question, choice_key, q_answer_choices)
    if q_answer_choices[1.to_s][:iscorrect] == choice_key
      question_choice = QuizQuestionChoice.new(txt: 'True', iscorrect: 'true', question_id: question.id)
      question_choice.save
      question_choice = QuizQuestionChoice.new(txt: 'False', iscorrect: 'false', question_id: question.id)
      question_choice.save
    else
      question_choice = QuizQuestionChoice.new(txt: 'True', iscorrect: 'false', question_id: question.id)
      question_choice.save
      question_choice = QuizQuestionChoice.new(txt: 'False', iscorrect: 'true', question_id: question.id)
      question_choice.save
    end
  end

  # update checkbox item
  def update_checkbox(question_choice, question_index)
    if params[:quiz_question_choices][@question.id.to_s][@question.type][question_index.to_s]
      question_choice.update_attributes(
        iscorrect: params[:quiz_question_choices][@question.id.to_s][@question.type][question_index.to_s][:iscorrect],
        txt: params[:quiz_question_choices][@question.id.to_s][@question.type][question_index.to_s][:txt]
      )
    else
      question_choice.update_attributes(
        iscorrect: '0',
        txt: params[:quiz_question_choices][question_choice.id.to_s][:txt]
      )
    end
  end

  # update radio item
  def update_radio(question_choice, question_index)
    if params[:quiz_question_choices][@question.id.to_s][@question.type][:correctindex] == question_index.to_s
      question_choice.update_attributes(
        iscorrect: '1',
        txt: params[:quiz_question_choices][@question.id.to_s][@question.type][question_index.to_s][:txt]
      )
    else
      question_choice.update_attributes(
        iscorrect: '0',
        txt: params[:quiz_question_choices][@question.id.to_s][@question.type][question_index.to_s][:txt]
      )
    end
  end

  # update true/false item
  def update_truefalse(question_choice)
    if params[:quiz_question_choices][@question.id.to_s][@question.type][1.to_s][:iscorrect] == 'True' # the statement is correct
      question_choice.txt == 'True' ? question_choice.update_attributes(iscorrect: '1') : question_choice.update_attributes(iscorrect: '0')
      # the statement is correct so "True" is the right answer
    else # the statement is not correct
      question_choice.txt == 'True' ? question_choice.update_attributes(iscorrect: '0') : question_choice.update_attributes(iscorrect: '1')
      # the statement is not correct so "False" is the right answer
    end
  end

  # save questionnaire
  def save
    @questionnaire.save!
    save_questions @questionnaire.id unless @questionnaire.id.nil? || @questionnaire.id <= 0
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

  # Saves either True/False or Multiple Choice questions to a quiz questionnaire
  # Only scorable questions can be added to a quiz, but future projects could consider relaxing this constraint
  def save_choices(questionnaire_id)
    return unless params[:new_question] || params[:new_choices]

    questions = Question.where(questionnaire_id: questionnaire_id)
    question_num = 1

    questions.each do |question|
      q_type = params[:question_type][question_num.to_s][:type]
      q_answer_choices = params[:new_choices][question_num.to_s][q_type]
      q_answer_choices.each_pair do |choice_key, _|
        question_factory(q_type, question, choice_key, q_answer_choices) # allow factory method to create appropriate question
      end
      question_num += 1
      question.weight = 1
    end
  end

  # factory method to create the appropriate question based on the question type (true/false or multiple choice)
  def question_factory(q_type, question, choice_key, q_answer_choices)
    if q_type == 'TrueFalse'
      create_truefalse(question, choice_key, q_answer_choices)
    else # create MultipleChoice of either type, rather than creating them separately based on q_type
      create_multchoice(question, choice_key, q_answer_choices)
    end
  end

  def questionnaire_params
    params.require(:questionnaire).permit(:name, :instructor_id, :private, :min_question_score,
                                          :max_question_score, :type, :display_type, :instruction_loc)
  end
end
