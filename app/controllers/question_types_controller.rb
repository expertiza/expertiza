class QuestionTypesController < ApplicationController
  # GET /question_types
  # GET /question_types.xml
  def index
    @question_types = QuestionType.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @question_types }
    end
  end

  # GET /question_types/1
  # GET /question_types/1.xml
  def show
    @question_type = QuestionType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @question_type }
    end
  end

  # GET /question_types/new
  # GET /question_types/new.xml
  def new
    @question_type = QuestionType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @question_type }
    end
  end

  # GET /question_types/1/edit
  def edit
    @question_type = QuestionType.find(params[:id])
  end

  # POST /question_types
  # POST /question_types.xml
  def create
    @question_type = QuestionType.new(params[:question_type])

    respond_to do |format|
      if @question_type.save
        format.html { redirect_to(@question_type, :notice => 'QuestionType was successfully created.') }
        format.xml  { render :xml => @question_type, :status => :created, :location => @question_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @question_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /question_types/1
  # PUT /question_types/1.xml
  def update
    @question_type = QuestionType.find(params[:id])

    respond_to do |format|
      if @question_type.update_attributes(params[:question_type])
        format.html { redirect_to(@question_type, :notice => 'QuestionType was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @question_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /question_types/1
  # DELETE /question_types/1.xml
  def destroy
    @question_type = QuestionType.find(params[:id])
    @question_type.destroy

    respond_to do |format|
      format.html { redirect_to(question_types_url) }
      format.xml  { head :ok }
    end
  end
end
