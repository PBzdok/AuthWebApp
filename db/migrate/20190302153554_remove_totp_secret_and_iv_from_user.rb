class RemoveTotpSecretAndIvFromUser < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :encrypted_otp_secret
    remove_column :users, :encrypted_otp_secret_iv
  end
end
