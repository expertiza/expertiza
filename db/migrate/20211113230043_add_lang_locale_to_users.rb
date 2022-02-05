class AddLangLocaleToUsers < ActiveRecord::Migration
  def change
    add_column :users, :locale, :integer, default: 0
  end
end
