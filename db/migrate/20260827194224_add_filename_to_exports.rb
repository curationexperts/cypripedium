class AddFilenameToExports < ActiveRecord::Migration[7.2]
  def change
    add_column :exports, :filename, :string
  end
end
