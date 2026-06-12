# frozen_string_literal: true

require "rails/generators"

module Vindi
  module Generators
    class WebhookHandlerGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      desc "Creates a specific modular webhook handler and a base handler if it does not exist."

      def create_webhook_handler_files
        template "base_handler.rb", "app/services/vindi/webhooks/base_handler.rb"
        template "webhook_handler.rb", "app/services/vindi/webhooks/#{file_name}_handler.rb"
      end
    end
  end
end
