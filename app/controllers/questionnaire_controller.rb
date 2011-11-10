class QuestionnaireController < ApplicationController
  # Controller for Questionnaire objects
  # A Questionnaire can be of several types (QuestionnaireType)
  # Each Questionnaire contains zero or more questions (Question)
  # Generally a questionnaire is associated with an assignment (Assignment)  
  before_filter :authorize
  
  # Create a clone of the given questionnaire, copying all associated
  # questions. The name and creator are updated.
def copy
  orig_questionnaire = Questionnaire.find(params[:id])
  usersess= session[:user]
  @result = QuestionnaireHelper::copyqn(orig_questionnaire,usersess)
  if (@result == "false")
    flash[:error] = 'The questionnaire was not able to be copied. Please check the original course for missing information.'+$!
      redirect_to :action => 'list', :controller => 'tree_display'
  else
    redirect_to :controller => 'questionnaire', :action => 'view', :id => params[:id]
  end
end

  # Remove a given questionnaire
  def delete
    questionnaire = Questionnaire.find(params[:id])
    
    if questionnaire
       begin
          name = questionnaire.name
          questionnaire.delete
          flash[:note] = "Questionnaire <B>#{name}</B> was deleted."
      rescue
          flash[:error] = $!
      end
    end
    
    redirect_to :action => 'list', :controller => 'tree_display'   
  end
  
  # View a questionnaire
  def view
    @questionnaire = Questionnaire.find(params[:id])
  end
  
  # Edit a questionnaire
  def edit
    begin
    @questionnaire = Questionnaire.find(params[:id])
    redirect_to :action => 'list' if @questionnaire == nil
    
    if params['save']
      @questionnaire.update_attributes(params[:questionnaire])
      save_questionnaire  
    end
    
    if params['export']
      csv_data = QuestionnaireHelper::create_questionnaire_csv @questionnaire, session[:user].name

      send_data csv_data, 
        :type => 'text/csv; charset=iso-8859-1; header=present',
        :disposition => "attachment; filename=questionnaires.csv"
    end
    
    if params['import']
      file = params['csv']
      questions = QuestionnaireHelper::get_questions_from_csv(@questionnaire, file)
      
      if questions != nil and questions.length > 0

        # delete the existing questions if no scores have been recorded yet
        @questionnaire.questions.each {
          | question |
            raise "Cannot import new questions, scores exist" if Score.find_by_question_id(question.id)
            question.delete        
        }
        
        @questionnaire.questions = questions
      end
    end
    
    if params['view_advice']
        redirect_to :controller => 'question_advice', :action => 'edit', :id => params[:questionnaire][:id]
    end
    rescue
      flash[:error] = $!
    end
  end
    
  # Define a new questionnaire
  def new
    @questionnaire = Object.const_get(params[:model]).new
    @questionnaire.private = params[:private] 
    @questionnaire.min_question_score = Questionnaire::DEFAULT_MIN_QUESTION_SCORE
    @questionnaire.max_question_score = Questionnaire::DEFAULT_MAX_QUESTION_SCORE    
  end

  # Save the new questionnaire to the database
  def create_questionnaire
    @questionnaire = Object.const_get(params[:questionnaire][:type]).new(params[:questionnaire])

    if (session[:user]).role.name == "Teaching Assistant"
      @questionnaire.instructor_id = Ta.get_my_instructor((session[:user]).id)
    else
      @questionnaire.instructor_id = session[:user].id
    end       
    save_questionnaire    
    redirect_to :controller => 'question_advice', :action => 'create', :id => @questionnaire.id
  end

  private
  #save questionnaire object after create or edit
  def save_questionnaire     
    begin
      @questionnaire.save!
      save_questions @questionnaire.id if @questionnaire.id != nil and @questionnaire.id > 0

      pFolder = TreeFolder.find_by_name(@questionnaire.display_type)
      parent = FolderNode.find_by_node_object_id(pFolder.id)
      if QuestionnaireNode.find_by_parent_id_and_node_object_id(parent.id,@questionnaire.id) == nil
        QuestionnaireNode.create(:parent_id => parent.id, :node_object_id => @questionnaire.id)
      end
    rescue
      flash[:error] = $!
    end
  end

  
  # save questions that have been added to a questionnaire
  def save_new_questions(questionnaire_id)
    if params[:new_question]
      # The new_question array contains all the new questions
      # that should be saved to the database
      for question_key in params[:new_question].keys
        q = Question.new(params[:new_question][question_key])
        q.questionnaire_id = questionnaire_id
        q.save if !q.txt.strip.empty?
      end
    end
  end
  
  # delete questions from a questionnaire
  def delete_questions(questionnaire_id)
    # Deletes any questions that, as a result of the edit, are no longer in the questionnaire
    questions = Question.find(:all, :conditions => "questionnaire_id = " + questionnaire_id.to_s)
    for question in questions
      should_delete = true
      for question_key in params[:question].keys
        if question_key.to_s === question.id.to_s
          should_delete = false
        end
      end
      
      if should_delete == true
        for advice in question.question_advices
          advice.destroy
        end
        question.destroy
      end
    end
  end
  
  # Handles questions whose wording changed as a result of the edit    
  def save_questions(questionnaire_id)
    delete_questions questionnaire_id
    save_new_questions questionnaire_id
    
    if params[:question]
      for question_key in params[:question].keys
        begin
          if params[:question][question_key][:txt].strip.empty?
            # question text is empty, delete the question
            Question.delete(question_key)
          else
            # Update existing question.
            Question.update(question_key, params[:question][question_key])
          end
        rescue ActiveRecord::RecordNotFound 
        end
      end
    end
  end
end