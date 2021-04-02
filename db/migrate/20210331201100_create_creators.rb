class CreateCreators < ActiveRecord::Migration[5.1]
  def change
    create_table :creators do |t|
      t.string :display_name, null: false
      t.string :repec
      t.string :viaf
      t.references :qa_local_authority_entries

      t.timestamps
    end

    create_table :alternate_names do |t|
      t.belongs_to :creator, index: true, foreign_key: true
      t.string :display_name

      t.timestamps
    end
  end
end
