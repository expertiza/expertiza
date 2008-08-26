class QuestionsController < ApplicationController
scaffold :answers

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @question_pages, @questions = paginate :questions, :per_page => 10
  end

  def listuser
         @question = Array.new
         @i = 0
         @sign_qts = SignupQuestion.find(:all,
                              :conditions => 'signup_id = '+@params[:id].to_s,          
                              :order => 'id')                         
                              
   end


  def SignupSheet
    @question_pages, @questions = paginate :questions, :per_page => 10
  end

  def show
    @question = Question.find(params[:id])
  end

  def new
    @question = Question.new    
  end

  def create
    @question = Question.new(params[:question])
    if @question.save
      flash[:notice] = 'Question was successfully created.'          
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @question = Question.find(params[:id])
  end

  def update
    @question = Question.find(params[:id])
    if @question.update_attributes(params[:question])
      flash[:notice] = 'Question was successfully updated.'
      redirect_to :action => 'show', :id => @question
    else
      render :action => 'edit'
    end
  end

  def destroy
    Question.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
