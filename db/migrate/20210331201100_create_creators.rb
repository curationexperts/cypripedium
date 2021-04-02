class CreateCreators < ActiveRecord::Migration[5.1]
  def change
    create_table :creators do |t|
      t.string :display_name, null: false
      t.string :repec
      t.string :viaf
      t.references :qa_local_authority_entries
      t.text :alternate_names, default: [].to_yaml
      t.timestamps
    end
  end
end
