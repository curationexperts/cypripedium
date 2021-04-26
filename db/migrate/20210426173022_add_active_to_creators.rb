class AddActiveToCreators < ActiveRecord::Migration[5.1]
  def change
    add_column :creators, :active, :boolean
  end
end
