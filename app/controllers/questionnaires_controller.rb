class QuestionnairesController < ApplicationController
  # Controller for Questionnaire objects
  # A Questionnaire can be of several types (QuestionnaireType)
  # Each Questionnaire contains zero or more questions (Question)
  # Generally a questionnaire is associated with an assignment (Assignment)

  before_filter :authorize

  def action_allowed?
    ['Administrator',
     'Instructor',
     'Teaching Assistant'].include? current_role_name
  end

  # Create a clone of the given questionnaire, copying all associated
  # questions. The name and creator are updated.
  def copy
    Questionnaire.copy_questionnaires(params[:id],session[:user])
      undo_link("Copy of questionnaire #{orig_questionnaire.name} has been created successfully. ")
      redirect_to :back
    rescue
      flash[:error] = 'The questionnaire was not able to be copied. Please check the original course for missing information.'+$!
      redirect_to :action => 'list', :controller => 'tree_display'
    end
  end

  # Remove a given questionnaire
  def delete
    @questionnaire = Questionnaire.find(params[:id])

    if @questionnaire
      begin
        name = @questionnaire.name

        @questionnaire.questions.each do |question|
          current_q_type = QuestionType.find_by_question_id(question.id)
          if current_q_type
            current_q_type.delete
          end
        end
        @questionnaire.assignments.each{
          | assignment |
          raise "The assignment #{assignment.name} uses this questionnaire. Do you want to <A href='../assignment/delete/#{assignment.id}'>delete</A> the assignment?"
        }
        @questionnaire.destroy
        undo_link("Questionnaire \"#{name}\" has been deleted successfully. ")
      rescue
        flash[:error] = $!
      end
    end

    redirect_to :action => 'list', :controller => 'tree_display'
  end

  def view
    redirect_to action: :show
  end

  #View a quiz questionnaire
  # Do I need to move this method to model? it renders a view at last.
  def view_quiz
    @questionnaire = Questionnaire.find(params[:id])
    @participant = Participant.find(params[:pid]) #creating an instance variable since it needs to be sent to submitted_content/edit
    render :view
  end

  def show
    @questionnaire = Questionnaire.find(params[:id])
  end

  # Edit a questionnaire
  def edit
    @questionnaire = Questionnaire.find(params[:id])
    redirect_to Questionnaire if @questionnaire == nil

    if params['save']
      @questionnaire.update_attributes(params[:questionnaire])
      redirect_to :action => 'view',:id => @questionnaire
    end

    Questionnaire.export(params[:id],session[:user]) if params['export']
    Questionnaire.import(params[:id], params['csv']) if params['import']

    if params['view_advice']
      redirect_to :controller => 'advice', :action => 'edit_advice', :id => params[:questionnaire][:id]
    end
  end


  #edit a quiz questionnaire
  # move this method?
  def edit_quiz
    @questionnaire = Questionnaire.find(params[:id])
    render :edit
  end


  #save an updated quiz questionnaire to the database
  # usage only in views/questionnaires/edit.html.erb line 5
  def update_quiz
    @questionnaire = Questionnaire.find(params[:id])
    redirect_to :controller => 'submitted_content', :action => 'edit', :id => params[:pid] if @questionnaire == nil
    if params['save']
      @questionnaire.update_attributes(params[:questionnaire])
      params[:question_type].keys.each do |qtypeid|
        @question_type = QuestionType.find(qtypeid)
        @question_type.update_attributes(params[:question_type][qtypeid])
      end
      question_num=1
      params[:new_question].keys.each do |qid|
        @question = Question.find(qid)
        @question.update_attributes(params[:new_question][qid])
        @question_type = QuestionType.find_by_question_id(qid)
        @quiz_question_choices = QuizQuestionChoice.where(question_id: qid)
        i=1
        @quiz_question_choices.each do |quiz_question_choice|
          if  @question_type.q_type!="Essay"
            if (@question_type.q_type=="MCC")
              if(params[:quiz_question_choices][questionnum.to_s][@question_type.q_type][i.to_s])
                if  params[:quiz_question_choices][questionnum.to_s][@question_type.q_type][i.to_s][:iscorrect]==1.to_s
                  quiz_question_choice.update_attributes(:iscorrect => '1',:txt=> params[:quiz_question_choices][quiz_question_choice.id.to_s][:txt])
                else
                  quiz_question_choice.update_attributes(:iscorrect => '0',:txt=> params[:quiz_question_choices][quiz_question_choice.id.to_s][:txt])
                end
              else
                quiz_question_choice.update_attributes(:iscorrect => '0',:txt=> params[:quiz_question_choices][quiz_question_choice.id.to_s][:txt])
              end
            else if (@question_type.q_type=="MCR")
              if  params[:quiz_question_choices][questionnum.to_s][@question_type.q_type][1.to_s][:iscorrect]== i.to_s
                quiz_question_choice.update_attributes(:iscorrect => '1',:txt=> params[:quiz_question_choices][quiz_question_choice.id.to_s][:txt])
              else
                quiz_question_choice.update_attributes(:iscorrect => '0',:txt=> params[:quiz_question_choices][quiz_question_choice.id.to_s][:txt])
              end
            else if (@question_type.q_type=="TF")
              if  params[:quiz_question_choices][questionnum.to_s][@question_type.q_type][1.to_s][:iscorrect]== 1.to_s
                quiz_question_choice.update_attributes(:iscorrect => '1',:txt=>"True")
              else
                quiz_question_choice.update_attributes(:iscorrect => '1',:txt=>"False")
              end
            end
          end
        end
        i+=1
      end
    end
    question_num+=1
  end
  # save
  #save_choices @questionnaire.id
