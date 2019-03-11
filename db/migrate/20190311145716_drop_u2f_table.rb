class DropU2fTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :u2f_registrations
  end
end
