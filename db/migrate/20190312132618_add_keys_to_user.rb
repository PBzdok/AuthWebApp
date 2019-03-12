class AddKeysToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :public_key, :string
    add_column :users, :private_key, :string
  end
end
