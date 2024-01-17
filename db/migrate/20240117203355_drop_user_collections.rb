class DropUserCollections < ActiveRecord::Migration[5.2]
  def up
    drop_table :user_collections
  end

  def down
    create_table :user_collections do |t|
      t.string :email, :null => false, :uniqueness => true
      t.text :collections, default: [].to_yaml

      t.timestamps
    end
    add_index :user_collections, :email
  end
end
