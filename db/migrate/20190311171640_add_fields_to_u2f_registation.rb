class AddFieldsToU2fRegistation < ActiveRecord::Migration[5.2]
  def change
    add_column :u2f_registrations, :certificate, :string
    add_column :u2f_registrations, :key_handle, :string
    add_column :u2f_registrations, :public_key, :string
    add_column :u2f_registrations, :counter, :integer
  end
end
