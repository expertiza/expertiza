require 'redcloth'

class ContentPage < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name

  belongs_to :permission

  attr_accessor :content_html

  def self.find_for_permission(p_ids)
    where('permission_id in (?)', p_ids)
      .order(:name)
  end

  def url
    "/#{self.name}"
  end

  def markup_style
    if !@markup_style && markup_style_id && markup_style_id > 0
      @markup_style = MarkupStyle.find markup_style_id
    end
  end

  before_save :setup_save
  def setup_save
    self.content_cache = markup_content
  end

  def content_html
    if content_cache && content_cache.length > 0
      content_cache.html_safe
    else
      markup_content.html_safe
    end
  end

  protected

  def markup_content
    markup = self.markup_style
    if markup and markup.name
      if markup.name == 'Textile'
        content_html = RedCloth.new(self.content).to_html(:textile)
      elsif markup.name == 'Markdown'
        content_html = RedCloth.new(self.content).to_html(:markdown)
      else
        content_html = self.content
      end
    else
      content_html = self.content
    end
    return content_html
  end
end
