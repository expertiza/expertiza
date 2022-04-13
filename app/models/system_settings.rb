class SystemSettings < ApplicationRecord
  self.table_name = 'system_settings'

  # rubocop:disable Lint/DuplicateMethods
  attr_accessor :public_role, :default_markup_style
  attr_accessor :site_default_page, :not_found_page, :permission_denied_page,
                :session_expired_page

  def public_role
    @public_role ||= Role.find(public_role_id)
  end

  def default_markup_style
    @default_markup_style ||= if default_markup_style_id
                                MarkupStyle.find(default_markup_style_id)
                              else
                                MarkupStyle.new(id: nil,
                                                name: '(None)')
                              end
    @default_markup_style
  end

  def site_default_page
    @site_default_page ||= ContentPage.find(site_default_page_id)
  end

  def not_found_page
    @not_found_page ||= ContentPage.find(not_found_page_id)
  end

  def permission_denied_page
    @permission_denied_page ||= ContentPage.find(permission_denied_page_id)
  end

  def session_expired_page
    @session_expired_page ||= ContentPage.find(session_expired_page_id)
  end
  # rubocop:enable Lint/DuplicateMethods

  # Returns an array of system page settings for a given page,
  # or nil if the page is not a system page.
  def system_pages(pageid)
    pages = []

    pages << 'Site default page' if site_default_page_id == pageid
    pages << 'Not found page' if not_found_page_id == pageid
    pages << 'Permission denied page' if permission_denied_page_id == pageid
    pages << 'Session expired page' if session_expired_page_id == pageid
    pages unless pages.empty?
  end
end
