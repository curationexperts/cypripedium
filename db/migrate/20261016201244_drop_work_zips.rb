class DropWorkZips < ActiveRecord::Migration[7.2]
  def change
    drop_table :work_zips do |t|
      t.string :work_id
      t.string :job_id
      t.string :file_path
      t.integer :status, default: 0
      t.datetime :created_at, precision: nil, null: false
      t.datetime :updated_at, precision: nil, null: false
    end
  end
end
