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
    while @versions.length != 0 do
      @versions.each do |v|
        if v.reify
          begin
            v.reify.save!
          rescue
          else
            @versions.delete(v)
          end
        else
          v.item.destroy
          @versions.delete(v)
        end
      end
    end
    begin
      redirect_to :back
    rescue
      redirect_to :controller => :tree_display,:action => :list
    end
  end
end