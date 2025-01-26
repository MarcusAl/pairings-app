class RemoveImageKeyFromItems < ActiveRecord::Migration[8.0]
  def change
    remove_column :items, :image_key, :string
  end
end

