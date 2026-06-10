# frozen_string_literal: true

class AddVindiFieldsTo<%= class_name.pluralize %> < ActiveRecord::Migration[<%= ActiveRecord::Migration.current_version %>]
  def change
    add_column :<%= table_name %>, :vindi_customer_id, :string
    add_column :<%= table_name %>, :vindi_payment_profile_id, :string
    
    add_index :<%= table_name %>, :vindi_customer_id, unique: true
  end
end
