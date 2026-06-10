# frozen_string_literal: true

require_relative "test_helper"
require "rails/generators/test_case"

class SyncGeneratorTest < Rails::Generators::TestCase
  tests Vindi::Generators::SyncGenerator
  destination File.expand_path("../tmp", __FILE__)
  setup :prepare_destination

  test "generator creates migration file" do
    run_generator ["User"]

    assert_migration "db/migrate/add_vindi_fields_to_users.rb" do |content|
      assert_match(/class AddVindiFieldsToUsers < ActiveRecord::Migration/, content)
      assert_match(/add_column :users, :vindi_customer_id, :string/, content)
      assert_match(/add_index :users, :vindi_customer_id/, content)
    end
  end
end
