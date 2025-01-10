class AddStatusToWorkZip < ActiveRecord::Migration[6.1]
  def change
    add_column :work_zips, :status, :integer, default: 0
  end
end
