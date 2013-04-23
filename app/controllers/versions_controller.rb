class VersionsController < ApplicationController
  before_filter :conflict?
  # test if someone else has edited the same item to undo
  def conflict?
    @version = Version.find_by_id(params[:id])
    @versions = Version.find(:all,:conditions => ["whodunnit = ? AND created_at = ?", @version.whodunnit,@version.created_at])
    @versions.each do |v|
      if v.item
        if v.item.versions.last.whodunnit.to_i != session[:user].id
          flash[:note] = "User #{User.find(v.item.versions.last.whodunnit).name} already edited this item."
          redirect_to :back
        end
      end
    end
  end

  def revert
    @version = Version.find_by_id(params[:id])
    @versions = Version.find(:all,:conditions => ["whodunnit = ? AND created_at BETWEEN ? AND ?", @version.whodunnit,@version.created_at-1.0,@version.created_at + 1.0])
    @iteration = 0
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
end