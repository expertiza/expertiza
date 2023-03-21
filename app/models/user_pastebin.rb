class UserPastebin < ActiveRecord::Base
  validates :user_id, uniqueness: { scope: :short_form }

  @markdown_character = '\\'

  def self.get_current_user_pastebin(user)
    @user_pastebins = UserPastebin.where(user_id: user.id)
  end

  def self.get_current_user_pastebin_json(user)
    @user_pastebins = get_current_user_pastebin(user)
    @pastebin_list = @user_pastebins.map do |u|
      { label: @markdown_character + u.short_form, value: u.long_form }
    end
    @pastebin_list.to_json
  end
end
