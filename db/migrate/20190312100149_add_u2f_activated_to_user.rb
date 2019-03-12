class AddU2fActivatedToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :u2f_activated, :boolean
  end
end
