class QuizQuestionnairesController < QuestionnairesController

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
  def new
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

      render :new
    else
      redirect_to controller: 'submitted_content', action: 'view', id: params[:pid]
    end
  end

  # seperate method for creating a quiz questionnaire because of differences in permission
  def create
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
  def edit
    @questionnaire = Questionnaire.find(params[:id])
    if !@questionnaire.taken_by_anyone?
      render :edit
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

end
