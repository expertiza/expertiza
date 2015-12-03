class QuestionnairesQuizController < ApplicationController

  before_filter :authorize

  #=========================================================================================================
  #Separate methods for quiz questionnaire
  #=========================================================================================================
  #View a quiz questionnaire
  def view_quiz
    @questionnaire = Questionnaire.find(params[:id])
    @participant = Participant.find(params[:pid]) #creating an instance variable since it needs to be sent to submitted_content/edit
    render :view
  end

  #define a new quiz questionnaire
  #method invoked by the view
  def new_quiz
    valid_request=true
    @assignment_id = params[:aid] #creating an instance variable to hold the assignment id
    @participant_id = params[:pid] #creating an instance variable to hold the participant id
    assignment = Assignment.find(@assignment_id)
    if !assignment.require_quiz? #flash error if this assignment does not require quiz
      flash[:error] = "This assignment does not support quizzing feature."
      valid_request=false
    else
      team = AssignmentParticipant.find(@participant_id).team
      if team.nil? #flash error if this current participant does not have a team
        flash[:error] = "You should create or join a team first."
        valid_request=false
      else
        if assignment.has_topics? && team.topic.nil?#flash error if this assignment has topic but current team does not have a topic
          flash[:error] = "Your team should have a topic first."
          valid_request=false
        end
      end
    end

    if valid_request
      @questionnaire = Object.const_get(params[:model]).new
      @questionnaire.private = params[:private]
      @questionnaire.min_question_score = 0
      @questionnaire.max_question_score = 1
      render :new_quiz
    else
      redirect_to controller: 'submitted_content', action: 'view', id: params[:pid]
    end
  end

  #seperate method for creating a quiz questionnaire because of differences in permission
  def create_quiz_questionnaire
    valid = valid_quiz
    if valid.eql?("valid")
      create_questionnaire
    else
      flash[:error] = valid.to_s
      redirect_to :back
    end
  end

  #edit a quiz questionnaire
  def edit_quiz
    @questionnaire = Questionnaire.find(params[:id])
    if !@questionnaire.taken_by_anyone?
      render :edit
    else
      flash[:error] = "Your quiz has been taken by some other students, editing cannot be done any more."
      redirect_to controller: 'submitted_content', action: 'view', id: params[:pid]
    end
  end

  #save an updated quiz questionnaire to the database
  def update_quiz
    @questionnaire = Questionnaire.find(params[:id])
    redirect_to controller: 'submitted_content', action: 'view', id: params[:pid] if @questionnaire == nil
    if params['save']
      @questionnaire.update_attributes(questionnaire_params)
      for qid in params[:question].keys
        @question = Question.find(qid)
        @question.txt = params[:question][qid.to_sym][:txt]
        @question.save
        @quiz_question_choices = QuizQuestionChoice.where(question_id: qid)
        i=1
        for quiz_question_choice in @quiz_question_choices
          choose_question_type(i, quiz_question_choice)
          i+=1
        end
      end
    end
    redirect_to controller: 'submitted_content', action: 'view', id: params[:pid]
  end

  def choose_question_type(i, quiz_question_choice)
    if (@question.type=="MultipleChoiceCheckbox")
      if (params[:quiz_question_choices][@question.id.to_s][@question.type][i.to_s])
        quiz_question_choice.update_attributes(iscorrect: params[:quiz_question_choices][@question.id.to_s][@question.type][i.to_s][:iscorrect], txt: params[:quiz_question_choices][@question.id.to_s][@question.type][i.to_s][:txt])
      else
        quiz_question_choice.update_attributes(iscorrect: '0', txt: params[:quiz_question_choices][quiz_question_choice.id.to_s][:txt])
      end
    end
    if (@question.type=="MultipleChoiceRadio")
      if params[:quiz_question_choices][@question.id.to_s][@question.type][:correctindex]== i.to_s
        quiz_question_choice.update_attributes(iscorrect: '1', txt: params[:quiz_question_choices][@question.id.to_s][@question.type][i.to_s][:txt])
      else
        quiz_question_choice.update_attributes(iscorrect: '0', txt: params[:quiz_question_choices][@question.id.to_s][@question.type][i.to_s][:txt])
      end
    end
    if (@question.type=="TrueFalse")
      if params[:quiz_question_choices][@question.id.to_s][@question.type][1.to_s][:iscorrect]== "True" # the statement is correct
        if quiz_question_choice.txt =="True"
          quiz_question_choice.update_attributes(iscorrect: '1') # the statement is correct so "True" is the right answer
        else
          quiz_question_choice.update_attributes(iscorrect: '0')
        end
      else # the statement is not correct
        if quiz_question_choice.txt =="True"
          quiz_question_choice.update_attributes(iscorrect: '0')
        else
          quiz_question_choice.update_attributes(iscorrect: '1') # the statement is not correct so "False" is the right answer
        end
      end
    end
  end

  def valid_quiz
    num_quiz_questions = Assignment.find(params[:aid]).num_quiz_questions
    valid = "valid"
    (1..num_quiz_questions).each do |i|
      if params[:new_question][i.to_s] == ''
        #One of the questions text is not filled out
        valid = "Please make sure all questions have text"
        break
      elsif !params.has_key?(:question_type) || !params[:question_type].has_key?(i.to_s) || params[:question_type][i.to_s][:type] == nil
        #A type isnt selected for a question
        valid = "Please select a type for each question"
        break
      elsif params[:questionnaire][:name]==""
        #questionnaire name is not specified
        valid = "Please specify quiz name (please do not use your name or id)."
        break
      else
        type = params[:question_type][i.to_s][:type]
        if type == 'MultipleChoiceCheckbox' || type == 'MultipleChoiceRadio'
          correct_selected, valid = valid_quiz_option(i, type)
          if valid == "valid" && !correct_selected
            #A correct option isnt selected for a check box or radio question
            valid = "Please select a correct answer for all questions"
            break
          end
        elsif type == 'TF' # TF is not disabled. We need to test TF later.
          if params[:new_choices][i.to_s]["TF"] == nil
            #A correct option isnt selected for a true/false question
            valid = "Please select a correct answer for all questions"
            break
          end
        end
      end
    end
    return valid
  end

  def valid_quiz_option(i, type)
    correct_selected = false
    (1..4).each do |x|
      if params[:new_choices][i.to_s][type][x.to_s][:txt] == ''
        #Text isnt provided for an option
        valid = "Please make sure every question has text for all options"
        break
      elsif type == 'MultipleChoiceRadio' and not params[:new_choices][i.to_s][type][x.to_s][:iscorrect] == nil
        correct_selected = true
      elsif type == 'MultipleChoiceCheckbox' and not params[:new_choices][i.to_s][type][x.to_s][:iscorrect] == 0.to_s
        correct_selected = true
      end
    end
    return correct_selected, valid
  end


end