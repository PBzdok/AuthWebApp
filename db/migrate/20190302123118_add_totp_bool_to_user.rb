class AddTotpBoolToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :totp_activated, :boolean
  end
end
