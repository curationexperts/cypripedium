class CreateExports < ActiveRecord::Migration[7.2]
  def change
    create_table :exports do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.string :items, array: true, default: []
      t.integer :format, null: false
      t.integer :status, null: false, default: 0
      t.string :message

      t.timestamps
    end
  end
end
