class QuestionnaireController < ApplicationController
  
  before_filter :authorize
  
  def list
    set_up_display_options("QUESTIONNAIRE")
    @rubrics = super(Questionnaire)
  end
  ## There needs to be an option for administrators to list all rubrics (public & private)
  
  def copy_rubric
    @rubric = get(Questionnaire, params[:id])
    
    if params['save']
      @rubric = Questionnaire.new
      # Take attributes from form filled in by user
      @rubric.update_attributes(params[:rubric])
      @rubric.instructor_id = session[:user].id
      @rubric.save
      copy_questions(params[:id], @rubric.id)
      save_new_questions(@rubric.id)
      
      flash[:notice] = 'Rubric was successfully copied.'
      redirect_to :action => 'list'
    end
  end
  
  def delete_rubric
    @rubric = get(Questionnaire, params[:id])
    
    if @rubric == nil
      redirect_to :action => 'list' 
    else 
      if @rubric.assignments_exist? == false or params['delete']
        @rubric.delete_assignments
        @rubric.delete_questions
        @rubric.destroy
        redirect_to :action => 'list'
      end
    end
  end
  
  def edit_rubric
    @rubric = get(Questionnaire, params[:id])
    redirect_to :action => 'list' if @rubric == nil
   
    if params['save']
      @rubric.update_attributes(params[:rubric])
      save_rubric 'edit_rubric', false
    end
    
    if params['export']
      filename = RubricHelper::create_rubric_csv @rubric, session[:user].name
      send_file(filename) 
    end
    
    if params['import']
      file = params['csv']
      questions = RubricHelper::get_questions_from_csv(@rubric, file)
      
      if questions != nil and questions.length > 0
        @rubric.delete_questions
        @rubric.questions = questions
      end
    end
    
    if params['view_advice']
        redirect_to :action => 'edit_advice', :id => params[:rubric][:id]
    end
  end

  def new_rubric
    @rubric = Questionnaire.new
    @rubric.min_question_score = Questionnaire::DEFAULT_MIN_QUESTION_SCORE
    @rubric.max_question_score = Questionnaire::DEFAULT_MAX_QUESTION_SCORE
  end

  def create_rubric
    if params[:rubric][:id] != nil and params[:rubric][:id].to_i > 0
      # Rubric already exists in the database
      @rubric = get(Questionnaire, params[:id])
    end
    @rubric = Questionnaire.new if @rubric == nil
    @rubric.update_attributes(params[:rubric])
   
    # Don't save until Save button is pressed
    if params[:save]
      save_rubric 'new_rubric', true
    end
  end
  
  def edit_advice
    @rubric = get(Questionnaire, params[:id])
    
    for question in @rubric.questions
      if question.true_false
        num_questions = 2
      else
        num_questions = @rubric.max_question_score - @rubric.min_question_score
      end
      
      sorted_advice = question.question_advices.sort {|x,y| y.score <=> x.score } 
      if question.question_advices.length != num_questions or
         sorted_advice[0].score != @rubric.min_question_score or
         sorted_advice[sorted_advice.length-1] != @rubric.max_question_score
        #  The number of advices for this question has changed.
        rubric_changed = RubricHelper::adjust_advice_size(@rubric, question)
      end
    end
    @rubric = get(Questionnaire, params[:id])
  end
  
  def save_advice
    begin
      for advice_key in params[:advice].keys
        p params[:advice][advice_key]
        QuestionAdvice.update(advice_key, params[:advice][advice_key])
      end
      flash[:notice] = "The rubric's question advice was successfully saved"
      redirect_to :action => 'list'
      
    rescue ActiveRecord::RecordNotFound
      render :action => 'edit_advice'
    end
  end
  
  private
  def save_rubric(failure_action, save_instructor_id)
    @rubric.instructor_id = session[:user].id if save_instructor_id
    save_questions @rubric.id if @rubric.id != nil and @rubric.id > 0
    
    if @rubric.save
      flash[:notice] = 'Rubric was successfully saved.'
      redirect_to :action => 'list'
    else # If something goes wrong, stay at same page
      render :action => failure_action
    end
  end
  
  def copy_questions(old_id, new_id)
    # Creates a new copy of each question belonging to the copied rubric.
    # Each new question will belong to the newly created rubri
    questions = Question.find(:all, :conditions => ["questionnaire_id = ?", old_id])
    
    for question in questions
      q = Question.new(question.attributes)
      q.rubric_id = new_id
      q.save
    end
  end
  
  def save_new_questions(rubric_id)
    if params[:new_question]
      # The new_question array contains all the new questions
      # that should be saved to the database
      for question_key in params[:new_question].keys
        q = Question.new(params[:new_question][question_key])
        q.rubric_id = rubric_id
        q.save if !q.txt.strip.empty?
      end
    end
  end
  
  def delete_questions(rubric_id)
    # Deletes any questions that, as a result of the edit, are no longer in the rubric
    questions = Question.find(:all, :conditions => "rubric_id = " + rubric_id.to_s)
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
  
  def save_questions(rubric_id)
    # Handles questions whose wording changed as a result of the edit
    delete_questions rubric_id
    save_new_questions rubric_id
    
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