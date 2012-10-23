class WaitlistsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @waitlists = Waitlist.paginate(:page => params[:page], :per_page => 10)
  end

  def show
    @waitlist = Waitlist.find(params[:id])
  end

  def new
    @waitlist = Waitlist.new
  end

  def create
    @waitlist = Waitlist.new(params[:waitlist])
    if @waitlist.save
      flash[:notice] = 'Waitlist was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @waitlist = Waitlist.find(params[:id])
  end

  def update
    @waitlist = Waitlist.find(params[:id])
    if @waitlist.update_attributes(params[:waitlist])
      flash[:notice] = 'Waitlist was successfully updated.'
      redirect_to :action => 'show', :id => @waitlist
    else
      render :action => 'edit'
    end
  end

  def destroy
    Waitlist.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
