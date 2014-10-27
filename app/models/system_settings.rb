# == Schema Information
#
# Table name: system_settings
#
#  id                        :integer          not null, primary key
#  site_name                 :string(255)      default(""), not null
#  site_subtitle             :string(255)
#  footer_message            :string(255)      default("")
#  public_role_id            :integer          default(0), not null
#  session_timeout           :integer          default(0), not null
#  default_markup_style_id   :integer          default(0)
#  site_default_page_id      :integer          default(0), not null
#  not_found_page_id         :integer          default(0), not null
#  permission_denied_page_id :integer          default(0), not null
#  session_expired_page_id   :integer          default(0), not null
#  menu_depth                :integer          default(0), not null
#

class SystemSettings < ActiveRecord::Base
  set_table_name 'system_settings'

  attr_accessor :public_role, :default_markup_style
  attr_accessor :site_default_page, :not_found_page, :permission_denied_page,
  :session_expired_page

  def public_role
    @public_role ||= Role.find(self.public_role_id)
  end

  def default_markup_style
    if not @default_markup_style
      if self.default_markup_style_id
        @default_markup_style = MarkupStyle.find(self.default_markup_style_id)
      else
        @default_markup_style = MarkupStyle.new(:id => nil, 
                                                :name => '(None)')
      end
    end
    return @default_markup_style
  end

  def site_default_page
    @site_default_page ||= ContentPage.find(self.site_default_page_id)
  end

  def not_found_page
    @not_found_page ||= ContentPage.find(self.not_found_page_id)
  end

  def permission_denied_page
    @permission_denied_page ||= ContentPage.find(self.permission_denied_page_id)
  end

  def session_expired_page
    @session_expired_page ||= ContentPage.find(self.session_expired_page_id)
  end
  
  # Returns an array of system page settings for a given page,
  # or nil if the page is not a system page.
  def system_pages(pageid)
    pages = Array.new
    
    if self.site_default_page_id == pageid
      pages << "Site default page"
    end
    if self.not_found_page_id == pageid
      pages << "Not found page"
    end
    if self.permission_denied_page_id == pageid
      pages << "Permission denied page"
    end
    if self.session_expired_page_id == pageid
      pages << "Session expired page"
    end

    if pages.length > 0
      return pages
    else
      return nil
    end
  end

end
