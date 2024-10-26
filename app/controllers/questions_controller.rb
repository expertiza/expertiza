class QuestionsController < ApplicationController
  include AuthorizationHelper

  # A item is a single entry within a itemnaire
  # Questions provide a way of scoring an object
  # based on either a numeric value or a true/false
  # state.

  # Default action, same as list
  def index
    list
    render action: 'list'
  end

  def action_allowed?
    current_user_has_ta_privileges?
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify method: :post, only: %i[destroy create update],
         redirect_to: { action: :list }

  # List all items in paginated view
  def list
    @items = Question.paginate(page: params[:page], per_page: 10)
  end

  # Display a given item
  def show
    @item = Question.find(params[:id])
  end

  # Provide the user with the ability to define
  # a new item
  def new
    @item = Question.new
  end

  # Save a item created by the user
  # follows from new
  def create
    @item = Question.new(item_params[:item])
    if @item.save
      flash[:notice] = 'The item was successfully created.'
      redirect_to action: 'list'
    else
      render action: 'new'
    end
  end

  # edit an existing item
  def edit
    @item = Question.find(params[:id])
  end

  # save the update to an existing item
  # follows from edit
  def update
    @item = Question.find(item_params[:id])
    if @item.update_attributes(item_params[:item])
      flash[:notice] = 'The item was successfully updated.'
      redirect_to action: 'show', id: @item
    else
      render action: 'edit'
    end
  end

  # Remove item from database and
  # return to list
  def destroy
    item = Question.find(params[:id])
    itemnaire_id = item.itemnaire_id

    if AnswerHelper.check_and_delete_responses(itemnaire_id)
      flash[:success] = 'You have successfully deleted the item. Any existing reviews for the itemnaire have been deleted!'
    else
      flash[:success] = 'You have successfully deleted the item!'
    end

    begin
      item.destroy
    rescue StandardError
      flash[:error] = $ERROR_INFO
    end
    redirect_to edit_itemnaire_path(itemnaire_id.to_s.to_sym)
  end

  # required for answer tagging
  def types
    types = Question.distinct.pluck(:type)
    render json: types.to_a
  end

  # save all items that have been added to a itemnaire
  # uses the params new_item
  # if the itemnaire is a quizitemnaire then use weights given
  def save_new_items(itemnaire_id, itemnaire_type)
    if params[:new_item]
      # The new_item array contains all the new items
      # that should be saved to the database
      params[:new_item].keys.each_with_index do |item_key, index|
        q = Question.new
        q.txt = params[:new_item][item_key]
        q.itemnaire_id = itemnaire_id
        q.type = params[:item_type][item_key][:type]
        q.seq = item_key.to_i
        if itemnaire_type == 'QuizQuestionnaire'
          weight_key = "item_#{index + 1}"
          q.weight = params[:item_weights][weight_key.to_sym]
        end
        q.save unless q.txt.strip.empty?
      end
    end
    return
  end
  # delete items from a itemnaire
  # uses params itemnaire_id
  # checks if the items passed in params belongs to this itemnaire or not
  # if yes then it is deleted
  def delete_items(itemnaire_id)
    # Deletes any items that, as a result of the edit, are no longer in the itemnaire
    items = Question.where('itemnaire_id = ?', itemnaire_id)
    @deleted_items = []
    items.each do |item|
      should_delete = true
      unless item_params.nil?
        params[:item].each_key do |item_key|
          should_delete = false if item_key.to_s == item.id.to_s
        end
      end

      next unless should_delete

      item.item_advices.each(&:destroy)
      # keep track of the deleted items
      @deleted_items.push(item)
      item.destroy
    end
    return
  end
  # Handles items whose wording changed as a result of the edit
  # uses params itemnaire_id
  # uses params itemnaire_type
  # if the item text is empty then it is deleted
  # else it is updated
  def save_items
    itemnaire_id = params[:itemnaire_id]
    itemnaire_type = params[:itemnaire_type]
    delete_items itemnaire_id
    save_new_items(itemnaire_id, itemnaire_type)
    if params[:item]
      params[:item].keys.each do |item_key|
        if params[:item][item_key][:txt].strip.empty?
          Question.delete(item_key)
        else
          item = Question.find(item_key)
          Rails.logger.info(item.errors.messages.inspect) unless item.update_attributes(params[:item][item_key])
        end
      end
    end
    return
  end
  private

  def item_params
    params.require(:item).permit(:txt, :weight, :itemnaire_id, :seq, :type, :size,
                                     :alternatives, :break_before, :max_label, :min_label, :id, :item)
  end
end

