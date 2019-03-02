class AddOtpSecretToUserV2 < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :otp_secret, :string
  end
end