end
redirect_to :controller => 'submitted_content', :action => 'edit', :id => params[:pid]
  end

  # Define a new questionnaire
  def new
    @questionnaire = Object.const_get(params[:model]).new
    @questionnaire.private = params[:private]
    @questionnaire.min_question_score = Questionnaire::DEFAULT_MIN_QUESTION_SCORE
    @questionnaire.max_question_score = Questionnaire::DEFAULT_MAX_QUESTION_SCORE
    @questionnaire.instruction_loc = Questionnaire::DEFAULT_QUESTIONNAIRE_URL
    @questionnaire.section = "Regular"
  end

  #define a new quiz questionnaire
  #method invoked by the view
  def new_quiz
    @questionnaire = Object.const_get(params[:model]).new
    @questionnaire.private = params[:private]
    @questionnaire.min_question_score = 0
    @questionnaire.max_question_score = 1
    @participant_id = params[:pid] #creating an instance variable to hold the participant id
    @assignment_id = params[:aid] #creating an instance variable to hold the assignment id
    render :new_quiz
  end

  # Save the new questionnaire to the database
  def create_questionnaire

    @questionnaire = Object.const_get(params[:questionnaire][:type]).new(params[:questionnaire])

    # TODO: check for Quiz Questionnaire?
    if @questionnaire.type == "QuizQuestionnaire" #checking if it is a quiz questionnaire
      participant_id = params[:pid] #creating a local variable to send as parameter to submitted content if it is a quiz questionnaire
      @questionnaire.min_question_score = 0
      @questionnaire.max_question_score = 1
      @questionnaire.section = "Quiz"
      @assignment = Assignment.find(params[:aid])
      teams = TeamsUser.where(user_id: session[:user].id)
      for t in teams do
        if Team.find(t.team_id, @assignment.id)
          if team = Team.find(t.team_id, @assignment.id)
            break
          end
        end
      end
      @questionnaire.instructor_id = team.id    #for a team assignment, set the instructor id to the team_id

      @successful_create = true

      save
      save_choices @questionnaire.id
      if @successful_create
        flash[:note] = "Quiz was successfully created"
      end
      redirect_to :controller => 'submitted_content', :action => 'edit', :id => participant_id
    else
      if (session[:user]).role.name == "Teaching Assistant"
        @questionnaire.instructor_id = Ta.get_my_instructor((session[:user]).id)
      end
      save

      redirect_to :controller => 'tree_display', :action => 'list'
    end
  end

  #seperate method for creating a quiz questionnaire because of differences in permission
  #used only in views/questionnaires/new_quiz.erb line 4
  def create_quiz_questionnaire
    valid = QuizQuestionnaire.valid_quiz(params[:aid],params[:new_question],params[:question_type],params[:new_choices])
    if valid.eql?("valid")
      create_questionnaire
    else
      flash[:error] = valid.to_s
      redirect_to :back
    end
  end


  def select_questionnaire_type
    @questionnaire = Object.const_get(params[:questionnaire][:type]).new(params[:questionnaire])
    @questionnaire.private = params[:questionnaire][:private]
    @questionnaire.min_question_score = params[:questionnaire][:min_question_score]
    @questionnaire.max_question_score = params[:questionnaire][:max_question_score]
    @questionnaire.section = params[:questionnaire][:section]
    @questionnaire.id = params[:questionnaire][:id]
    @questionnaire.display_type = params[:questionnaire][:display_type]
  end

  def create
    @questionnaire = Object.const_get(params[:questionnaire][:type]).new(params[:questionnaire])
    if (session[:user]).role.name == "Teaching Assistant"
      @questionnaire.instructor_id = Ta.get_my_instructor((session[:user]).id)
    else
      @questionnaire.instructor_id = session[:user].id
    end
    save
    redirect_to :controller => 'tree_display', :action => 'list'
  end

  def update
    @questionnaire = Questionnaire.find(params[:id])
    if current_user.role == Role.ta
      @questionnaire.instructor_id = Ta.get_my_instructor(current_user.id)
    else
      @questionnaire.instructor_id = current_user.id
    end

    if @questionnaire.update_attributes(params[:questionnaire])
      redirect_to :controller => 'tree_display', :action => 'list'
    else
      render 'edit'
    end
  end

  def edit_advice  ##Code used to be in this class, was removed.  I have not checked the other class.
    redirect_to :controller => 'advice', :action => 'edit_advice'
  end

  def save_advice
    begin
      params[:advice].keys.each do |advice_key|
        QuestionAdvice.update(advice_key, params[:advice][advice_key])
      end
      flash[:notice] = "The questionnaire's question advice was successfully saved"
      #redirect_to :action => 'list'
      redirect_to :controller => 'advice', :action => 'save_advice'
    end   ##Rescue clause was removed; why?
  end

  # Toggle the access permission for this assignment from public to private, or vice versa
  def toggle_access
    @questionnaire = Questionnaire.find(params[:id])
    @questionnaire.private = !@questionnaire.private
    @questionnaire.save
    @access = @questionnaire.private == true ? "private" : "public"
    undo_link("Questionnaire \"#{@questionnaire.name}\" has been made #{@access} successfully. ")
    redirect_to :controller => 'tree_display', :action => 'list'
  end

  private

  #save questionnaire object after create or edit
  def save
    begin
      @questionnaire.save!
      save_questions @questionnaire.id if @questionnaire.id and @questionnaire.id > 0
      if @questionnaire.type != "QuizQuestionnaire"
        pFolder = TreeFolder.find_by_name(@questionnaire.display_type)
        parent = FolderNode.find_by_node_object_id(pFolder.id)
        unless QuestionnaireNode.where(parent_id: parent.id, node_object_id: @questionnaire.id)
          QuestionnaireNode.create(:parent_id => parent.id, :node_object_id => @questionnaire.id)
        end
      end
      undo_link("Questionnaire \"#{@questionnaire.name}\" has been updated successfully. ")
    rescue
      @successful_create = false
      flash[:error] = $!
    end
  end

  #save parameters for new questions
  # move to models/question.rb directly
  #used only in save_new_questions line 419
  def save_new_question_parameters(qid, q_num)
    q = QuestionType.new
    q.q_type = params[:question_type][q_num][:type]
    q.parameters = params[:question_type][q_num][:parameters]
    q.question_id =  qid
    q.save
  end

  # save questions that have been added to a questionnaire
  # put this method into models/question.rb as save_new_questions(questionnaire_id,type)?
  #used only in save questions line 510
  def save_new_questions(questionnaire_id)
    if params[:new_question]
      # The new_question array contains all the new questions
      # that should be saved to the database
      params[:new_question].keys.each do |question_key|
        q = Question.new(params[:new_question][question_key])
        q.questionnaire_id = questionnaire_id
        if @questionnaire.type == "QuizQuestionnaire"
          q.weight = 1 #setting the weight to 1 for quiz questionnaire since the model validates this field
          # if q.true_false == ''
          q.true_false = false
        end
        unless q.txt.strip.empty?
          q.save
          if @questionnaire.type == "QuizQuestionnaire"
            save_new_question_parameters(q.id, question_key)
          end
          questionnaire = Questionnaire.find(questionnaire_id)
          if questionnaire.section == "Custom"
            for i in (questionnaire.min_question_score .. questionnaire.max_question_score)
              a = QuestionAdvice.new(:score => i, :advice => nil)
              a.question_id = q.id
              a.save
            end
            save_new_question_parameters(q.id, question_key)
          end
        end
      end
    end
  end

  # delete questions from a questionnaire
  # @param [Object] questionnaire_id
  # used only in save_questions
  def delete_questions(questionnaire_id)
    # Deletes any questions that, as a result of the edit, are no longer in the questionnaire
    questions = Question.where( "questionnaire_id = " + questionnaire_id.to_s)
    @deleted_questions = []
    questions.each do |question|
      should_delete = true
      if params[:question]
        for question_key in params[:question].keys
          if question_key.to_s == question.id.to_s
            should_delete = false
          end
        end
      end
      if should_delete
        question.question_advices.each do |advice|
          advice.destroy
        end
        if Questionnaire.find(questionnaire_id).section == "Custom"
          question_type = QuestionType.find_by_question_id(question.id)
          question_type.destroy
        end
        # keep track of the deleted questions
        @deleted_questions.push(question)
        question.destroy
      end
    end
  end

  # @param [Object] question_type_key
  # since it need params[:q], do I still need to move this method and use params[:q] as parameter? if not need to move, then all the save_questions can't be moved.
  # used only in save_questions line 538
  def update_question_type (question_type_key)
    this_q = QuestionType.find(question_type_key)
    this_q.parameters = params[:q][question_type_key][:parameters]

    if params[:q][question_type_key][:q_type] == "0"
      this_q.q_type =  Question::GRADING_TYPES_CUSTOM[0][0]
    elsif params[:q][question_type_key][:q_type] == "1"
      this_q.q_type =  Question::GRADING_TYPES_CUSTOM[1][0]
    elsif params[:q][question_type_key][:q_type] == "2"
      this_q.q_type =  Question::GRADING_TYPES_CUSTOM[2][0]
    elsif params[:q][question_type_key][:q_type] == "3"
      this_q.q_type =  Question::GRADING_TYPES_CUSTOM[3][0]
    elsif params[:q][question_type_key][:q_type] == "4"
      this_q.q_type =  Question::GRADING_TYPES_CUSTOM[4][0]
    else
      this_q.q_type =  Question::GRADING_TYPES_CUSTOM[5][0]
    end

    if this_q
      this_q.save
    end
  end

  # Handles questions whose wording changed as a result of the edit
  # @param [Object] questionnaire_id
  # put this method into models/question.rb as save_questions(questionnaire_id,type)?
  #used only in save line 390, this method is tightly related with the params[:question]
  def save_questions(questionnaire_id)
    delete_questions questionnaire_id
    save_new_questions questionnaire_id

    if params[:question]
     params[:question].keys.each do |question_key|
        begin
          if params[:question][question_key][:txt].strip.empty?
            # question text is empty, delete the question
            if Questionnaire.find(questionnaire_id).section == "Custom"
              QuestionType.find_by_question_id(question_key).delete
            end
            Question.delete(question_key)
          else
            # Update existing question.
            if (@questionnaire.type == "QuizQuestionnaire")
              Question.update(question_key,:weight => 1, :txt => params[:question][question_key][:txt] )
            else
              Question.update(question_key, params[:question][question_key])
            end
            Question.update(question_key, params[:question][question_key])
          end
        rescue ActiveRecord::RecordNotFound
          # ignored
        end
      end
      if Questionnaire.find(questionnaire_id).section == "Custom"
        params[:q].keys.each do |question_type_key|
          update_question_type(question_type_key)
        end
      end
    end
  end


  #method to save the choices associated with a question in a quiz to the database
  #only for quiz questionnaire
  def save_choices(questionnaire_id)
    if params[:new_question] and params[:new_choices]
      questions = Question.where(questionnaire_id: questionnaire_id)
      question_num = 1

      for question in questions
        q_type = params[:question_type][questionnum.to_s][:type]
        if(q_type!="Essay")
          for choice_key in params[:new_choices][questionnum.to_s][q_type].keys
    
            if params[:new_choices][questionnum.to_s][q_type][choice_key]["weight"] == 1.to_s
              score = 1
            else
              score = 0
            end

            if(q_type=="MCC")
              if (params[:new_choices][questionnum.to_s][q_type][choice_key][:iscorrect]==1.to_s)
                q = QuizQuestionChoice.new(:txt => params[:new_choices][questionnum.to_s][q_type][choice_key][:txt], :iscorrect => "true",:question_id => question.id)
              else
                q = QuizQuestionChoice.new(:txt => params[:new_choices][questionnum.to_s][q_type][choice_key][:txt], :iscorrect => "false",:question_id => question.id)
              end
            else  if(q_type=="TF")
              if (params[:new_choices][questionnum.to_s][q_type][1.to_s][:iscorrect]==choice_key)
                q = QuizQuestionChoice.new(:txt => "True", :iscorrect => "true",:question_id => question.id)
              else
                q = QuizQuestionChoice.new(:txt => "False", :iscorrect => "false",:question_id => question.id)
              end
            else
              if (params[:new_choices][questionnum.to_s][q_type][1.to_s][:iscorrect]==choice_key)
                q = QuizQuestionChoice.new(:txt => params[:new_choices][questionnum.to_s][q_type][choice_key][:txt], :iscorrect => "true",:question_id => question.id)
              else
                q = QuizQuestionChoice.new(:txt => params[:new_choices][questionnum.to_s][q_type][choice_key][:txt], :iscorrect => "false",:question_id => question.id)
              end
            end
            end
          q.save
          end
        end
        question_num += 1
        question.weight = 1
        question.true_false = false
    end
  end

end
