class VersionsController < ApplicationController
  def revert
    @version = Version.find_by_id(params[:id])
    @versions = Version.find(:all,:conditions => ["whodunnit = ? AND created_at = ?", @version.whodunnit,@version.created_at])
    @versions.each do |v|
      if v.reify
        v.reify.save!
      else
        v.item.destroy
      end
    end
    redirect_to :back
    #if @version.reify
    #  if @version.event == "destroy"
    #    redirect_to :controller => @version.reify.class.to_s.tableize.singularize,:action => :create, @version.reify.class.to_s.tableize.singularize => @version.reify.attributes
    #  else
    #    @version.reify.save!
    #    redirect_to :back
    #  end
    #else
    #  redirect_to :controller => @version.item.class.to_s.tableize.singularize,:action => :delete,:id => @version.item.id
    #end
  end
end