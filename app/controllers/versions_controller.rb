class VersionsController < ApplicationController

  def index
    @versions = Version.all
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
    @version = Version.find(params[:id])
    @versions = Version.where( ["whodunnit = ? AND created_at = ?", @version.whodunnit,@version.created_at])
    @versions.each do |v|
      if v.item
        if v.item.versions.last.whodunnit.to_i != session[:user].id
          flash[:note] = "User #{User.find(v.item.versions.last.whodunnit).name} has edited this item since your last edit. "
          redirect_to :back
        end
      end
    end
  end

  def revert
    @version = Version.find(params[:id])
    # find all new versions created by current user at one single action
    @versions = Version.where( ["whodunnit = ? AND created_at BETWEEN ? AND ?", @version.whodunnit,@version.created_at-1.0,@version.created_at + 1.0])
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
end
