class CreateCreators < ActiveRecord::Migration[5.1]
  def change
    create_table :creators do |t|
      t.string :display_name
      t.string :alternate_names
      t.string :repec
      t.string :viaf

      t.timestamps
    end
    add_index :creators, :repec, unique: true
    add_index :creators, :viaf, unique: true
  end
end
