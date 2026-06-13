# frozen_string_literal: true

require "rails/generators"
require "rails/generators/active_record"

module Vindi
  module Generators
    class OutboxGenerator < ::Rails::Generators::Base
      include ::Rails::Generators::Migration

      source_root File.expand_path("templates", __dir__)

      desc "Creates migration to store transactional outbox pending synchronization tasks"

      def self.next_migration_number(dirname)
        ::ActiveRecord::Generators::Base.next_migration_number(dirname)
      end

      def create_migration_file
        migration_template "outbox_migration.rb", "db/migrate/create_vindi_pending_syncs.rb"
      end
    end
  end
end
