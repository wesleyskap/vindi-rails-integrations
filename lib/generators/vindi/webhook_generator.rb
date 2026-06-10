# frozen_string_literal: true

require "rails/generators"

module Vindi
  module Generators
    class WebhookGenerator < ::Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Creates a Webhooks controller and an ActiveJob to handle Vindi webhook events."

      def copy_webhook_files
        template "webhooks_controller.rb", "app/controllers/vindi/webhooks_controller.rb"
        template "webhook_job.rb", "app/jobs/vindi/webhook_job.rb"
        route 'post "/vindi/webhooks" => "vindi/webhooks#create"'
      end
    end
  end
end
