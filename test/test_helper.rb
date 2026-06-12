# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

require "minitest/autorun"
require "webmock/minitest"
require "rails"
require "active_record/railtie"
require "active_job/railtie"
require "action_controller/railtie"
require "vindi"
require "vindi/integrations/railtie"
require "vindi/integrations/concerns/synchronizable"

# Boot a minimal Rails application context
class DummyApp < Rails::Application
  config.root = File.expand_path("../..", __FILE__)
  config.eager_load = false
  config.logger = Logger.new(nil)
  config.active_job.queue_adapter = :test
  config.active_support.deprecation = :stderr

  # Provide database configuration directly on the configuration object
  def config.database_configuration
    {
      "test" => {
        "adapter" => "sqlite3",
        "database" => ":memory:"
      },
      "development" => {
        "adapter" => "sqlite3",
        "database" => ":memory:"
      }
    }
  end
end

Rails.application.initialize!

# Require rails/test_help after app initialization
require "rails/test_help"

# Setup SQLite in-memory database
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.string :name
    t.string :email
    t.string :vindi_customer_id
    t.timestamps
  end
end

# Require the generators so they are loaded in tests
require "generators/vindi/webhook_generator"
require "generators/vindi/sync_generator"
require "generators/vindi/webhook_handler_generator"

# Mock Vindi API setup
Vindi.configure do |config|
  config.api_key = "test_key"
end
