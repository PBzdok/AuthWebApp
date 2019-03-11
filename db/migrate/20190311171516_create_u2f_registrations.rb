class CreateU2fRegistrations < ActiveRecord::Migration[5.2]
  def change
    create_table :u2f_registrations do |t|
      t.timestamps
    end
  end
end
