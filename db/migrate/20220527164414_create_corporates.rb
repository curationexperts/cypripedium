class CreateCorporates < ActiveRecord::Migration[5.1]
  def change
    create_table :corporates do |t|
      t.string :corporate_name, null: false
      t.string :corporate_state, null: false
      t.string :corporate_city, null: false

      t.timestamps
    end
  end
end
