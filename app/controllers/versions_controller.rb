class VersionsController < ApplicationController

  include PaginationHelper

  VERSIONS_PER_PAGE = 25

  def action_allowed?
    case params[:action]
    when 'new', 'create', 'edit', 'update'
    #Modifications can only be done by papertrail
      return false
    when 'destroy_all'
      ['Super-Administrator',
       'Administrator'].include? current_role_name
    else
      #Allow all others
      ['Super-Administrator',
       'Administrator',
       'Instructor',
       'Teaching Assistant',
       'Student'].include? current_role_name
    end
  end

  def new
    #nothing to do, papertrail handles create/update
  end

  def create
    #nothing to do, papertrail handles create/update
  end

  def edit
    #nothing to do, papertrail handles create/update
  end

  def update
    #nothing to do, papertrail handles create/update
  end

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
      search_criteria = BuildSearchCriteria(params[:id], params[:post][:user_id], params[:post][:item_type],
                                            params[:post][:event])
      versions_matching_search_criteria = Version.where(search_criteria)
      @versions = paginate_list versions_matching_search_criteria
    else
      user_ids = get_list_of_user_ids
      matching_versions = Version.where('whodunnit IN (?)', user_ids).order('id')
      @versions = paginate_list matching_versions
    end
  end

  def destroy_all
    Version.destroy_all
    redirect_to versions_path, notice: 'All versions have been deleted'
  end

  def destroy
    Version.find(params[:id]).destroy
    redirect_to versions_path, notice: 'Your version has been deleted'
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

  # pagination.
  def paginate_list(versions)
    paginate(versions, VERSIONS_PER_PAGE);
  end

  def BuildSearchCriteria(id, user_id, item_type, event)
    # Set up the search criteria
    search_criteria = ''
    search_criteria = search_criteria + add_id_filter_if_valid(id).to_s
    if current_user_role? == 'Super-Administrator'
      search_criteria = search_criteria + add_user_filter_for_super_admin(user_id).to_s
    end
    search_criteria = search_criteria + add_user_filter
    search_criteria = search_criteria + add_version_type_filter(item_type).to_s
    search_criteria = search_criteria + add_event_filter(event).to_s
    search_criteria = search_criteria + add_date_time_filter
    search_criteria
  end

  def get_list_of_user_ids
    users = current_user.get_user_list
    users << current_user
    user_ids = []
    users.each do |user|
      user_ids << user.id
    end
    user_ids
  end

  def add_id_filter_if_valid (id)
    "id = #{id} AND " if id && id.to_i > 0
  end

  def add_user_filter_for_super_admin (user_id)
    "whodunnit = #{user_id} AND " if user_id && user_id.to_i > 0
  end

  def add_user_filter
    "whodunnit = #{current_user.try(:id)} AND " if current_user.try(:id) && current_user.try(:id).to_i > 0
  end

  def add_event_filter (event)
    "event = '#{event}' AND " if event && !(event.eql? 'Any')
  end

  def add_date_time_filter
    "created_at >= '#{time_to_string(params[:start_time])}' AND " +
        "created_at <= '#{time_to_string(params[:end_time])}'"
  end

  def add_version_type_filter (version_type)
    "item_type = '#{version_type}' AND " if version_type && !(version_type.eql? 'Any')
  end

  def time_to_string(time)
    "#{time.gsub('/', '-')}:00"
  end
end
