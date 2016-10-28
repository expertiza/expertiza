require 'redcloth'

class ContentPage < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name

  belongs_to :permission

  attr_accessor :content_html

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
    if content_cache && !content_cache.empty?
      content_cache.html_safe
    else
      markup_content.html_safe
    end
  end

  protected

  def markup_content
    markup = self.markup_style
    if markup and markup.name
      content_html = if markup.name == 'Textile'
                       RedCloth.new(self.content).to_html(:textile)
                     elsif markup.name == 'Markdown'
                       RedCloth.new(self.content).to_html(:markdown)
                     else
                       self.content
                     end
    else
      content_html = self.content
    end
    content_html
  end
end
