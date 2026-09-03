class AddVisibilityToExports < ActiveRecord::Migration[7.2]
  def change
    add_column :exports, :visibility, :string, default: 'open', null: false
  end
end
