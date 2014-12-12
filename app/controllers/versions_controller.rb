class VersionsController < ApplicationController

  def index
    redirect_to '/versions/search'
  end

  def show
    @version = Version.find_by_id(params[:id])
  end

  def search
    @per_page = params[:num_versions]

    # Get the versions list to show on current page
    if params[:post]
      @versions = paginate_list(params[:id], params[:post][:user_id], params[:post][:item_type],
                                params[:post][:event], params[:datetime])
    else
      @versions = Version.page(params[:page]).order('id').per_page(25).all
    end
  end

  def destroy_all
    Version.destroy_all
    redirect_to versions_path, notice: "All versions have been deleted"
  end

  def destroy
    Version.find(params[:id]).destroy
    redirect_to versions_path, notice: "Your version has been deleted"
  end

  before_filter :conflict? , :except => [:index,:destroy, :destroy_all]
  # test if someone else has edited the same item to undo

  def conflict?
    @version = Version.find_by_id(params[:id])
    if @version
      @versions = Version.where( ["whodunnit = ? AND created_at = ?", @version.version_author, @version.created_at])
      @versions.each do |v|
        if v.item
          if v.item.versions.last.whodunnit.to_i != session[:user].id
            flash[:note] = "User #{User.find(v.item.versions.last.whodunnit).name} has edited this item since your last edit. "
            redirect_to :back
          end
        end
      end
    end
  end

  def revert
    @version = Version.find(params[:id])
    # find all new versions created by current user at one single action
    @versions = Version.where( ["whodunnit = ? AND created_at BETWEEN ? AND ?", @version.version_author,@version.created_at-1.0,@version.created_at + 1.0] )
    @iteration = 0
    # due to association constraints, the
    while @versions.length != 0 and @iteration <= 5
      @versions_clone = @versions.clone
      @versions_clone.each do |v|
        if v.reify
          begin
            v.reify.save!
          rescue
          else
            @versions.delete(v)
          end
        else
          if v.item
            v.item.destroy
          end
          @versions.delete(v)
        end
      end
      @iteration += 1
    end
    @message = params[:redo] == "true" ? "Previous action has been undone successfully. " : "Previous action has been redone successfully. "
    undo_link(@message)
    redirect_to :back
  end

  private

  def action_allowed?
    true
  end

  # For filtering the versions list with proper search and pagination.
  def paginate_list(id, user_id, item_type, event, datetime)
    # Set up the search criteria
    criteria = ''
    criteria = criteria + "id = #{id} AND " if id && id.to_i > 0
    if current_user_role? == 'Super-Administrator'
      criteria = criteria + "whodunnit = #{user_id} AND " if user_id && user_id.to_i > 0
    end
    criteria = criteria + "whodunnit = #{current_user.try(:id)} AND " if current_user.try(:id) && current_user.try(:id).to_i > 0
    criteria = criteria + "item_type = '#{item_type}' AND " if item_type && !(item_type.eql? 'Any')
    criteria = criteria + "event = '#{event}' AND " if event && !(event.eql? 'Any')
    criteria = criteria + "created_at >= '#{datetime['start(1i)']}-#{datetime['start(2i)']}-#{datetime['start(3i)']} #{datetime['start(4i)']}:#{datetime['start(5i)']}:00' AND "
    criteria = criteria + "created_at <= '#{datetime['end(1i)']}-#{datetime['end(2i)']}-#{datetime['end(3i)']} #{datetime['end(4i)']}:#{datetime['end(5i)']}:00' AND "

    if current_role == 'Instructor' || current_role == 'Administrator'

    end

    # Remove the last ' AND '
    criteria = criteria[0..-5]

    versions = Version.page(params[:page]).order('id').per_page(25).where(criteria)
    versions
  end
end
