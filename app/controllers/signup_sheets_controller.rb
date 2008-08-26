class SignupSheetsController < ApplicationController

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    set_up_display_options("SIGNUPSHEET")
    @signup_sheets = super(SignupSheet)
#    @signup_sheet_pages, @signup_sheets = paginate :signup_sheets, :per_page => 10
  end

  def listuser
     @signup_sheets = SignupSheet.find_all
  end

  def show
    @signup_sheet = SignupSheet.find(params[:id])
  end

  def new
    @signup_sheet = SignupSheet.new
    @question = Question.new
    @assignments = Assignment.find_by_sql("select * from assignments")
  end

  def create
    @signup_sheet = SignupSheet.new(params[:signup_sheet])
    @signup_sheet.assignment_id = @params[:assignment_id]
    @signup_sheet.team = Assignment.find_by_id(params[:assignment_id]).team_assignment.to_s
    @signup_sheet.name = Assignment.find_by_id(@signup_sheet.assignment_id).name+" Signup "+getcount(@signup_sheet.assignment_id).to_s
    @signup_sheet.instructor_id = session[:user].id
    begin
      if @signup_sheet.save
        @current_id = SignupSheet.find_by_sql("select max(id) as id from signup_sheets")
        save_questions @current_id[0].id
        flash[:notice] = 'Signup sheet was successfully created.'
        redirect_to :action => 'list'
      else
        @signup_sheets = SignupSheet.find_all 
        @signup_sheet_pages, @signup_sheets = paginate :signup_sheets, :per_page => 10
        @assignments = Assignment.find_by_sql("select * from assignments")
        @question = Question.new
        render :action => 'new'
      end
    rescue ActiveRecord::RecordNotFound
    end
  end

  def edit
    @assignments = Assignment.find_by_sql("select * from assignments")
    @signup_sheet = SignupSheet.find(params[:id])
  end

  def update
    @signup_sheet = SignupSheet.find(params[:id])
    @signup_sheet.update_attributes(params[:signup_sheet])
    #count = SignupSheet.connection.update("update signup_sheets set name='"+params[:signup_sheet]["name"]+"', start_date='"+params[:signup_sheet]['start_date']+"', end_date='"+params[:signup_sheet]['end_date']+"', waitlist_deadline='"+params[:signup_sheet]['waitlist_deadline']+"', private='"+params[:signup_sheet]['private']+"' where id="+params[:id], nil)
    if @signup_sheet.save
      # now update the questions
      update_questions params[:id]
      flash[:notice] = 'SignupSheet was successfully updated.'
      redirect_to :action => 'show', :id => params[:id]
    else
      flash[:notice] = 'SignupSheet was not successfully updated.'
      @assignments = Assignment.find_by_sql("select * from assignments")
      render :action => 'edit', :id => params[:id]
    end
  end

  def destroy
    SignupSheet.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  private
  def save_questions(signup_id)
    logger.info "inside save questions"
    delete_questions signup_id
    if params[:question]
      # The new_question array contains all the new questions
      # that should be saved to the database
      for question in params[:question]
        q = Question.new(question)
        q.signup_sheet_id = signup_id
        q.save if !q.txt.strip.empty?
      end
    end
    save_new_questions signup_id
  end
  
  def update_questions(signup_id)
    delete_questions signup_id
    if params[:question]
      # The new_question array contains all the new questions
      # that should be saved to the database
      for question_key in params[:question].keys
        q = Question.new(params[:question][question_key])
        q.signup_sheet_id = signup_id
        q.save if !q.txt.strip.empty?
      end
    end
    save_new_questions signup_id
  end
  
  def save_new_questions(signup_id)
    if params[:new_question]
      # The new_question array contains all the new questions
      # that should be saved to the database
      for question_key in params[:new_question].keys
        q = Question.new(params[:new_question][question_key])
        q.signup_sheet_id = signup_id
        q.save if !q.txt.strip.empty?
      end
    end
  end
  
  def delete_questions(signup_id)
    # Deletes any questions that, as a result of the edit, are no longer in the rubric
    logger.info "inside delete questions"
    questions = Question.find(:all, :conditions => "signup_sheet_id = " + signup_id.to_s)
    for question in questions
      if (params[:questions] != nil)
        for question_key in params[:question].keys
          if question_key.to_s != question.id.to_s
            question.destroy
          end
        end
      else
        Question.connection.execute("delete from questions where signup_sheet_id = " + signup_id.to_s)
      end  
    end
  end
  
  def getcount(id)
    @count = SignupSheet.find_by_sql("select count(id) as id from signup_sheets where assignment_id ="+id.to_s)
    @count[0].id+1
  end
end
