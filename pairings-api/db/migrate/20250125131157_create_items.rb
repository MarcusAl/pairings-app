class CreateItems < ActiveRecord::Migration[8.0]
  def change
    create_table :items, id: :uuid do |t|
      t.string :name
      t.text :description
      t.string :category, null: false
      t.string :subcategory
      t.string :image_key
      t.references :user, null: false, foreign_key: true, type: :uuid, index: true
      t.boolean :public, default: false
      t.string :flavor_profiles, array: true, default: []
      t.string :primary_flavor_profile
      t.string :price_range
      t.json :attributes

      t.timestamps
    end


    add_index :items, :flavor_profiles, using: 'gin'
  end
end
