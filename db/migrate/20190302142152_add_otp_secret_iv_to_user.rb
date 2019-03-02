class AddOtpSecretIvToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :encrypted_otp_secret_iv, :string
  end
end
