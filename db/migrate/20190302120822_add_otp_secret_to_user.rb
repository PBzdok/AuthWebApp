class AddOtpSecretToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :encrypted_otp_secret, :string
  end
end
