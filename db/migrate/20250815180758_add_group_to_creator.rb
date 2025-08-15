class AddGroupToCreator < ActiveRecord::Migration[7.2]
  def change
    add_column :creators, :group, :integer, default: 0, null: false
    add_index :creators, [:group, :display_name]
  end
end
