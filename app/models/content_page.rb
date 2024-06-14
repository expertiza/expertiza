require 'redcloth'

class ContentPage < ApplicationRecord
  validates :name, presence: true
  validates :name, uniqueness: true

  belongs_to :permission

  # rubocop:disable Lint/DuplicateMethods
  attr_accessor :content_html
  # rubocop:enable Lint/DuplicateMethods

  def url
    "/#{name}"
  end

  def markup_style
    @markup_style = MarkupStyle.find markup_style_id if !@markup_style && markup_style_id && markup_style_id > 0
  end

  before_save :setup_save
  def setup_save
    self.content_cache = markup_content
  end

  # rubocop:disable Lint/DuplicateMethods
  def content_html
    if content_cache.present?
      content_cache.html_safe
    else
      markup_content.html_safe
    end
  end
  # rubocop:enable Lint/DuplicateMethods

  protected

  def markup_content
    markup = markup_style
    if markup && markup.name
      if markup.name == 'Textile'
        RedCloth.new(content).to_html(:textile)
      elsif markup.name == 'Markdown'
        RedCloth.new(content).to_html(:markdown)
      else
        content
      end
    else
      content
    end
  end
end
