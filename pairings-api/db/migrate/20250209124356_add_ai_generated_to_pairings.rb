class AddAiGeneratedToPairings < ActiveRecord::Migration[8.0]
  def change
    add_column :pairings, :ai, :boolean, default: false
  end
end
