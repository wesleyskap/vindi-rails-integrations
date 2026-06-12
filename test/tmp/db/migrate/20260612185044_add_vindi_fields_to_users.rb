# frozen_string_literal: true

class AddVindiFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :vindi_customer_id, :string
    add_column :users, :vindi_payment_profile_id, :string
    
    add_index :users, :vindi_customer_id, unique: true
  end
end
