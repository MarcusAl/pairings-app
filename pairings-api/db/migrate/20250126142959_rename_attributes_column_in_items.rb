class RenameAttributesColumnInItems < ActiveRecord::Migration[8.0]
  def change
    rename_column :items, :attributes, :item_attributes
  end
end
