class CreatePairings < ActiveRecord::Migration[8.0]
  def change
    create_table :pairings, id: :uuid do |t|
      t.references :item1, null: false, foreign_key: { to_table: :items }, type: :uuid
      t.references :item2, null: false, foreign_key: { to_table: :items }, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid, index: true
      t.integer :strength
      t.text :pairing_notes
      t.text :ai_reasoning
      t.float :confidence_score
      t.boolean :public, default: false

      t.timestamps
    end

    add_index :pairings, [:item1_id, :item2_id, :user_id], unique: true
  end
end

