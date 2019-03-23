class WaitlistsController < ApplicationController
  def index
    list
    render action: 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify method: :post, only: %i[destroy create update],
         redirect_to: {action: :list}

  def list
    @waitlists = Waitlist.paginate(page: params[:page], per_page: 10)
  end

  def show
    @waitlist = Waitlist.find(params[:id])
  end

  def new
    @waitlist = Waitlist.new
  end

  def create
    @waitlist = Waitlist.new(waitlist_params)
    if @waitlist.save
      flash[:notice] = 'The wait list was successfully created.'
      redirect_to action: 'list'
    else
      render action: 'new'
    end
  end

  def edit
    @waitlist = Waitlist.find(params[:id])
  end

  def update
    @waitlist = Waitlist.find(params[:id])
    if @waitlist.update_attributes(waitlist_params)
      flash_update
    else
      render action: 'edit'
    end
  end
  
  def flash_update
    flash[:notice] = 'The wait list was successfully updated.'
    redirect_to action: 'show', id: @waitlist
  end

  def destroy
    Waitlist.find(params[:id]).destroy
    redirect_to action: 'list'
  end
end

private

def waitlist_params
  params.require(:waitlist)
end
