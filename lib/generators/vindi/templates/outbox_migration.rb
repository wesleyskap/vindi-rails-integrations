# frozen_string_literal: true

class CreateVindiPendingSyncs < ActiveRecord::Migration[<%= ActiveRecord::Migration.current_version %>]
  def change
    create_table :vindi_pending_syncs do |t|
      t.string :item_type, null: false
      t.string :item_id, null: false
      t.string :action, null: false
      t.text :params
      t.string :status, null: false, default: "pending"
      t.integer :attempts, null: false, default: 0
      t.text :last_error

      t.timestamps
    end

    add_index :vindi_pending_syncs, [:status, :attempts]
    add_index :vindi_pending_syncs, [:item_type, :item_id]
  end
end
