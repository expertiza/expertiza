class AddLangLocaleToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :locale, :integer, default: 0
  end
end
