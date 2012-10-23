class SiteController < ActiveRecord::Base

  validates_presence_of :name
  validates_uniqueness_of :name
  attr_accessor :permission

  def permission
    @permission ||= Permission.find_by_id(self.permission_id)
    return @permission
  end

  def actions
    @actions ||= ControllerAction.find(:all,
                                       :conditions =>
                                       "site_controller_id = #{self.id}",
                                       :order => 'name')
  end


  def self.classes
    for file in Dir.glob("#{RAILS_ROOT}/app/controllers/*.rb") do
      begin
        load file
      rescue
        logger.info "Couldn't load file '#{file}' (already loaded?)"
      end
    end
    
    classes = Hash.new
    
    ObjectSpace.each_object(Class) do |klass|
      if klass.respond_to? :controller_name
        if klass.superclass.to_s == ApplicationController.to_s
          classes[klass.controller_name] = klass
        end
      end
    end

    return classes
  end

end
