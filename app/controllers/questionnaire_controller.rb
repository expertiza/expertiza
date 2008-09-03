class QuestionnaireController < ApplicationController
  
  before_filter :authorize
  
  def copy
    orig_questionnaire = Questionnaire.find(params[:id])
    new_questionnaire = orig_questionnaire.clone
    if (session[:user]).role_id != 6
      new_questionnaire.instructor_id = session[:user].id
    else # for TA we need to get his instructor id and by default add it to his course for which he is the TA
      new_questionnaire.instructor_id = Ta.get_my_instructor((session[:user]).id)
    end
    new_questionnaire.name = 'Copy of '+orig_questionnaire.name
    if new_questionnaire.save
      parent = QuestionnaireTypeNode.find_by_node_object_id(new_questionnaire.type_id)
      QuestionnaireNode.create(:node_object_id => new_questionnaire.id, :parent_id => parent.id)
      redirect_to :controller => 'questionnaire', :action => 'edit', :id => new_questionnaire.id
    else
      flash[:error] = 'The questionnaire was not able to be copied. Please check the original course for missing information.'
      redirect_to :action => 'list', :controller => 'tree_display'
    end      
  end
  
  def list
    set_up_display_options("QUESTIONNAIRE")
    @questionnaires = super(Questionnaire)
  end
  ## There needs to be an option for administrators to list all questionnaires (public & private)
  
  def copy_questionnaire
    @questionnaire = get(Questionnaire, params[:id])
    
    if params['save']
      @questionnaire = Questionnaire.new
      # Take attributes from form filled in by user
      @questionnaire.update_attributes(params[:questionnaire])
      @questionnaire.instructor_id = session[:user].id
      @questionnaire.save
      copy_questions(params[:id], @questionnaire.id)
      save_new_questions(@questionnaire.id)
      
      flash[:notice] = 'questionnaire was successfully copied.'
      redirect_to :action => 'list'
    end
  end
  
  def delete
    questionnaire = get(Questionnaire, params[:id])
    node = QuestionnaireNode.find_by_node_object_id(questionnaire.id)             
    if node
      node.destroy
    end
    if questionnaire == nil
      redirect_to :action => 'list', :controller => 'tree_display'
    else 
      if questionnaire.assignments_exist? == false or params['delete']
        questionnaire.delete_assignments
        questionnaire.delete_questions
        questionnaire.destroy
        redirect_to :action => 'list', :controller => 'tree_display'
      end
    end
  end
  
  def view_questionnaire
    @questionnaire = get(Questionnaire, params[:id])
    redirect_to :action => 'list' if @questionnaire == nil
  end
  
  def edit
    @questionnaire = get(Questionnaire, params[:id])
    redirect_to :action => 'list' if @questionnaire == nil
    if params['save']
      @questionnaire.update_attributes(params[:questionnaire])
      if (session[:user]).role_id == 6
        @questionnaire.instructor_id = Ta.get_my_instructor((session[:user]).id)
      end  
      save_questionnaire 'edit_questionnaire', false
    end
    
    if (session[:user]).role_id == 6
      @questionnaire.instructor_id = Ta.get_my_instructor((session[:user]).id)
    end
    
    if params['export']
      filename = QuestionnaireHelper::create_questionnaire_csv @questionnaire, session[:user].name
      send_file(filename) 
    end
    
    if params['import']
      file = params['csv']
      questions = QuestionnaireHelper::get_questions_from_csv(@questionnaire, file)
      
      if questions != nil and questions.length > 0
        @questionnaire.delete_questions
        @questionnaire.questions = questions
      end
    end
    
    if params['view_advice']
        redirect_to :action => 'edit_advice', :id => params[:questionnaire][:id]
    end
  end
    
  def new_questionnaire
    
    if params[:type_id] && params[:type_id] == "3" && session[:user].role_id != 3 && session[:user].role_id != 4
      redirect_to '/'
      return
    end
    
    @questionnaire = Questionnaire.new
    @questionnaire.min_question_score = Questionnaire::DEFAULT_MIN_QUESTION_SCORE
    @questionnaire.max_question_score = Questionnaire::DEFAULT_MAX_QUESTION_SCORE
    
  end

  def create_questionnaire
    if params[:questionnaire][:id] != nil and params[:questionnaire][:id].to_i > 0
      # questionnaire already exists in the database
      @questionnaire = get(Questionnaire, params[:id])
    end
    @questionnaire = Questionnaire.new if @questionnaire == nil
    @questionnaire.update_attributes(params[:questionnaire])
    if (session[:user]).role_id == 6
      @questionnaire.instructor_id = Ta.get_my_instructor((session[:user]).id)
    end   
    # Don't save until Save button is pressed
    if params[:save]
      save_questionnaire 'new_questionnaire', true
    end
  end
  
  def edit_advice
    @questionnaire = get(Questionnaire, params[:id])
    
    for question in @questionnaire.questions
      if question.true_false
        num_questions = 2
      else
        num_questions = @questionnaire.max_question_score - @questionnaire.min_question_score
      end
      
      sorted_advice = question.question_advices.sort {|x,y| y.score <=> x.score } 
      if question.question_advices.length != num_questions or
         sorted_advice[0].score != @questionnaire.min_question_score or
         sorted_advice[sorted_advice.length-1] != @questionnaire.max_question_score
        #  The number of advices for this question has changed.
        questionnaire_changed = QuestionnaireHelper::adjust_advice_size(@questionnaire, question)
      end
    end
    @questionnaire = get(Questionnaire, params[:id])
  end
  
  def save_advice
    begin
      for advice_key in params[:advice].keys
        p params[:advice][advice_key]
        QuestionAdvice.update(advice_key, params[:advice][advice_key])
      end
      flash[:notice] = "The questionnaire's question advice was successfully saved"
      redirect_to :action => 'list'
      
    rescue ActiveRecord::RecordNotFound
      render :action => 'edit_advice'
    end
  end
  
  private
  def save_questionnaire(failure_action, save_instructor_id)
    @questionnaire.instructor_id = session[:user].id if save_instructor_id
    save_questions @questionnaire.id if @questionnaire.id != nil and @questionnaire.id > 0
    
    if @questionnaire.save
      parent = QuestionnaireTypeNode.find_by_node_object_id(@questionnaire.type_id)
      QuestionnaireNode.create(:parent_id => parent.id, :node_object_id => @questionnaire.id)             
      flash[:notice] = 'questionnaire was successfully saved.'
      redirect_to :controller => 'tree_display', :action => 'list'
    else # If something goes wrong, stay at same page
      render :action => failure_action
    end
  end
  
  def copy_questions(old_id, new_id)
    # Creates a new copy of each question belonging to the copied questionnaire.
    # Each new question will belong to the newly created rubri
    questions = Question.find(:all, :conditions => ["questionnaire_id = ?", old_id])
    
    for question in questions
      q = Question.new(question.attributes)
      q.questionnaire_id = new_id
      q.save
    end
  end
  
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
  
  def save_questions(questionnaire_id)
    # Handles questions whose wording changed as a result of the edit
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