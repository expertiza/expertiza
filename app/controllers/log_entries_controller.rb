class LogEntriesController < ApplicationController
  # GET /log_entries/list
  # GET /log_entries/list.xml
  def index
    @log_entries = LogEntry.find(:all)

    respond_to do |format|
      format.html #  index.html.erb
      format.xml  { render :xml => @log_entries }
    end
  end

  # GET /log_entries
  # GET /log_entries.xml
  #def index
  #  respond_to do |format|
  #      format.html { redirect_to :controller => "log_entries", :action => "list" }
  #      format.xml  { head :ok }
  #  end
  #end

  # GET /log_entries/new
  # GET /log_entries/new.xml
  def new
    @log_entry = LogEntry.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @log_entry }
    end
  end

  # GET /log_entries/1/edit
  def edit
    @log_entry = LogEntry.find(params[:id])
  end

  # POST /log_entries
  # POST /log_entries.xml
  def create
    @log_entry = LogEntry.new(params[:log_entry])

    respond_to do |format|
      if @log_entry.save
        flash[:notice] = 'LogEntry was successfully created.'
        format.html { redirect_to(@log_entry) }
        format.xml  { render :xml => @log_entry, :status => :created, :location => @log_entry }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @log_entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /log_entries/1
  # PUT /log_entries/1.xml
  def update
    @log_entry = LogEntry.find(params[:id])

    respond_to do |format|
      if @log_entry.update_attributes(params[:log_entry])
        flash[:notice] = 'LogEntry was successfully updated.'
        format.html { redirect_to(@log_entry) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @log_entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /log_entries/1
  # DELETE /log_entries/1.xml
  def destroy
    @log_entry = LogEntry.find(params[:id])
    @log_entry.destroy

    respond_to do |format|
      format.html { redirect_to :controller => "log_entries", :action => "index"  }
      format.xml  { head :ok }
      end
  end
end
