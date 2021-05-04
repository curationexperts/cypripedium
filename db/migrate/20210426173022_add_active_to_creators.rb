class AddActiveToCreators < ActiveRecord::Migration[5.1]
  def change
    add_column :creators, :active_creator, :boolean, null: false, default: true
  end
end
