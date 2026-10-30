class AddCountsToExports < ActiveRecord::Migration[7.2]
  def change
    add_column :exports, :error_count, :integer, default: 0, null: false
    add_column :exports, :exported_count, :integer
  end
end
