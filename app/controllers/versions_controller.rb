class VersionsController < ApplicationController
  before_action :conflict?, except: %i[index destroy destroy_all]
  def action_allowed?
    ['Instructor',
     'Teaching Assistant',
     'Administrator',
     'Super-Administrator',
     'Student'].include? current_role_name
  end

  def index
    redirect_to '/versions/search'
  end

  def show
    @version = Version.find_by(id: params[:id])
  end

  def search
    @per_page = params[:num_versions]

    # Get the versions list to show on current page
    @versions = if params[:post]
                  paginate_list
                else
                  Version.page(params[:page]).order('id').per_page(25).all
                end
  end

  def destroy_all
    Version.destroy_all
    redirect_to versions_path, notice: "All versions have been deleted."
  end

  def destroy
    Version.find(params[:id]).destroy
    redirect_to versions_path, notice: "Your version has been deleted."
  end

  # test if someone else has edited the same item to undo
  def conflict?
    @version = Version.find_by(id: params[:id])
    if @version
      @versions = Version.where("whodunnit = ? AND created_at = ?", @version.version_author, @version.created_at)
      @versions.each do |v|
        next unless v.item
        unless v.item.versions.last.whodunnit.to_i == session[:user].id
          flash[:note] = "User #{User.find(v.item.versions.last.whodunnit).name} has edited this item since your last edit. "
          redirect_to :back
        end
      end
    end
  end

  def revert
    @version = Version.find(params[:id])
    @versions = Version.where('whodunnit = ? AND created_at BETWEEN ? AND ?',
                              @version.version_author, @version.created_at - 1.0, @version.created_at + 1.0)
    @iteration = 0
    while !@versions.empty? and @iteration <= 5
      @versions_clone = @versions.clone
      @versions_clone.each do |v|
        if v.reify
          begin
            v.reify.save!
          rescue StandardError => e
            @versions.delete(v)
          end
        else
          v.item.destroy if v.item
          @versions.delete(v)
        end
      end
      @iteration += 1
    end
    @message = 'The previous action has been successfully ' + (params[:redo] == 'true' ? 'undone.' : 'redone.')
    undo_link(@message)
    redirect_to :back
  end

  private

  # For filtering the versions list with proper search and pagination.
  def paginate_list
    versions = Version.page(params[:page]).order('id').per_page(25)
    versions = versions.where(id: params[:id]) if params[:id].to_i > 0
    if current_user_role? == 'Super-Administrator'
      versions = versions.where(whodunnit: params[:post][:user_id]) if params[:post][:user_id].to_i > 0
    end
    versions = versions.where(whodunnit: current_user.try(:id)) if current_user.try(:id).to_i > 0
    versions = versions.where(item_type: params[:post][:item_type]) if params[:post][:item_type] && params[:post][:item_type] != 'Any'
    versions = versions.where(event: params[:post][:event]) if params[:post][:event] && params[:post][:event] != 'Any'
    versions.where('created_at >= ? and created_at <= ?', time_to_string(params[:start_time]), time_to_string(params[:end_time]))
  end

  def time_to_string(time)
    "#{time.tr('/', '-')}:00"
  end
end
