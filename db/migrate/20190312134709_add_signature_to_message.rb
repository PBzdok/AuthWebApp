class AddSignatureToMessage < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :signature, :string
  end
end
