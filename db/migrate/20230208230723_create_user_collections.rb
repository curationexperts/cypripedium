class CreateUserCollections < ActiveRecord::Migration[5.2]
  def change
    create_table :user_collections do |t|
      t.string :email, :null => false, :uniqueness => true
      t.text :collections, default: [].to_yaml

      t.timestamps
    end
    add_index :user_collections, :email
  end
end
