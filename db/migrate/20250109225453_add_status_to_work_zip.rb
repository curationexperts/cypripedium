class AddStatusToWorkZip < ActiveRecord::Migration[5.2]
  def change
    add_column :work_zips, :status, :integer, default: 0
  end
end
