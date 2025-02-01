class AddExpiresAtToSessions < ActiveRecord::Migration[8.0]
  def change
    add_column :sessions, :expires_at, :datetime, null: false, default: -> { 'CURRENT_TIMESTAMP + INTERVAL \'45 days\'' }
  end
end
