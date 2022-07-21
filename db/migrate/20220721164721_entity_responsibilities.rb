class EntityResponsibilities < ActiveRecord::Migration[5.2]
  def change
    change_column :sipity_entity_specific_responsibilities, :entity_id, 'INTEGER USING cast(entity_id as integer)', null: false
  end
end
