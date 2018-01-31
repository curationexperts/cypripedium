class CreateWorkZips < ActiveRecord::Migration[5.1]
  def change
    create_table :work_zips do |t|
      t.string :work_id
      t.string :job_id
      t.string :file_path

      t.timestamps
    end
  end
end
