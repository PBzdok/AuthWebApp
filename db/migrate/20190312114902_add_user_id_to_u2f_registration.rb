class AddUserIdToU2fRegistration < ActiveRecord::Migration[5.2]
  def change
    add_reference :u2f_registrations, :user, foreign_key: { to_table: :users }
  end
end
