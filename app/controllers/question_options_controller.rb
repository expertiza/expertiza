class QuestionOptionsController < ApplicationController
  # GET /question_options
  # GET /question_options.xml
  def index
    @question_options = QuestionOption.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @question_options }
    end
  end

  # GET /question_options/1
  # GET /question_options/1.xml
  def show
    @question_option = QuestionOption.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @question_option }
    end
  end

  # GET /question_options/new
  # GET /question_options/new.xml
  def new
    @question_option = QuestionOption.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @question_option }
    end
  end

  # GET /question_options/1/edit
  def edit
    @question_option = QuestionOption.find(params[:id])
  end

  # POST /question_options
  # POST /question_options.xml
  def create
    @question_option = QuestionOption.new(params[:question_option])

    respond_to do |format|
      if @question_option.save
        format.html { redirect_to(@question_option, :notice => 'QuestionOption was successfully created.') }
        format.xml  { render :xml => @question_option, :status => :created, :location => @question_option }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @question_option.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /question_options/1
  # PUT /question_options/1.xml
  def update
    @question_option = QuestionOption.find(params[:id])

    respond_to do |format|
      if @question_option.update_attributes(params[:question_option])
        format.html { redirect_to(@question_option, :notice => 'QuestionOption was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @question_option.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /question_options/1
  # DELETE /question_options/1.xml
  def destroy
    @question_option = QuestionOption.find(params[:id])
    @question_option.destroy

    respond_to do |format|
      format.html { redirect_to(question_options_url) }
      format.xml  { head :ok }
    end
  end
end
