# frozen_string_literal: true

require "rails/generators"
require "rails/generators/active_record"

module Vindi
  module Generators
    class SyncGenerator < ::Rails::Generators::NamedBase
      include ::Rails::Generators::Migration

      source_root File.expand_path("templates", __dir__)

      desc "Adds Vindi synchronization columns to database and concern to your model."

      def self.next_migration_number(dirname)
        ::ActiveRecord::Generators::Base.next_migration_number(dirname)
      end

      def create_migration_file
        migration_template "migration.rb", "db/migrate/add_vindi_fields_to_#{table_name}.rb"
      end

      def inject_concern_into_model
        model_path = File.join("app/models", "#{file_path}.rb")
        
        if File.exist?(model_path)
          inject_into_class(model_path, class_name, "  include Vindi::Synchronizable\n")
        else
          say_status("warning", "Model file #{model_path} not found. Please add 'include Vindi::Synchronizable' manually.", :yellow)
        end
      end

      private

      def table_name
        name.pluralize.underscore
      end
    end
  end
end
