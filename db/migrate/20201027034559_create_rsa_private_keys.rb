class CreateRsaPrivateKeys < ActiveRecord::Migration

  def up
    RsaPrivateKey.create(:key_name=>'rsa_key', :key_value=> 'ZXhwZXJ0aXph\n')
  end

  def change
    create_table :rsa_private_keys do |t|
      t.string :key_name
      t.string :key_value

      t.timestamps null: false
    end
  end
end
